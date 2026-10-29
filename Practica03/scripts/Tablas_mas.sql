USE db_test;

-- Limpiamos las tablas que fallaron
DROP TABLE IF EXISTS tb_invoices;
DROP TABLE IF EXISTS tb_shipments;

-- 1. Facturas (Corregido a INT UNSIGNED)
CREATE TABLE IF NOT EXISTS tb_invoices (
    ID BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_ID INT UNSIGNED NOT NULL, -- <--- AQUÍ ESTABA EL ERROR (Era BIGINT)
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_ID) REFERENCES tb_seller_orders(ID) ON DELETE CASCADE
);

-- 2. Envíos (Corregido a INT UNSIGNED)
CREATE TABLE IF NOT EXISTS tb_shipments (
    ID BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_ID INT UNSIGNED NOT NULL, -- <--- AQUÍ ESTABA EL ERROR (Era BIGINT)
    carrier_ID BIGINT UNSIGNED NOT NULL,
    address_ID BIGINT UNSIGNED NOT NULL,
    tracking_number VARCHAR(100),
    status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (order_ID) REFERENCES tb_seller_orders(ID) ON DELETE CASCADE,
    FOREIGN KEY (carrier_ID) REFERENCES tb_carriers(ID),
    FOREIGN KEY (address_ID) REFERENCES tb_addresses(ID)
);

-- 3. Los 6 triggers de estas 2 tablas
DELIMITER $$

CREATE TRIGGER trg_invoices_ai AFTER INSERT ON tb_invoices FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_invoices', 'Create', USER(), 'Nueva factura'); END$$
CREATE TRIGGER trg_invoices_au AFTER UPDATE ON tb_invoices FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_invoices', 'Update', USER(), 'Factura actualizada'); END$$
CREATE TRIGGER trg_invoices_ad AFTER DELETE ON tb_invoices FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_invoices', 'Delete', USER(), 'Factura eliminada'); END$$

CREATE TRIGGER trg_shipments_ai AFTER INSERT ON tb_shipments FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_shipments', 'Create', USER(), 'Nuevo envío'); END$$
CREATE TRIGGER trg_shipments_au AFTER UPDATE ON tb_shipments FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_shipments', 'Update', USER(), 'Envío actualizado'); END$$
CREATE TRIGGER trg_shipments_ad AFTER DELETE ON tb_shipments FOR EACH ROW BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_shipments', 'Delete', USER(), 'Envío eliminado'); END$$

DELIMITER ;