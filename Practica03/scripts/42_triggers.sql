USE db_test;

-- Limpiar triggers anteriores
DROP TRIGGER IF EXISTS trg_users_ai; DROP TRIGGER IF EXISTS trg_users_au; DROP TRIGGER IF EXISTS trg_users_ad;
DROP TRIGGER IF EXISTS trg_products_ai; DROP TRIGGER IF EXISTS trg_products_au; DROP TRIGGER IF EXISTS trg_products_ad;
DROP TRIGGER IF EXISTS trg_cats_ai; DROP TRIGGER IF EXISTS trg_cats_au; DROP TRIGGER IF EXISTS trg_cats_ad;
DROP TRIGGER IF EXISTS trg_sorders_ai; DROP TRIGGER IF EXISTS trg_sorders_au; DROP TRIGGER IF EXISTS trg_sorders_ad;
DROP TRIGGER IF EXISTS trg_users_bd; DROP TRIGGER IF EXISTS trg_products_bd; DROP TRIGGER IF EXISTS trg_cats_bd;
DROP TRIGGER IF EXISTS trg_users_pass_bi; DROP TRIGGER IF EXISTS trg_users_email_bi;
DROP TRIGGER IF EXISTS trg_products_price_bi; DROP TRIGGER IF EXISTS trg_products_stock_bu; DROP TRIGGER IF EXISTS trg_products_sku_bu; DROP TRIGGER IF EXISTS trg_products_sku_fmt_bi;
DROP TRIGGER IF EXISTS trg_cats_name_bi;
DROP TRIGGER IF EXISTS trg_sorders_diff_bi; DROP TRIGGER IF EXISTS trg_sorders_cancel_bu;
DROP TRIGGER IF EXISTS trg_oitems_qty_bi; DROP TRIGGER IF EXISTS trg_oitems_price_bi; DROP TRIGGER IF EXISTS trg_oitems_stock_bi; DROP TRIGGER IF EXISTS trg_oitems_stock_ai; DROP TRIGGER IF EXISTS trg_oitems_stock_ad; DROP TRIGGER IF EXISTS trg_oitems_order_bu;
DROP TRIGGER IF EXISTS trg_payments_bu; DROP TRIGGER IF EXISTS trg_payments_amt_bi; DROP TRIGGER IF EXISTS trg_payments_status_bi;
DROP TRIGGER IF EXISTS trg_odetails_qty_bi; DROP TRIGGER IF EXISTS trg_odetails_price_bi;
DROP TRIGGER IF EXISTS trg_offer_stock_bi; DROP TRIGGER IF EXISTS trg_offer_date_bi;
DROP TRIGGER IF EXISTS trg_cart_dup_bi; DROP TRIGGER IF EXISTS trg_cart_qty_bi;
DROP TRIGGER IF EXISTS trg_orders_total_bi; DROP TRIGGER IF EXISTS trg_pc_delete_bd; DROP TRIGGER IF EXISTS trg_wishlist_bi;

DELIMITER $$

-- ============================================================
-- PARTE 1: 12 TRIGGERS DE TRAZABILIDAD (AUDITORÍA)
-- ============================================================
CREATE TRIGGER trg_users_ai AFTER INSERT ON tb_users FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_users', 'Create', USER(), CONCAT('Nuevo usuario ID: ', NEW.ID)); END$$
CREATE TRIGGER trg_users_au AFTER UPDATE ON tb_users FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_users', 'Update', USER(), CONCAT('Usuario modificado ID: ', NEW.ID)); END$$
CREATE TRIGGER trg_users_ad AFTER DELETE ON tb_users FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_users', 'Delete', USER(), CONCAT('Usuario eliminado ID: ', OLD.ID)); END$$

CREATE TRIGGER trg_products_ai AFTER INSERT ON tb_products FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_products', 'Create', USER(), CONCAT('Nuevo producto SKU: ', NEW.SKU)); END$$
CREATE TRIGGER trg_products_au AFTER UPDATE ON tb_products FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_products', 'Update', USER(), CONCAT('Producto modificado SKU: ', NEW.SKU)); END$$
CREATE TRIGGER trg_products_ad AFTER DELETE ON tb_products FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_products', 'Delete', USER(), CONCAT('Producto eliminado SKU: ', OLD.SKU)); END$$

CREATE TRIGGER trg_cats_ai AFTER INSERT ON tb_categories FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_categories', 'Create', USER(), CONCAT('Nueva categoría: ', NEW.name)); END$$
CREATE TRIGGER trg_cats_au AFTER UPDATE ON tb_categories FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_categories', 'Update', USER(), CONCAT('Categoría modificada: ', NEW.name)); END$$
CREATE TRIGGER trg_cats_ad AFTER DELETE ON tb_categories FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_categories', 'Delete', USER(), CONCAT('Categoría eliminada: ', OLD.name)); END$$

CREATE TRIGGER trg_sorders_ai AFTER INSERT ON tb_seller_orders FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_seller_orders', 'Create', USER(), CONCAT('Orden creada Key: ', NEW.key)); END$$
CREATE TRIGGER trg_sorders_au AFTER UPDATE ON tb_seller_orders FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_seller_orders', 'Update', USER(), CONCAT('Orden actualizada ID: ', NEW.ID)); END$$
CREATE TRIGGER trg_sorders_ad AFTER DELETE ON tb_seller_orders FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_seller_orders', 'Delete', USER(), CONCAT('Orden eliminada Key: ', OLD.key)); END$$

-- ============================================================
-- PARTE 2: 3 TRIGGERS DE SOFT DELETE (BLOQUEO FÍSICO)
-- ============================================================
CREATE TRIGGER trg_users_bd BEFORE DELETE ON tb_users FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prohibido borrar usuarios físicamente.'; END$$
CREATE TRIGGER trg_products_bd BEFORE DELETE ON tb_products FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prohibido borrar productos físicamente.'; END$$
CREATE TRIGGER trg_cats_bd BEFORE DELETE ON tb_categories FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prohibido borrar categorías físicamente.'; END$$

-- ============================================================
-- PARTE 3: 27 TRIGGERS DE LÓGICA DE NEGOCIO
-- ============================================================
CREATE TRIGGER trg_users_pass_bi BEFORE INSERT ON tb_users FOR EACH ROW BEGIN IF LENGTH(NEW.password) < 8 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password muy corto'; END IF; END$$
CREATE TRIGGER trg_users_email_bi BEFORE INSERT ON tb_users FOR EACH ROW BEGIN IF NEW.email NOT LIKE '%@%.%' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email inválido'; END IF; END$$
CREATE TRIGGER trg_products_price_bi BEFORE INSERT ON tb_products FOR EACH ROW BEGIN IF NEW.current_price <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio debe ser mayor a 0'; END IF; END$$
CREATE TRIGGER trg_products_stock_bu BEFORE UPDATE ON tb_products FOR EACH ROW BEGIN IF NEW.current_stock < 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock no puede ser negativo'; END IF; END$$
CREATE TRIGGER trg_products_sku_bu BEFORE UPDATE ON tb_products FOR EACH ROW BEGIN IF NEW.SKU <> OLD.SKU THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SKU no se puede modificar'; END IF; END$$
CREATE TRIGGER trg_products_sku_fmt_bi BEFORE INSERT ON tb_products FOR EACH ROW BEGIN IF NEW.SKU NOT LIKE 'SKU-%' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SKU debe iniciar con SKU-'; END IF; END$$
CREATE TRIGGER trg_cats_name_bi BEFORE INSERT ON tb_categories FOR EACH ROW BEGIN IF NEW.name = '' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre no puede estar vacío'; END IF; END$$
CREATE TRIGGER trg_sorders_diff_bi BEFORE INSERT ON tb_seller_orders FOR EACH ROW BEGIN IF NEW.seller_ID = NEW.buyer_ID THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vendedor y comprador no pueden ser iguales'; END IF; END$$
CREATE TRIGGER trg_sorders_cancel_bu BEFORE UPDATE ON tb_seller_orders FOR EACH ROW BEGIN IF NEW.status_string = 'cancelled' AND OLD.status_string <> 'cancelled' THEN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_seller_orders', 'Update', USER(), 'Orden cancelada'); END IF; END$$
CREATE TRIGGER trg_oitems_qty_bi BEFORE INSERT ON tb_order_items FOR EACH ROW BEGIN IF NEW.quantity <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad debe ser > 0'; END IF; END$$
CREATE TRIGGER trg_oitems_price_bi BEFORE INSERT ON tb_order_items FOR EACH ROW BEGIN IF NEW.unit_price < 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio no puede ser negativo'; END IF; END$$
CREATE TRIGGER trg_oitems_stock_bi BEFORE INSERT ON tb_order_items FOR EACH ROW BEGIN DECLARE v_stock INT; SELECT current_stock INTO v_stock FROM tb_products WHERE ID = NEW.product_ID; IF NEW.quantity > v_stock THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente'; END IF; END$$
CREATE TRIGGER trg_oitems_stock_ai AFTER INSERT ON tb_order_items FOR EACH ROW BEGIN UPDATE tb_products SET current_stock = current_stock - NEW.quantity WHERE ID = NEW.product_ID; END$$
CREATE TRIGGER trg_oitems_stock_ad AFTER DELETE ON tb_order_items FOR EACH ROW BEGIN UPDATE tb_products SET current_stock = current_stock + OLD.quantity WHERE ID = OLD.product_ID; END$$
CREATE TRIGGER trg_oitems_order_bu BEFORE UPDATE ON tb_order_items FOR EACH ROW BEGIN IF NEW.seller_order_ID <> OLD.seller_order_ID THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cambiar la orden'; END IF; END$$
CREATE TRIGGER trg_payments_bu BEFORE UPDATE ON tb_payments FOR EACH ROW BEGIN IF OLD.payment_status = 'Completed' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pago ya completado no se modifica'; END IF; END$$
CREATE TRIGGER trg_payments_amt_bi BEFORE INSERT ON tb_payments FOR EACH ROW BEGIN IF NEW.amount <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Monto > 0 requerido'; END IF; END$$
CREATE TRIGGER trg_payments_status_bi BEFORE INSERT ON tb_payments FOR EACH ROW BEGIN IF NEW.payment_status NOT IN ('Pending', 'Completed', 'Failed', 'Refunded') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de pago inválido'; END IF; END$$
CREATE TRIGGER trg_odetails_qty_bi BEFORE INSERT ON tbd_order_details FOR EACH ROW BEGIN IF NEW.quantity <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad > 0 requerida'; END IF; END$$
CREATE TRIGGER trg_odetails_price_bi BEFORE INSERT ON tbd_order_details FOR EACH ROW BEGIN IF NEW.unit_price < 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio >= 0 requerido'; END IF; END$$
CREATE TRIGGER trg_offer_stock_bi BEFORE INSERT ON tbd_users_offer_products FOR EACH ROW BEGIN IF NEW.available_stock < 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock ofertado inválido'; END IF; END$$
CREATE TRIGGER trg_offer_date_bi BEFORE INSERT ON tbd_users_offer_products FOR EACH ROW BEGIN IF NEW.available_date < NOW() THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha de disponibilidad inválida'; END IF; END$$
CREATE TRIGGER trg_cart_dup_bi BEFORE INSERT ON tbd_shopping_cart FOR EACH ROW BEGIN DECLARE v_count INT; SELECT COUNT(*) INTO v_count FROM tbd_shopping_cart WHERE user_ID = NEW.user_ID AND product_ID = NEW.product_ID; IF v_count > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto ya en carrito'; END IF; END$$
CREATE TRIGGER trg_cart_qty_bi BEFORE INSERT ON tbd_shopping_cart FOR EACH ROW BEGIN IF NEW.quantity <= 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad > 0 requerida'; END IF; END$$
CREATE TRIGGER trg_orders_total_bi BEFORE INSERT ON tb_orders FOR EACH ROW BEGIN IF NEW.total_cost < 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Total >= 0 requerido'; END IF; END$$
CREATE TRIGGER trg_pc_delete_bd BEFORE DELETE ON tb_products_categories FOR EACH ROW BEGIN IF (SELECT COUNT(*) FROM tb_products WHERE category_id = OLD.category_ID) > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No borrar categoría con productos'; END IF; END$$
CREATE TRIGGER trg_wishlist_bi BEFORE INSERT ON tbd_wishlist FOR EACH ROW BEGIN IF NEW.product_ID IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto requerido'; END IF; END$$

DELIMITER ;

-- VERIFICACIÓN FINAL (Debe dar exactamente 42)
SELECT COUNT(*) AS Total_Triggers FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'db_test';