USE db_test;

DELIMITER $$

-- 1. Triggers para tb_carts (3)
CREATE TRIGGER trg_carts_ai AFTER INSERT ON tb_carts FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_carts', 'Create', USER(), CONCAT('Carrito creado ID: ', NEW.ID)); END$$
CREATE TRIGGER trg_carts_au AFTER UPDATE ON tb_carts FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_carts', 'Update', USER(), CONCAT('Carrito modificado ID: ', NEW.ID)); END$$
CREATE TRIGGER trg_carts_ad AFTER DELETE ON tb_carts FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_carts', 'Delete', USER(), CONCAT('Carrito eliminado ID: ', OLD.ID)); END$$

-- 2. Triggers para tbd_shopping_cart (3)
CREATE TRIGGER trg_shopping_ai AFTER INSERT ON tbd_shopping_cart FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tbd_shopping_cart', 'Create', USER(), CONCAT('Producto agregado al carrito ID: ', NEW.user_ID)); END$$
CREATE TRIGGER trg_shopping_au AFTER UPDATE ON tbd_shopping_cart FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tbd_shopping_cart', 'Update', USER(), 'Cantidad modificada en carrito'); END$$
CREATE TRIGGER trg_shopping_ad AFTER DELETE ON tbd_shopping_cart FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tbd_shopping_cart', 'Delete', USER(), 'Producto eliminado del carrito'); END$$

-- 3. Triggers para tb_orders (3)
CREATE TRIGGER trg_orders_ai AFTER INSERT ON tb_orders FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_orders', 'Create', USER(), CONCAT('Orden generada ID: ', NEW.ID)); END$$
CREATE TRIGGER trg_orders_au AFTER UPDATE ON tb_orders FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_orders', 'Update', USER(), CONCAT('Orden modificada ID: ', NEW.ID)); END$$
CREATE TRIGGER trg_orders_ad AFTER DELETE ON tb_orders FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_orders', 'Delete', USER(), CONCAT('Orden eliminada ID: ', OLD.ID)); END$$

-- 4. Triggers para tbd_order_details (3)
CREATE TRIGGER trg_odetails_ai AFTER INSERT ON tbd_order_details FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tbd_order_details', 'Create', USER(), CONCAT('Detalle de orden creado ID: ', NEW.ID)); END$$
CREATE TRIGGER trg_odetails_au AFTER UPDATE ON tbd_order_details FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tbd_order_details', 'Update', USER(), CONCAT('Detalle de orden modificado ID: ', NEW.ID)); END$$
CREATE TRIGGER trg_odetails_ad AFTER DELETE ON tbd_order_details FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tbd_order_details', 'Delete', USER(), CONCAT('Detalle de orden eliminado ID: ', OLD.ID)); END$$

DELIMITER ;

-- Verificación final
SELECT COUNT(*) AS total_triggers FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'db_test';