USE db_test;

DROP PROCEDURE IF EXISTS sp_generate_massive_users;

DELIMITER $$

CREATE PROCEDURE sp_generate_massive_users(IN p_scenario INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_total_rows INT DEFAULT 0;
    DECLARE v_user_id INT;
    DECLARE v_first_name VARCHAR(50);
    DECLARE v_last_name VARCHAR(50);
    DECLARE v_email VARCHAR(100);
    DECLARE v_country CHAR(2);
    DECLARE v_birth_date DATE;
    DECLARE v_deleted_at DATETIME;

    -- Desactivamos el autocommit para que sea rápido
    SET autocommit = 0;

    -- =========================================================
    -- ESCENARIO 1: 1000 Usuarios Estadounidenses (Datos Amazon)
    -- =========================================================
    IF p_scenario = 1 THEN
        SET v_total_rows = 1000;
        
        START TRANSACTION;
        WHILE i < v_total_rows DO
            SET v_first_name = ELT(FLOOR(1 + RAND() * 10), 'James', 'Mary', 'Robert', 'Patricia', 'John', 'Jennifer', 'Michael', 'Linda', 'David', 'Elizabeth');
            SET v_last_name = ELT(FLOOR(1 + RAND() * 10), 'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez');
            
            SET v_email = CONCAT(LOWER(v_first_name), '.', LOWER(v_last_name), i, '@amazon-test.com');
            SET v_country = 'US';
            SET v_birth_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 15000) DAY);
            
            -- AQUÍ ESTÁ LA CORRECCIÓN: Agregamos ' #', i al nickname
            INSERT INTO tb_users (email, nickname, password) 
            VALUES (v_email, CONCAT(v_first_name, ' ', v_last_name, ' #', i), SHA2('Amazon123', 256));
            
            SET v_user_id = LAST_INSERT_ID();
            
            INSERT INTO tb_people (user_ID, given_names, family_names, birth_date, country_code, phone) 
            VALUES (v_user_id, v_first_name, v_last_name, v_birth_date, v_country, CONCAT('+1', FLOOR(1000000000 + RAND() * 8999999999)));
            
            SET i = i + 1;
        END WHILE;
        COMMIT;

    -- =========================================================
    -- ESCENARIO 2: 2000 Usuarios (18 a 30 años) de varios países
    -- =========================================================
    ELSEIF p_scenario = 2 THEN
        SET v_total_rows = 2000;
        SET i = 0;
        
        START TRANSACTION;
        WHILE i < v_total_rows DO
            SET v_first_name = ELT(FLOOR(1 + RAND() * 10), 'Carlos', 'Sofia', 'Mateo', 'Valentina', 'Lucas', 'Isabella', 'Diego', 'Camila', 'Alejandro', 'Daniela');
            SET v_last_name = ELT(FLOOR(1 + RAND() * 10), 'Gomez', 'Rodriguez', 'Lopez', 'Martinez', 'Perez', 'Gonzalez', 'Sanchez', 'Ramirez', 'Torres', 'Flores');
            SET v_email = CONCAT(LOWER(v_first_name), '.', LOWER(v_last_name), i, '@test-global.com');
            
            SET v_country = ELT(FLOOR(1 + RAND() * 5), 'MX', 'CO', 'AR', 'ES', 'CL');
            -- Edad: 18 años (6570 días) a 30 años (10950 días)
            SET v_birth_date = DATE_SUB(CURDATE(), INTERVAL (6570 + FLOOR(RAND() * 4380)) DAY);
            
            -- CORRECCIÓN en nickname
            INSERT INTO tb_users (email, nickname, password) 
            VALUES (v_email, CONCAT(v_first_name, ' ', v_last_name, ' #', i), SHA2('User123', 256));
            
            SET v_user_id = LAST_INSERT_ID();
            
            INSERT INTO tb_people (user_ID, given_names, family_names, birth_date, country_code, phone) 
            VALUES (v_user_id, v_first_name, v_last_name, v_birth_date, v_country, CONCAT('+52', FLOOR(1000000000 + RAND() * 8999999999)));
            
            SET i = i + 1;
        END WHILE;
        COMMIT;

    -- =========================================================
    -- ESCENARIO 3: 7222 Usuarios (85% activos, 15% de baja)
    -- =========================================================
    ELSEIF p_scenario = 3 THEN
        SET v_total_rows = 7222;
        SET i = 0;
        
        START TRANSACTION;
        WHILE i < v_total_rows DO
            SET v_first_name = ELT(FLOOR(1 + RAND() * 10), 'William', 'Olivia', 'Henry', 'Ava', 'Alexander', 'Mia', 'Daniel', 'Charlotte', 'Matthew', 'Amelia');
            SET v_last_name = ELT(FLOOR(1 + RAND() * 10), 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Moore', 'Young', 'Allen');
            SET v_email = CONCAT(LOWER(v_first_name), '.', LOWER(v_last_name), i, '@platform-test.com');
            SET v_country = ELT(FLOOR(1 + RAND() * 3), 'US', 'CA', 'GB');
            SET v_birth_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 15000) DAY);
            
            IF (RAND() <= 0.85) THEN
                SET v_deleted_at = NULL; -- Activo
            ELSE
                SET v_deleted_at = CURRENT_TIMESTAMP - INTERVAL FLOOR(RAND() * 30) DAY; -- Dado de baja
            END IF;
            
            -- CORRECCIÓN en nickname
            INSERT INTO tb_users (email, nickname, password, deleted_at) 
            VALUES (v_email, CONCAT(v_first_name, ' ', v_last_name, ' #', i), SHA2('Pass123', 256), v_deleted_at);
            
            SET v_user_id = LAST_INSERT_ID();
            
            INSERT INTO tb_people (user_ID, given_names, family_names, birth_date, country_code, phone, deleted_at) 
            VALUES (v_user_id, v_first_name, v_last_name, v_birth_date, v_country, CONCAT('+44', FLOOR(1000000000 + RAND() * 8999999999)), v_deleted_at);
            
            SET i = i + 1;
        END WHILE;
        COMMIT;
        
    ELSE
        SELECT 'Escenario no válido. Usa 1, 2 o 3.' AS Error;
    END IF;

    SET autocommit = 1;
    SELECT CONCAT('¡Éxito! Se generaron ', v_total_rows, ' usuarios para el escenario ', p_scenario) AS Resultado;
END$$

DELIMITER ;