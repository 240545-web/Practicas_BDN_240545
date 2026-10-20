USE db_test;

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. TABLA PADRE: tb_seller_orders
-- ============================================================
DROP TABLE IF EXISTS tb_seller_orders;

CREATE TABLE tb_seller_orders (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `key` VARCHAR(40) NOT NULL,
    seller_ID INT NOT NULL,
    buyer_ID INT NOT NULL,
    status_string VARCHAR(50) NOT NULL DEFAULT 'pending',
    status BIT(1) NOT NULL DEFAULT b'1',
    total_items INT UNSIGNED NOT NULL DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    UNIQUE KEY uk_seller_orders_key (`key`),
    KEY fk_seller_orders_seller (seller_ID),
    KEY fk_seller_orders_buyer (buyer_ID),
    CONSTRAINT fk_seller_orders_seller
        FOREIGN KEY (seller_ID) REFERENCES tb_users (ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_seller_orders_buyer
        FOREIGN KEY (buyer_ID) REFERENCES tb_users (ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. TABLA: tb_order_items
-- ============================================================
DROP TABLE IF EXISTS tb_order_items;

CREATE TABLE tb_order_items (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    seller_order_ID INT UNSIGNED NOT NULL,
    product_ID INT UNSIGNED NOT NULL,
    provider_ID INT UNSIGNED NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    KEY fk_order_items_order (seller_order_ID),
    KEY fk_order_items_product (product_ID),
    KEY fk_order_items_provider (provider_ID),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (seller_order_ID) REFERENCES tb_seller_orders (ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_ID) REFERENCES tb_products (ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_items_provider
        FOREIGN KEY (provider_ID) REFERENCES tbd_users_offer_products (ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
SELECT '========== TABLAS CREADAS ==========' AS seccion;
SHOW TABLES LIKE 'tb_%order%';

SELECT '========== FKs DE tb_order_items ==========' AS seccion;
SELECT
    CONSTRAINT_NAME AS FK,
    COLUMN_NAME AS Columna,
    REFERENCED_TABLE_NAME AS Tabla_Ref,
    REFERENCED_COLUMN_NAME AS Col_Ref
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'db_test'
  AND TABLE_NAME = 'tb_order_items'
  AND REFERENCED_TABLE_NAME IS NOT NULL;