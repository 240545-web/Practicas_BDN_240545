USE db_test;

DROP PROCEDURE IF EXISTS sp_massive_user_generation;

DELIMITER $$

CREATE PROCEDURE sp_massive_user_generation(IN p_scenario INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_user_id INT;
    DECLARE v_full_name VARCHAR(100);
    DECLARE v_email VARCHAR(100);
    DECLARE v_birth_date DATE;
    DECLARE v_country CHAR(2);
    DECLARE v_deleted_at DATETIME;
    DECLARE v_product_id INT;
    DECLARE v_payment_method INT;
    DECLARE v_order_id INT; -- Variable nueva para la orden

    SET autocommit = 0;

    -- ESCENARIO 1: 1000 Usuarios US
    IF p_scenario = 1 THEN
        SET v_total = 1000;
        START TRANSACTION;
        WHILE i < v_total DO
            SET v_full_name = fn_gen_us_name();
            SET v_email = CONCAT(REPLACE(LOWER(v_full_name), ' ', '.'), i, '@amazon-test.com');
            SET v_country = 'US';
            SET v_birth_date = fn_gen_random_date(18, 60);
            SET v_deleted_at = NULL; 
            
            INSERT INTO tb_users (email, nickname, password, deleted_at) VALUES (v_email, v_full_name, SHA2('Amazon123', 256), v_deleted_at);
            SET v_user_id = LAST_INSERT_ID();
            INSERT INTO tb_people (user_ID, given_names, family_names, birth_date, country_code) VALUES (v_user_id, SUBSTRING_INDEX(v_full_name, ' ', 1), SUBSTRING_INDEX(v_full_name, ' ', -1), v_birth_date, v_country);
            
            SET v_product_id = fn_get_random_active_product();
            IF v_product_id IS NOT NULL THEN
                INSERT INTO tbd_shopping_cart (user_ID, product_ID, quantity) VALUES (v_user_id, v_product_id, FLOOR(1 + RAND() * 3));
            END IF;
            
            -- CREAMOS LA ORDEN FICTICIA ANTES DEL PAGO
            INSERT INTO tb_orders (`key`, user_ID, total_products, total_cost, status_string) 
            VALUES (CONCAT('ORD-', v_user_id), v_user_id, 1, 100.00, 'Completed');
            SET v_order_id = LAST_INSERT_ID();
            
            SET v_payment_method = FLOOR(1 + RAND() * 3);
            INSERT INTO tb_payments (order_id, payment_method_id, amount, payment_status) VALUES (v_order_id, v_payment_method, FLOOR(100 + RAND() * 500), 'Completed');
            
            SET i = i + 1;
        END WHILE;
        COMMIT;

    -- ESCENARIO 2: 2000 Usuarios LATAM (18-30 años)
    ELSEIF p_scenario = 2 THEN
        SET v_total = 2000;
        SET i = 0;
        START TRANSACTION;
        WHILE i < v_total DO
            SET v_full_name = fn_gen_latam_name();
            SET v_email = CONCAT(REPLACE(LOWER(v_full_name), ' ', '.'), i, '@latam-test.com');
            SET v_country = ELT(FLOOR(1 + RAND() * 5), 'MX', 'CO', 'AR', 'ES', 'CL');
            SET v_birth_date = fn_gen_random_date(18, 30);
            SET v_deleted_at = NULL;
            
            INSERT INTO tb_users (email, nickname, password, deleted_at) VALUES (v_email, v_full_name, SHA2('Latam123', 256), v_deleted_at);
            SET v_user_id = LAST_INSERT_ID();
            INSERT INTO tb_people (user_ID, given_names, family_names, birth_date, country_code) VALUES (v_user_id, SUBSTRING_INDEX(v_full_name, ' ', 1), SUBSTRING_INDEX(v_full_name, ' ', -1), v_birth_date, v_country);
            
            SET v_product_id = fn_get_random_active_product();
            IF v_product_id IS NOT NULL THEN
                INSERT INTO tbd_shopping_cart (user_ID, product_ID, quantity) VALUES (v_user_id, v_product_id, FLOOR(1 + RAND() * 5));
            END IF;
            
            -- CREAMOS LA ORDEN FICTICIA
            INSERT INTO tb_orders (`key`, user_ID, total_products, total_cost, status_string) 
            VALUES (CONCAT('ORD-', v_user_id), v_user_id, 1, 100.00, 'Completed');
            SET v_order_id = LAST_INSERT_ID();
            
            SET v_payment_method = FLOOR(1 + RAND() * 3);
            INSERT INTO tb_payments (order_id, payment_method_id, amount, payment_status) VALUES (v_order_id, v_payment_method, FLOOR(100 + RAND() * 1000), 'Completed');
            
            SET i = i + 1;
        END WHILE;
        COMMIT;

    -- ESCENARIO 3: 7222 Usuarios (85% Activos, 15% Bajas)
    ELSEIF p_scenario = 3 THEN
        SET v_total = 7222;
        SET i = 0;
        START TRANSACTION;
        WHILE i < v_total DO
            SET v_full_name = fn_gen_us_name();
            SET v_email = CONCAT(REPLACE(LOWER(v_full_name), ' ', '.'), i, '@platform-test.com');
            SET v_country = 'US';
            SET v_birth_date = fn_gen_random_date(18, 70);
            
            IF RAND() <= 0.85 THEN
                SET v_deleted_at = NULL;
            ELSE
                SET v_deleted_at = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 100) DAY);
            END IF;
            
            INSERT INTO tb_users (email, nickname, password, deleted_at) VALUES (v_email, v_full_name, SHA2('Pass123', 256), v_deleted_at);
            SET v_user_id = LAST_INSERT_ID();
            INSERT INTO tb_people (user_ID, given_names, family_names, birth_date, country_code, deleted_at) VALUES (v_user_id, SUBSTRING_INDEX(v_full_name, ' ', 1), SUBSTRING_INDEX(v_full_name, ' ', -1), v_birth_date, v_country, v_deleted_at);
            
            IF v_deleted_at IS NULL THEN
                SET v_product_id = fn_get_random_active_product();
                IF v_product_id IS NOT NULL THEN
                    INSERT INTO tbd_shopping_cart (user_ID, product_ID, quantity) VALUES (v_user_id, v_product_id, FLOOR(1 + RAND() * 2));
                END IF;
                
                -- CREAMOS LA ORDEN FICTICIA
                INSERT INTO tb_orders (`key`, user_ID, total_products, total_cost, status_string) 
                VALUES (CONCAT('ORD-', v_user_id), v_user_id, 1, 100.00, 'Completed');
                SET v_order_id = LAST_INSERT_ID();
                
                SET v_payment_method = FLOOR(1 + RAND() * 3);
                INSERT INTO tb_payments (order_id, payment_method_id, amount, payment_status) VALUES (v_order_id, v_payment_method, FLOOR(100 + RAND() * 300), 'Completed');
            END IF;
            SET i = i + 1;
        END WHILE;
        COMMIT;
    END IF;

    SET autocommit = 1;
    SELECT CONCAT('Éxito: Se generaron ', v_total, ' usuarios en el escenario ', p_scenario) AS Resultado;
END$$

DELIMITER ;