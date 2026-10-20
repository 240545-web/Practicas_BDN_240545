-- ============================================================
-- TABLAS RESTANTES - Modelo Físico completo db_test
-- Práctica 03 - Emigdio Aguirre 240545
-- ============================================================

USE db_test;

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. tb_orders (PEDIDOS Y PAGOS)
-- ============================================================
DROP TABLE IF EXISTS tb_orders;

CREATE TABLE tb_orders (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `key` VARCHAR(40) NOT NULL,
    user_ID INT NOT NULL,
    total_products INT UNSIGNED NOT NULL DEFAULT 0,
    total_cost DECIMAL(10,3) NOT NULL DEFAULT 0.000,
    status_string VARCHAR(50) NOT NULL,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    UNIQUE KEY uk_orders_key (`key`),
    KEY fk_orders_user (user_ID),
    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_ID) REFERENCES tb_users (ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. tb_carts (CARRITOS)
-- ============================================================
DROP TABLE IF EXISTS tb_carts;

CREATE TABLE tb_carts (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_ID INT NOT NULL,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    KEY fk_carts_user (user_ID),
    CONSTRAINT fk_carts_user
        FOREIGN KEY (user_ID) REFERENCES tb_users (ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. tbc_payment_methods (MÉTODOS DE PAGO)
-- ============================================================
DROP TABLE IF EXISTS tbc_payment_methods;

CREATE TABLE tbc_payment_methods (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    UNIQUE KEY uk_payment_methods_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. tb_payments (PAGOS)
-- ============================================================
DROP TABLE IF EXISTS tb_payments;

CREATE TABLE tb_payments (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_ID INT UNSIGNED NOT NULL,
    payment_method_ID INT UNSIGNED NOT NULL,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    payment_status ENUM('Pending','Completed','Failed','Refunded') NOT NULL DEFAULT 'Pending',
    transaction_reference VARCHAR(150) NULL,
    payment_date DATETIME NULL,
    PRIMARY KEY (ID),
    KEY fk_payments_order (order_ID),
    KEY fk_payments_method (payment_method_ID),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_ID) REFERENCES tb_orders (ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payments_method
        FOREIGN KEY (payment_method_ID) REFERENCES tbc_payment_methods (ID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. tbd_order_details (DETALLES DE PEDIDO)
-- ============================================================
DROP TABLE IF EXISTS tbd_order_details;

CREATE TABLE tbd_order_details (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_ID INT UNSIGNED NOT NULL,
    product_ID INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    KEY fk_order_details_order (order_ID),
    KEY fk_order_details_product (product_ID),
    CONSTRAINT fk_order_details_order
        FOREIGN KEY (order_ID) REFERENCES tb_orders (ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_order_details_product
        FOREIGN KEY (product_ID) REFERENCES tb_products (ID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. tbd_shopping_cart (ITEMS DEL CARRITO)
-- ============================================================
DROP TABLE IF EXISTS tbd_shopping_cart;

CREATE TABLE tbd_shopping_cart (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_ID INT NOT NULL,
    offer_ID INT UNSIGNED NULL,
    product_ID INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    KEY fk_shopping_cart_user (user_ID),
    KEY fk_shopping_cart_product (product_ID),
    CONSTRAINT fk_shopping_cart_user
        FOREIGN KEY (user_ID) REFERENCES tb_users (ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_shopping_cart_product
        FOREIGN KEY (product_ID) REFERENCES tb_products (ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. tb_products_categories (RELACIÓN PRODUCTO-CATEGORÍA)
-- ============================================================
DROP TABLE IF EXISTS tb_products_categories;

CREATE TABLE tb_products_categories (
    category_ID INT UNSIGNED NOT NULL,
    product_ID INT UNSIGNED NOT NULL,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (category_ID, product_ID),
    KEY fk_pc_product (product_ID),
    CONSTRAINT fk_pc_category
        FOREIGN KEY (category_ID) REFERENCES tbc_categories (ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pc_product
        FOREIGN KEY (product_ID) REFERENCES tb_products (ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. tbd_users_offer_products (OFERTAS DE USUARIOS)
-- ============================================================
DROP TABLE IF EXISTS tbd_users_offer_products;

CREATE TABLE tbd_users_offer_products (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_ID INT NOT NULL,
    product_ID INT UNSIGNED NOT NULL,
    available_stock INT UNSIGNED NOT NULL DEFAULT 0,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    available_date DATETIME NOT NULL,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    KEY fk_offer_user (user_ID),
    KEY fk_offer_product (product_ID),
    CONSTRAINT fk_offer_user
        FOREIGN KEY (user_ID) REFERENCES tb_users (ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_offer_product
        FOREIGN KEY (product_ID) REFERENCES tb_products (ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. tbd_wishlist (LISTA DE DESEOS)
-- ============================================================
DROP TABLE IF EXISTS tbd_wishlist;

CREATE TABLE tbd_wishlist (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_ID INT NOT NULL,
    product_ID INT UNSIGNED NOT NULL,
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    UNIQUE KEY uk_wishlist_user_product (user_ID, product_ID),
    KEY fk_wishlist_product (product_ID),
    CONSTRAINT fk_wishlist_user
        FOREIGN KEY (user_ID) REFERENCES tb_users (ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_wishlist_product
        FOREIGN KEY (product_ID) REFERENCES tb_products (ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. tbd_users_wishlist_products (RELACIÓN USERS-WISHLIST)
-- ============================================================
DROP TABLE IF EXISTS tbd_users_wishlist_products;

CREATE TABLE tbd_users_wishlist_products (
    user_ID INT NOT NULL,
    product_ID INT UNSIGNED NOT NULL,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_ID, product_ID),
    KEY fk_uwp_product (product_ID),
    CONSTRAINT fk_uwp_user
        FOREIGN KEY (user_ID) REFERENCES tb_users (ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_uwp_product
        FOREIGN KEY (product_ID) REFERENCES tb_products (ID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
SELECT '========== TODAS LAS TABLAS ==========' AS seccion;

SELECT
    TABLE_NAME AS Tabla,
    TABLE_ROWS AS Filas,
    CREATE_TIME AS Creada
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'db_test'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

SELECT '========== LLAVES FORÁNEAS ==========' AS seccion;

SELECT
    TABLE_NAME AS Tabla,
    CONSTRAINT_NAME AS FK,
    COLUMN_NAME AS Columna,
    REFERENCED_TABLE_NAME AS Referencia,
    REFERENCED_COLUMN_NAME AS Col_Ref
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'db_test'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

SELECT '========== RESUMEN ==========' AS seccion;

SELECT
    COUNT(DISTINCT TABLE_NAME) AS Total_Tablas,
    (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE
     WHERE TABLE_SCHEMA = 'db_test' AND REFERENCED_TABLE_NAME IS NOT NULL) AS Total_FKs
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'db_test' AND TABLE_TYPE = 'BASE TABLE';