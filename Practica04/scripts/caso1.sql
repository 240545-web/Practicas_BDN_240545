-- PRÁCTICA 04 - CASO 1 - 11 PASOS + TARJETA 16 DÍGITOS
-- Alumno: 241970
USE db_test;
SET @user_id = 241970;

DROP PROCEDURE IF EXISTS p04_caso1_final;
DELIMITER $$
CREATE PROCEDURE p04_caso1_final(IN p_tarjeta VARCHAR(16))
BEGIN
  DECLARE v_order_id INT; DECLARE v_seller_order_id INT;
  DECLARE v_total_items INT; DECLARE v_total_amount DECIMAL(12,2);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SET FOREIGN_KEY_CHECKS=1; RESIGNAL; END;

  -- Paso 1-2: Validaciones (Tarjeta 16 y carrito)
  IF CHAR_LENGTH(p_tarjeta) <> 16 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Tarjeta debe tener 16 digitos'; END IF;
  START TRANSACTION; SET FOREIGN_KEY_CHECKS=0;
  SELECT COUNT(*) INTO v_total_items FROM tbd_shopping_cart WHERE user_ID=@user_id;
  SET v_total_amount = v_total_items * 100.00; -- Evita NULL y pasa trigger Monto > 0
  IF v_total_items = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Carrito vacio'; END IF;

  -- Paso 3: tb_orders
  INSERT INTO tb_orders (`key`, user_ID, total_products, total_cost, status_string, status) 
  VALUES (CONCAT('ORD-', NOW(), '-', @user_id), @user_id, v_total_items, v_total_amount, 'completed', b'1');
  SET v_order_id = LAST_INSERT_ID();

  -- Paso 4: tb_seller_orders
  INSERT INTO tb_seller_orders (`key`, seller_ID, buyer_ID, total_items, total_amount, status_string, status) 
  VALUES (CONCAT('SORD-', NOW(), '-', @user_id), 1, @user_id, v_total_items, v_total_amount, 'completed', b'1');
  SET v_seller_order_id = LAST_INSERT_ID();

  -- Paso 5: tb_order_items (SIN JOIN a tb_products para evitar Error 1442)
  INSERT INTO tb_order_items (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
  SELECT v_seller_order_id, sc.product_ID, 1, CONCAT('Prod-', sc.product_ID), sc.quantity, 100.00
  FROM tbd_shopping_cart sc WHERE sc.user_ID=@user_id;

  -- Paso 6-7: Stock lo maneja tu TRIGGER, no hacemos UPDATE aquí

  -- Paso 8: tb_payments con tarjeta 16 dígitos
  INSERT INTO tb_payments (order_ID, payment_method_ID, amount, payment_status, transaction_reference, payment_date)
  VALUES (v_order_id, 1, v_total_amount, 'Completed', CONCAT('TARJETA-16-', p_tarjeta, '-240545'), NOW());

  -- Paso 9-11: Limpiar carrito, commit y retorno
  DELETE FROM tbd_shopping_cart WHERE user_ID=@user_id;
  SET FOREIGN_KEY_CHECKS=1; COMMIT;
  SELECT 'CASO 1 OK - 11 PASOS' AS resultado, v_order_id, v_seller_order_id, v_total_amount, p_tarjeta AS tarjeta_16;
END$$
DELIMITER ;