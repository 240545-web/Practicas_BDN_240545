-- Fase 3: MySQL 8.0.16+. Solo instala rutinas; no genera usuarios al cargar.
USE db_test_ecosystem;
SET NAMES utf8mb4;
DELIMITER $$

DROP FUNCTION IF EXISTS fn_gen_us_name$$
CREATE FUNCTION fn_gen_us_name() RETURNS VARCHAR(150) CHARACTER SET utf8mb4
NOT DETERMINISTIC NO SQL SQL SECURITY INVOKER
BEGIN
    RETURN CONCAT(ELT(1 + FLOOR(RAND()*12), 'James', 'Olivia', 'William', 'Emma', 'Benjamin', 'Charlotte', 'Henry', 'Amelia', 'Michael', 'Sophia', 'Daniel', 'Isabella'), '|', ELT(1 + FLOOR(RAND()*12), 'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Miller', 'Davis', 'Wilson', 'Anderson', 'Taylor', 'Thomas', 'Moore'));
END$$

DROP FUNCTION IF EXISTS fn_gen_latam_name$$
CREATE FUNCTION fn_gen_latam_name() RETURNS VARCHAR(150) CHARACTER SET utf8mb4
NOT DETERMINISTIC NO SQL SQL SECURITY INVOKER
BEGIN
    RETURN CONCAT(ELT(1 + FLOOR(RAND()*12), 'Santiago', 'Valentina', 'Mateo', 'Camila', 'Sebastián', 'Mariana', 'Diego', 'Lucía', 'Alejandro', 'Daniela', 'Nicolás', 'Gabriela'), '|', ELT(1 + FLOOR(RAND()*12), 'García', 'Rodríguez', 'Martínez', 'Hernández', 'López', 'González', 'Pérez', 'Sánchez', 'Ramírez', 'Torres', 'Flores', 'Rivera'));
END$$

DROP FUNCTION IF EXISTS fn_gen_random_date$$
CREATE FUNCTION fn_gen_random_date(min_age INT, max_age INT) RETURNS DATE
NOT DETERMINISTIC NO SQL SQL SECURITY INVOKER
BEGIN
    DECLARE oldest DATE;
    DECLARE youngest DATE;
    DECLARE born DATE;
    DECLARE years_back INT;
    DECLARE age_years INT;
    IF min_age IS NULL OR max_age IS NULL OR min_age < 0
       OR max_age < min_age OR max_age > 120 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Edades inválidas.';
    END IF;
    SET years_back = max_age + 1;
    SET oldest = DATE_ADD(DATE_SUB(CURRENT_DATE, INTERVAL years_back YEAR), INTERVAL 1 DAY);
    SET youngest = DATE_SUB(CURRENT_DATE, INTERVAL min_age YEAR);
    SET born = DATE_ADD(oldest, INTERVAL FLOOR(RAND()*(DATEDIFF(youngest,oldest)+1)) DAY);
    SET age_years = TIMESTAMPDIFF(YEAR,born,CURRENT_DATE);
    WHILE age_years < min_age OR age_years > max_age DO
        SET born = DATE_ADD(oldest, INTERVAL FLOOR(RAND()*(DATEDIFF(youngest,oldest)+1)) DAY);
        SET age_years = TIMESTAMPDIFF(YEAR,born,CURRENT_DATE);
    END WHILE;
    RETURN born;
END$$

DROP FUNCTION IF EXISTS fn_get_random_active_product$$
CREATE FUNCTION fn_get_random_active_product() RETURNS BIGINT
NOT DETERMINISTIC READS SQL DATA SQL SECURITY INVOKER
BEGIN
    DECLARE chosen BIGINT DEFAULT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET chosen = NULL;
    SELECT id INTO chosen FROM tb_products
    WHERE deleted_at IS NULL AND current_stock > 0
    ORDER BY RAND() LIMIT 1 FOR UPDATE;
    IF chosen IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay productos activos con existencias.';
    END IF;
    RETURN chosen;
END$$

-- Responsabilidad: crear cuenta y ficha personal; no controlar transacciones.
DROP PROCEDURE IF EXISTS sp_create_user_person$$
CREATE PROCEDURE sp_create_user_person(
    IN p_name VARCHAR(150), IN p_country CHAR(2),
    IN p_birth DATE, IN p_deleted DATETIME, OUT p_user_id BIGINT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE token CHAR(32);
    SET token = REPLACE(UUID(),'-','');
    INSERT INTO tb_users(email,nickname,password,deleted_at)
    VALUES (CONCAT('mass_',token,'@example.test'),CONCAT('gen_',token),
            SHA2(CONCAT('Synthetic-',UUID()),256),p_deleted);
    SET p_user_id = LAST_INSERT_ID();
    INSERT INTO tb_people(user_id,given_names,family_names,birth_date,country_code,deleted_at)
    VALUES(p_user_id,SUBSTRING_INDEX(p_name,'|',1),SUBSTRING_INDEX(p_name,'|',-1),
           p_birth,p_country,p_deleted);
END$$

-- Responsabilidad: simular una compra coherente con sus FK y reservar stock.
-- No invocar directamente fuera de una transacción.
DROP PROCEDURE IF EXISTS sp_assign_purchase$$
CREATE PROCEDURE sp_assign_purchase(IN p_user_id BIGINT)
SQL SECURITY INVOKER
BEGIN
    DECLARE product_id_selected BIGINT;
    DECLARE cart_created BIGINT;
    DECLARE order_created BIGINT;
    DECLARE price_selected DECIMAL(12,2);
    DECLARE name_selected VARCHAR(250);
    DECLARE method_selected BIGINT;
    IF NOT EXISTS (SELECT 1 FROM tb_users WHERE id=p_user_id AND deleted_at IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La compra requiere un usuario activo.';
    END IF;
    SET product_id_selected = fn_get_random_active_product();
    SELECT current_price,name INTO price_selected,name_selected
    FROM tb_products WHERE id=product_id_selected FOR UPDATE;

    INSERT INTO tb_carts(user_id,status) VALUES(p_user_id,'checked_out');
    SET cart_created = LAST_INSERT_ID();
    INSERT INTO tbd_shopping_cart(cart_id,user_id,product_id,quantity)
    VALUES(cart_created,p_user_id,product_id_selected,1);
    INSERT INTO tb_orders(user_id,cart_id,status,total_amount)
    VALUES(p_user_id,cart_created,'paid',price_selected);
    SET order_created = LAST_INSERT_ID();
    INSERT INTO tb_order_items(order_id,product_id,product_name,quantity,unit_price)
    VALUES(order_created,product_id_selected,name_selected,1,price_selected);
    SET method_selected = 1 + FLOOR(RAND()*3);
    INSERT INTO tb_payments(order_id,payment_method_id,amount,payment_status)
    VALUES(order_created,method_selected,price_selected,'Completed');
    UPDATE tb_products SET current_stock=current_stock-1
    WHERE id=product_id_selected AND deleted_at IS NULL AND current_stock>0;
    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo descontar inventario.';
    END IF;
END$$

-- Responsabilidad: coordinar escenario y transacción de todo el lote.
-- Ejecutar CALL sin una transacción previa abierta por el cliente MySQL.
DROP PROCEDURE IF EXISTS sp_massive_user_generation$$
CREATE PROCEDURE sp_massive_user_generation(IN p_scenario INT)
SQL SECURITY INVOKER
BEGIN
    DECLARE total_count INT;
    DECLARE counter INT DEFAULT 0;
    DECLARE active_count INT DEFAULT 0;
    DECLARE created_user BIGINT;
    DECLARE generated_name VARCHAR(150);
    DECLARE generated_country CHAR(2);
    DECLARE generated_birth DATE;
    DECLARE deleted_time DATETIME;
    DECLARE is_active BOOLEAN;
    DECLARE in_tx BOOLEAN DEFAULT FALSE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF in_tx THEN ROLLBACK; END IF;
        RESIGNAL;
    END;
    IF p_scenario IS NULL OR p_scenario NOT IN (1,2,3) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Escenario válido: 1, 2 o 3.';
    END IF;
    SET total_count = CASE p_scenario WHEN 1 THEN 1000 WHEN 2 THEN 2000 ELSE 7222 END;
    START TRANSACTION;
    SET in_tx = TRUE;
    IF (SELECT COUNT(*) FROM tbc_payment_methods WHERE id IN(1,2,3)) <> 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Faltan métodos de pago 1, 2 o 3.';
    END IF;
    IF (SELECT COUNT(*) FROM tbc_countries WHERE code IN('US','MX','CO','AR','CL','PE','EC','CR','UY')) <> 9 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ejecute primero las semillas de países.';
    END IF;
    WHILE counter < total_count DO
        IF p_scenario = 1 THEN
            SET generated_name = fn_gen_us_name();
            SET generated_country = 'US';
        ELSE
            SET generated_name = fn_gen_latam_name();
            SET generated_country = ELT(1+FLOOR(RAND()*8),'MX','CO','AR','CL','PE','EC','CR','UY');
        END IF;
        SET generated_birth = fn_gen_random_date(18,IF(p_scenario=2,30,80));
        SET is_active = TRUE;
        SET deleted_time = NULL;
        IF p_scenario = 3 THEN
            SET is_active = (RAND() <= 0.85);
            IF NOT is_active THEN SET deleted_time = CURRENT_TIMESTAMP; END IF;
        END IF;
        CALL sp_create_user_person(generated_name,generated_country,generated_birth,deleted_time,created_user);
        IF is_active THEN
            CALL sp_assign_purchase(created_user);
            SET active_count = active_count+1;
        END IF;
        SET counter = counter+1;
    END WHILE;
    COMMIT;
    SET in_tx = FALSE;
    SELECT p_scenario AS scenario,total_count AS users_created,
           active_count AS active_users,total_count-active_count AS deleted_users,
           active_count AS carts_orders_payments_created;
END$$

DELIMITER ;
-- CALL db_test_ecosystem.sp_massive_user_generation(1);
-- CALL db_test_ecosystem.sp_massive_user_generation(2);
-- CALL db_test_ecosystem.sp_massive_user_generation(3);
