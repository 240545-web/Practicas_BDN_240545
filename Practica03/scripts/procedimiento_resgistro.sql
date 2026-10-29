USE db_test;

-- Eliminar el procedimiento si ya existía
DROP PROCEDURE IF EXISTS sp_register_new_user;

DELIMITER $$

CREATE PROCEDURE sp_register_new_user(
    IN p_email VARCHAR(80),
    IN p_nickname VARCHAR(100),
    IN p_password VARCHAR(255),    -- Se encriptará dentro del procedimiento
    IN p_given_names VARCHAR(100),
    IN p_family_names VARCHAR(100),
    IN p_birth_date DATE,
    IN p_country_code CHAR(2),
    IN p_phone VARCHAR(20)
)
BEGIN
    -- Variables para manejar la transacción
    DECLARE v_new_user_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si algo falla (ej. email duplicado), deshacemos todo
        ROLLBACK;
        SELECT 'Error: No se pudo registrar el usuario. Transacción cancelada.' AS Mensaje;
    END;

    -- Iniciar la transacción (Paso 7: Separar la información)
    START TRANSACTION;

    -- 1. Insertar en tb_users (Paso 8: Encriptar contraseña con SHA2)
    INSERT INTO tb_users (email, nickname, password)
    VALUES (p_email, p_nickname, SHA2(p_password, 256));

    -- 2. Obtener el ID que se acaba de generar en tb_users
    SET v_new_user_id = LAST_INSERT_ID();

    -- 3. Insertar los datos personales en tb_people usando el mismo ID
    INSERT INTO tb_people (
        user_ID, courtesy_title, given_names, family_names, 
        birth_date, gender_ID, country_code, postal_code, phone
    ) 
    VALUES (
        v_new_user_id, 'Sr.', p_given_names, p_family_names, 
        p_birth_date, 1, p_country_code, '00000', p_phone
    );

    -- Si todo salió bien, guardamos los cambios
    COMMIT;
    
    SELECT '¡Usuario registrado exitosamente!' AS Mensaje, v_new_user_id AS ID_Creado;

END$$

DELIMITER ;