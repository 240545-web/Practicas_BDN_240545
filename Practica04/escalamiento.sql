/* ============================================================
   PRÁCTICA 04 - ESCALAMIENTO DE DOMICILIO JERÁRQUICO
   Alumno: Emigdio Aguirre - 240545
   Base existente: db_test (no se crea ninguna base nueva)
   Motor: MySQL 8.0
   ------------------------------------------------------------
   1. Tabla tbd_address_componentes: árbol de 10 niveles.
   2. sp_crear_domicilio_escalado: inserta los 10 niveles en orden.
   3. sp_crear_usuario: inserta tb_users + tb_people en una llamada.
   ============================================================ */

USE db_test;
SET NAMES utf8mb4;

/* ============================================================
   1. TABLA DE ESCALAMIENTO DE DOMICILIO
   address_sup_ID = 0 significa "raíz" (País). No se declara FK
   para permitir la raíz 0; la jerarquía se valida por componente.
   ============================================================ */
CREATE TABLE IF NOT EXISTS tbd_address_componentes (
    ID             INT UNSIGNED NOT NULL AUTO_INCREMENT,
    address_ID     INT          NOT NULL,
    `value`        VARCHAR(150) NOT NULL,
    component_type ENUM(
        'País','Estado','Municipio','Ciudad','Localidad',
        'Código Postal','Colonia','Calle/Avenida',
        'Número Exterior','Número Interior'
    ) NOT NULL,
    status         BIT(1)       NOT NULL DEFAULT b'1',
    address_sup_ID INT          NOT NULL DEFAULT 0,
    creation_date  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    KEY idx_domicilio_address (address_ID),
    KEY idx_domicilio_padre (address_sup_ID),
    KEY idx_domicilio_tipo (component_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   2. PROCEDIMIENTO sp_crear_domicilio_escalado
   Inserta los 10 niveles en orden. El LAST_INSERT_ID() de cada
   nivel se usa como address_sup_ID del nivel siguiente.
   ============================================================ */
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_crear_domicilio_escalado$$

CREATE PROCEDURE sp_crear_domicilio_escalado(
    IN p_pais        VARCHAR(100),
    IN p_estado      VARCHAR(100),
    IN p_municipio   VARCHAR(100),
    IN p_ciudad      VARCHAR(100),
    IN p_localidad   VARCHAR(100),
    IN p_cp          VARCHAR(20),
    IN p_colonia     VARCHAR(100),
    IN p_calle       VARCHAR(150),
    IN p_num_ext     VARCHAR(30),
    IN p_num_int     VARCHAR(30),
    IN p_address_ID  INT
)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_padre INT DEFAULT 0;
    DECLARE v_raiz  INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Nivel 1: País (raíz, address_sup_ID = 0)
    INSERT INTO tbd_address_componentes
        (address_ID, `value`, component_type, status, address_sup_ID)
    VALUES (p_address_ID, p_pais, 'País', b'1', 0);
    SET v_raiz  = LAST_INSERT_ID();
    SET v_padre = v_raiz;

    -- Nivel 2: Estado
    INSERT INTO tbd_address_componentes
        (address_ID, `value`, component_type, status, address_sup_ID)
    VALUES (p_address_ID, p_estado, 'Estado', b'1', v_padre);
    SET v_padre = LAST_INSERT_ID();

    -- Nivel 3: Municipio
    INSERT INTO tbd_address_componentes
        (address_ID, `value`, component_type, status, address_sup_ID)
    VALUES (p_address_ID, p_municipio, 'Municipio', b'1', v_padre);
    SET v_padre = LAST_INSERT_ID();

    -- Nivel 4: Ciudad
    INSERT INTO tbd_address_componentes
        (address_ID, `value`, component_type, status, address_sup_ID)
    VALUES (p_address_ID, p_ciudad, 'Ciudad', b'1', v_padre);
    SET v_padre = LAST_INSERT_ID();

    -- Nivel 5: Localidad
    INSERT INTO tbd_address_componentes
        (address_ID, `value`, component_type, status, address_sup_ID)
    VALUES (p_address_ID, p_localidad, 'Localidad', b'1', v_padre);
    SET v_padre = LAST_INSERT_ID();

    -- Nivel 6: Código Postal
    INSERT INTO tbd_address_componentes
        (address_ID, `value`, component_type, status, address_sup_ID)
    VALUES (p_address_ID, p_cp, 'Código Postal', b'1', v_padre);
    SET v_padre = LAST_INSERT_ID();

    -- Nivel 7: Colonia
    INSERT INTO tbd_address_componentes
        (address_ID, `value`, component_type, status, address_sup_ID)
    VALUES (p_address_ID, p_colonia, 'Colonia', b'1', v_padre);
    SET v_padre = LAST_INSERT_ID();

    -- Nivel 8: Calle/Avenida
    INSERT INTO tbd_address_componentes
        (address_ID, `value`, component_type, status, address_sup_ID)
    VALUES (p_address_ID, p_calle, 'Calle/Avenida', b'1', v_padre);
    SET v_padre = LAST_INSERT_ID();

    -- Nivel 9: Número Exterior
    INSERT INTO tbd_address_componentes
        (address_ID, `value`, component_type, status, address_sup_ID)
    VALUES (p_address_ID, p_num_ext, 'Número Exterior', b'1', v_padre);
    SET v_padre = LAST_INSERT_ID();

    -- Nivel 10: Número Interior
    INSERT INTO tbd_address_componentes
        (address_ID, `value`, component_type, status, address_sup_ID)
    VALUES (p_address_ID, p_num_int, 'Número Interior', b'1', v_padre);

    COMMIT;

    -- Verificación: devuelve la raíz y los 10 niveles en orden.
    SELECT v_raiz AS address_raiz_ID;

    SELECT
        ID,
        address_ID,
        component_type,
        `value`,
        address_sup_ID,
        status
    FROM tbd_address_componentes
    WHERE address_ID = p_address_ID
    ORDER BY FIELD(
        component_type,
        'País','Estado','Municipio','Ciudad','Localidad',
        'Código Postal','Colonia','Calle/Avenida',
        'Número Exterior','Número Interior'
    );
END$$

/* ============================================================
   3. PROCEDIMIENTO sp_crear_usuario
   Inserta tb_users + tb_people en una sola llamada y una
   transacción. La contraseña se encripta con SHA2-256.
   ============================================================ */
DROP PROCEDURE IF EXISTS sp_crear_usuario$$

CREATE PROCEDURE sp_crear_usuario(
    IN  p_email        VARCHAR(80),
    IN  p_nickname     VARCHAR(100),
    IN  p_password     VARCHAR(255),
    IN  p_given_names  VARCHAR(100),
    IN  p_family_names VARCHAR(100),
    IN  p_birth_date   DATE,
    IN  p_country_code CHAR(2),
    IN  p_phone        VARCHAR(20),
    OUT p_user_id      INT
)
SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Cuenta de acceso
    INSERT INTO tb_users (email, nickname, password)
    VALUES (p_email, p_nickname, SHA2(p_password, 256));

    SET p_user_id = LAST_INSERT_ID();

    -- 2. Ficha personal ligada al mismo ID
    INSERT INTO tb_people (
        user_ID, courtesy_title, given_names, family_names,
        birth_date, gender_ID, country_code, postal_code, phone
    )
    VALUES (
        p_user_id, 'Sr.', p_given_names, p_family_names,
        p_birth_date, 1, p_country_code, '00000', p_phone
    );

    COMMIT;

    SELECT p_user_id AS nuevo_user_id;
END$$

DELIMITER ;

/* ============================================================
   EJEMPLO DE USO (descomentar para probar)
   ------------------------------------------------------------
   CALL sp_crear_domicilio_escalado(
       'México','Jalisco','Zapopan','Zapopan','Ladera Norte',
       '45110','Real del Valle','Av. Patria','120','5B', 5001);

   CALL sp_crear_usuario(
       'luna.ferreyra@correo.test','Luna Ferreyra','Luna2026!',
       'Luna','Ferreyra','1998-03-12','MX','5512348001', @u1);
   SELECT @u1;
   ============================================================ */
