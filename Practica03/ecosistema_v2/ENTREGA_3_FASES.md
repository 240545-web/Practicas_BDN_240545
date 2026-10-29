# Ecosistema e-commerce — entrega en tres fases

**Diseño nuevo; no es una migración del esquema anterior. No se ha ejecutado SQL.** MySQL requiere 8.0.16+ para imponer CHECK; PostgreSQL requiere 16+. Se conserva la grafía de `SKU`; los identificadores de fila son BIGINT.

Las variantes son alternativas: no ejecutar el bloque SQL combinado de principio a fin. Los archivos `02_mysql.sql`, `02_postgresql.sql`, `03_mysql.sql` y `03_postgresql.sql` contienen las variantes ejecutables por separado. MySQL usa la base nueva `db_test_ecosystem`; PostgreSQL usa el esquema nuevo `ecommerce` en la base elegida por el cliente. El DDL se detiene si una tabla ya existe para evitar mezclar diseños incompatibles. No cambia Docker ni sus puertos.

## Bloque 1 — ERD

```mermaid
erDiagram
    %% Seguridad
    tb_users {
        BIGINT id PK
        VARCHAR(254) email
        VARCHAR(100) nickname
        VARCHAR(255) password
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_roles {
        BIGINT id PK
        VARCHAR(80) name
        TIMESTAMP created_at
    }
    tb_user_roles {
        BIGINT id PK
        BIGINT user_id FK
        BIGINT role_id FK
        TIMESTAMP created_at
    }
    tb_permissions {
        BIGINT id PK
        VARCHAR(100) code
        TEXT description
        TIMESTAMP created_at
    }
    tb_role_permissions {
        BIGINT id PK
        BIGINT role_id FK
        BIGINT permission_id FK
        TIMESTAMP created_at
    }
    tb_logs {
        BIGINT id PK
        VARCHAR(100) table_name
        BIGINT entity_id
        VARCHAR(10) operation
        VARCHAR(288) db_actor
        JSON old_data
        JSON new_data
        TIMESTAMP created_at
    }
    %% Catálogo
    tb_products {
        BIGINT id PK
        VARCHAR(50) SKU
        VARCHAR(250) name
        TEXT description
        DECIMAL(12,2) current_price
        INT current_stock
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_categories {
        BIGINT id PK
        VARCHAR(150) name
        TEXT description
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_product_categories {
        BIGINT id PK
        BIGINT product_id FK
        BIGINT category_id FK
        TIMESTAMP created_at
    }
    tb_tags {
        BIGINT id PK
        VARCHAR(80) name
        TIMESTAMP created_at
    }
    tb_product_tags {
        BIGINT id PK
        BIGINT product_id FK
        BIGINT tag_id FK
        TIMESTAMP created_at
    }
    tb_reviews {
        BIGINT id PK
        BIGINT user_id FK
        BIGINT product_id FK
        INT rating
        TEXT comment
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    %% Clientes y ubicación
    tb_people {
        BIGINT id PK
        BIGINT user_id FK
        VARCHAR(150) given_names
        VARCHAR(150) family_names
        DATE birth_date
        CHAR(2) country_code FK
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_addresses {
        BIGINT id PK
        BIGINT user_id FK
        CHAR(2) country_code FK
        BIGINT state_id FK
        VARCHAR(120) city
        VARCHAR(250) street
        VARCHAR(20) postal_code
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tbc_countries {
        BIGINT id PK
        CHAR(2) code
        VARCHAR(100) name
        TIMESTAMP created_at
    }
    tbc_states {
        BIGINT id PK
        CHAR(2) country_code FK
        VARCHAR(100) name
        TIMESTAMP created_at
    }
    %% Compras
    tb_carts {
        BIGINT id PK
        BIGINT user_id FK
        VARCHAR(20) status
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tbd_shopping_cart {
        BIGINT id PK
        BIGINT cart_id FK
        BIGINT user_id FK
        BIGINT product_id FK
        INT quantity
        TIMESTAMP created_at
    }
    tb_orders {
        BIGINT id PK
        BIGINT user_id FK
        BIGINT cart_id FK
        VARCHAR(20) status
        DECIMAL(12,2) total_amount
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_order_items {
        BIGINT id PK
        BIGINT order_id FK
        BIGINT product_id FK
        VARCHAR(250) product_name
        INT quantity
        DECIMAL(12,2) unit_price
        DECIMAL(12,2) subtotal
        TIMESTAMP created_at
    }
    tb_wishlists {
        BIGINT id PK
        BIGINT user_id FK
        BIGINT product_id FK
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    %% Pagos y envíos
    tb_payments {
        BIGINT id PK
        BIGINT order_id FK
        BIGINT payment_method_id FK
        DECIMAL(12,2) amount
        VARCHAR(20) payment_status
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tbc_payment_methods {
        BIGINT id PK
        VARCHAR(40) code
        VARCHAR(100) name
        TIMESTAMP created_at
    }
    tb_shipments {
        BIGINT id PK
        BIGINT order_id FK
        BIGINT carrier_id FK
        BIGINT address_id FK
        VARCHAR(150) tracking_code
        VARCHAR(20) status
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_carriers {
        BIGINT id PK
        VARCHAR(150) name
        TIMESTAMP created_at
    }
    tb_invoices {
        BIGINT id PK
        BIGINT order_id FK
        VARCHAR(80) invoice_number
        DECIMAL(12,2) total_amount
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_users ||--o{ tb_user_roles : "user_id"
    tb_roles ||--o{ tb_user_roles : "role_id"
    tb_roles ||--o{ tb_role_permissions : "role_id"
    tb_permissions ||--o{ tb_role_permissions : "permission_id"
    tb_products ||--o{ tb_product_categories : "product_id"
    tb_categories ||--o{ tb_product_categories : "category_id"
    tb_products ||--o{ tb_product_tags : "product_id"
    tb_tags ||--o{ tb_product_tags : "tag_id"
    tb_users ||--o{ tb_reviews : "user_id"
    tb_products ||--o{ tb_reviews : "product_id"
    tbc_countries ||--o{ tbc_states : "country_code"
    tb_users ||--o| tb_people : "user_id"
    tbc_countries ||--o{ tb_people : "country_code"
    tb_users ||--o{ tb_addresses : "user_id"
    tbc_countries ||--o{ tb_addresses : "country_code"
    tbc_states |o--o{ tb_addresses : "state_id, country_code"
    tb_users ||--o{ tb_carts : "user_id"
    tb_carts ||--o{ tbd_shopping_cart : "cart_id, user_id"
    tb_users ||--o{ tbd_shopping_cart : "user_id"
    tb_products ||--o{ tbd_shopping_cart : "product_id"
    tb_users ||--o{ tb_orders : "user_id"
    tb_carts |o--o| tb_orders : "cart_id, user_id"
    tb_orders ||--o{ tb_order_items : "order_id"
    tb_products ||--o{ tb_order_items : "product_id"
    tb_users ||--o{ tb_wishlists : "user_id"
    tb_products ||--o{ tb_wishlists : "product_id"
    tb_orders ||--o{ tb_payments : "order_id"
    tbc_payment_methods ||--o{ tb_payments : "payment_method_id"
    tb_orders ||--o{ tb_shipments : "order_id"
    tb_carriers ||--o{ tb_shipments : "carrier_id"
    tb_addresses ||--o{ tb_shipments : "address_id"
    tb_orders ||--o| tb_invoices : "order_id"
```

## Bloque 2 — Tablas y exactamente 72 triggers por motor

```sql
-- ============================================================
-- VARIANTE MYSQL: ejecutar por separado.
-- ============================================================
-- Fase 2: 26 tablas y exactamente 72 triggers.
-- Nuevo diseño: ejecutar solo en el espacio nuevo indicado; no es una migración.
-- Sin DROP TABLE, sin modificaciones del Docker o de los datos anteriores.
CREATE DATABASE IF NOT EXISTS db_test_ecosystem CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs;
USE db_test_ecosystem;
SET NAMES utf8mb4;

CREATE TABLE tb_users (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(254) NOT NULL UNIQUE,
    `nickname` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL
) ENGINE=InnoDB;

CREATE TABLE tb_roles (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(80) NOT NULL UNIQUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE tb_user_roles (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `role_id` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (role_id) REFERENCES tb_roles (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_user_roles_1 ON tb_user_roles (user_id);
CREATE INDEX ix_tb_user_roles_2 ON tb_user_roles (role_id);

CREATE TABLE tb_permissions (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(100) NOT NULL UNIQUE,
    `description` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE tb_role_permissions (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `role_id` BIGINT NOT NULL,
    `permission_id` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES tb_roles (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES tb_permissions (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_role_permissions_1 ON tb_role_permissions (role_id);
CREATE INDEX ix_tb_role_permissions_2 ON tb_role_permissions (permission_id);

CREATE TABLE tb_categories (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL UNIQUE,
    `description` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL
) ENGINE=InnoDB;

CREATE TABLE tb_products (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `SKU` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(250) NOT NULL,
    `description` TEXT NULL,
    `current_price` DECIMAL(12,2) NOT NULL CHECK (current_price > 0),
    `current_stock` INT NOT NULL DEFAULT 0 CHECK (current_stock >= 0),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL
) ENGINE=InnoDB;

CREATE TABLE tb_product_categories (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `product_id` BIGINT NOT NULL,
    `category_id` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES tb_categories (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_product_categories_1 ON tb_product_categories (product_id);
CREATE INDEX ix_tb_product_categories_2 ON tb_product_categories (category_id);

CREATE TABLE tb_tags (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(80) NOT NULL UNIQUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE tb_product_tags (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `product_id` BIGINT NOT NULL,
    `tag_id` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, tag_id),
    FOREIGN KEY (product_id) REFERENCES tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tb_tags (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_product_tags_1 ON tb_product_tags (product_id);
CREATE INDEX ix_tb_product_tags_2 ON tb_product_tags (tag_id);

CREATE TABLE tb_reviews (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `product_id` BIGINT NOT NULL,
    `rating` INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    `comment` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    UNIQUE (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_reviews_1 ON tb_reviews (user_id);
CREATE INDEX ix_tb_reviews_2 ON tb_reviews (product_id);

CREATE TABLE tbc_countries (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `code` CHAR(2) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL UNIQUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE tbc_states (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `country_code` CHAR(2) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (country_code, name),
    UNIQUE (id, country_code),
    FOREIGN KEY (country_code) REFERENCES tbc_countries (code) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tbc_states_1 ON tbc_states (country_code);

CREATE TABLE tb_people (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL UNIQUE,
    `given_names` VARCHAR(150) NOT NULL,
    `family_names` VARCHAR(150) NOT NULL,
    `birth_date` DATE NOT NULL,
    `country_code` CHAR(2) NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (country_code) REFERENCES tbc_countries (code) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_people_1 ON tb_people (user_id);
CREATE INDEX ix_tb_people_2 ON tb_people (country_code);

CREATE TABLE tb_addresses (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `country_code` CHAR(2) NOT NULL,
    `state_id` BIGINT NULL,
    `city` VARCHAR(120) NOT NULL,
    `street` VARCHAR(250) NOT NULL,
    `postal_code` VARCHAR(20) NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (country_code) REFERENCES tbc_countries (code) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (state_id, country_code) REFERENCES tbc_states (id, country_code) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_addresses_1 ON tb_addresses (user_id);
CREATE INDEX ix_tb_addresses_2 ON tb_addresses (country_code);
CREATE INDEX ix_tb_addresses_3 ON tb_addresses (state_id, country_code);

CREATE TABLE tb_carts (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active','checked_out','abandoned')),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    UNIQUE (id, user_id),
    FOREIGN KEY (user_id) REFERENCES tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_carts_1 ON tb_carts (user_id);

CREATE TABLE tbd_shopping_cart (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `cart_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `product_id` BIGINT NOT NULL,
    `quantity` INT NOT NULL CHECK (quantity > 0),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (cart_id, product_id),
    FOREIGN KEY (cart_id, user_id) REFERENCES tb_carts (id, user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tbd_shopping_cart_1 ON tbd_shopping_cart (cart_id, user_id);
CREATE INDEX ix_tbd_shopping_cart_2 ON tbd_shopping_cart (user_id);
CREATE INDEX ix_tbd_shopping_cart_3 ON tbd_shopping_cart (product_id);

CREATE TABLE tb_orders (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `cart_id` BIGINT NULL UNIQUE,
    `status` VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','paid','cancelled','shipped','delivered')),
    `total_amount` DECIMAL(12,2) NOT NULL CHECK (total_amount > 0),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    UNIQUE (id, user_id),
    FOREIGN KEY (user_id) REFERENCES tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (cart_id, user_id) REFERENCES tb_carts (id, user_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_orders_1 ON tb_orders (user_id);
CREATE INDEX ix_tb_orders_2 ON tb_orders (cart_id, user_id);

CREATE TABLE tb_order_items (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `product_id` BIGINT NOT NULL,
    `product_name` VARCHAR(250) NOT NULL,
    `quantity` INT NOT NULL CHECK (quantity > 0),
    `unit_price` DECIMAL(12,2) NOT NULL CHECK (unit_price > 0),
    `subtotal` DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES tb_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_order_items_1 ON tb_order_items (order_id);
CREATE INDEX ix_tb_order_items_2 ON tb_order_items (product_id);

CREATE TABLE tb_wishlists (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `product_id` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    UNIQUE (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_wishlists_1 ON tb_wishlists (user_id);
CREATE INDEX ix_tb_wishlists_2 ON tb_wishlists (product_id);

CREATE TABLE tbc_payment_methods (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(40) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL UNIQUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE tb_payments (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `payment_method_id` BIGINT NOT NULL,
    `amount` DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    `payment_status` VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (payment_status IN ('Pending','Completed','Failed','Refunded')),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    FOREIGN KEY (order_id) REFERENCES tb_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES tbc_payment_methods (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_payments_1 ON tb_payments (order_id);
CREATE INDEX ix_tb_payments_2 ON tb_payments (payment_method_id);

CREATE TABLE tb_carriers (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL UNIQUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE tb_shipments (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `carrier_id` BIGINT NOT NULL,
    `address_id` BIGINT NOT NULL,
    `tracking_code` VARCHAR(150) NOT NULL UNIQUE,
    `status` VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','in_transit','delivered','returned')),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    FOREIGN KEY (order_id) REFERENCES tb_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (carrier_id) REFERENCES tb_carriers (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (address_id) REFERENCES tb_addresses (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_shipments_1 ON tb_shipments (order_id);
CREATE INDEX ix_tb_shipments_2 ON tb_shipments (carrier_id);
CREATE INDEX ix_tb_shipments_3 ON tb_shipments (address_id);

CREATE TABLE tb_invoices (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL UNIQUE,
    `invoice_number` VARCHAR(80) NOT NULL UNIQUE,
    `total_amount` DECIMAL(12,2) NOT NULL CHECK (total_amount > 0),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    FOREIGN KEY (order_id) REFERENCES tb_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX ix_tb_invoices_1 ON tb_invoices (order_id);

CREATE TABLE tb_logs (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `table_name` VARCHAR(100) NOT NULL,
    `entity_id` BIGINT NOT NULL,
    `operation` VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT','UPDATE','DELETE')),
    `db_actor` VARCHAR(288) NOT NULL,
    `old_data` JSON NULL,
    `new_data` JSON NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

DELIMITER $$

CREATE TRIGGER trg_tb_users_ai AFTER INSERT ON tb_users FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_users', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'email', NEW.`email`, 'nickname', NEW.`nickname`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_users_au AFTER UPDATE ON tb_users FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_users', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'email', OLD.`email`, 'nickname', OLD.`nickname`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'email', NEW.`email`, 'nickname', NEW.`nickname`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_users_ad AFTER DELETE ON tb_users FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_users', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'email', OLD.`email`, 'nickname', OLD.`nickname`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_users_bi BEFORE INSERT ON tb_users FOR EACH ROW
BEGIN
    IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email inválido';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.nickname)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nickname vacío';
    END IF;
    IF CHAR_LENGTH(NEW.password) < 32 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hash de contraseña inválido';
    END IF;
END$$

CREATE TRIGGER trg_tb_users_bu BEFORE UPDATE ON tb_users FOR EACH ROW
BEGIN
    IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email inválido';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.nickname)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nickname vacío';
    END IF;
    IF CHAR_LENGTH(NEW.password) < 32 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hash de contraseña inválido';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_users_bd BEFORE DELETE ON tb_users FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_users; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_categories_ai AFTER INSERT ON tb_categories FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_categories', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'name', NEW.`name`, 'description', NEW.`description`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_categories_au AFTER UPDATE ON tb_categories FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_categories', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'name', OLD.`name`, 'description', OLD.`description`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'name', NEW.`name`, 'description', NEW.`description`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_categories_ad AFTER DELETE ON tb_categories FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_categories', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'name', OLD.`name`, 'description', OLD.`description`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_categories_bi BEFORE INSERT ON tb_categories FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.name)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Categoría sin nombre';
    END IF;
END$$

CREATE TRIGGER trg_tb_categories_bu BEFORE UPDATE ON tb_categories FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.name)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Categoría sin nombre';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_categories_bd BEFORE DELETE ON tb_categories FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_categories; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_products_ai AFTER INSERT ON tb_products FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_products', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'SKU', NEW.`SKU`, 'name', NEW.`name`, 'description', NEW.`description`, 'current_price', NEW.`current_price`, 'current_stock', NEW.`current_stock`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_products_au AFTER UPDATE ON tb_products FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_products', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'SKU', OLD.`SKU`, 'name', OLD.`name`, 'description', OLD.`description`, 'current_price', OLD.`current_price`, 'current_stock', OLD.`current_stock`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'SKU', NEW.`SKU`, 'name', NEW.`name`, 'description', NEW.`description`, 'current_price', NEW.`current_price`, 'current_stock', NEW.`current_stock`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_products_ad AFTER DELETE ON tb_products FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_products', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'SKU', OLD.`SKU`, 'name', OLD.`name`, 'description', OLD.`description`, 'current_price', OLD.`current_price`, 'current_stock', OLD.`current_stock`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_products_bi BEFORE INSERT ON tb_products FOR EACH ROW
BEGIN
    IF NEW.current_price <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio debe ser positivo';
    END IF;
    IF NEW.current_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock negativo';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.name)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto sin nombre';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.SKU)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SKU vacío';
    END IF;
END$$

CREATE TRIGGER trg_tb_products_bu BEFORE UPDATE ON tb_products FOR EACH ROW
BEGIN
    IF NEW.current_price <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio debe ser positivo';
    END IF;
    IF NEW.current_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock negativo';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.name)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto sin nombre';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.SKU)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SKU vacío';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_products_bd BEFORE DELETE ON tb_products FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_products; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_reviews_ai AFTER INSERT ON tb_reviews FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_reviews', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'product_id', NEW.`product_id`, 'rating', NEW.`rating`, 'comment', NEW.`comment`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_reviews_au AFTER UPDATE ON tb_reviews FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_reviews', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'product_id', OLD.`product_id`, 'rating', OLD.`rating`, 'comment', OLD.`comment`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'product_id', NEW.`product_id`, 'rating', NEW.`rating`, 'comment', NEW.`comment`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_reviews_ad AFTER DELETE ON tb_reviews FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_reviews', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'product_id', OLD.`product_id`, 'rating', OLD.`rating`, 'comment', OLD.`comment`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_reviews_bi BEFORE INSERT ON tb_reviews FOR EACH ROW
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rating fuera de rango';
    END IF;
END$$

CREATE TRIGGER trg_tb_reviews_bu BEFORE UPDATE ON tb_reviews FOR EACH ROW
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rating fuera de rango';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_reviews_bd BEFORE DELETE ON tb_reviews FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_reviews; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_people_ai AFTER INSERT ON tb_people FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_people', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'given_names', NEW.`given_names`, 'family_names', NEW.`family_names`, 'birth_date', NEW.`birth_date`, 'country_code', NEW.`country_code`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_people_au AFTER UPDATE ON tb_people FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_people', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'given_names', OLD.`given_names`, 'family_names', OLD.`family_names`, 'birth_date', OLD.`birth_date`, 'country_code', OLD.`country_code`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'given_names', NEW.`given_names`, 'family_names', NEW.`family_names`, 'birth_date', NEW.`birth_date`, 'country_code', NEW.`country_code`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_people_ad AFTER DELETE ON tb_people FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_people', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'given_names', OLD.`given_names`, 'family_names', OLD.`family_names`, 'birth_date', OLD.`birth_date`, 'country_code', OLD.`country_code`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_people_bi BEFORE INSERT ON tb_people FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.given_names)) = 0 OR CHAR_LENGTH(TRIM(NEW.family_names)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre personal vacío';
    END IF;
    IF NEW.birth_date > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nacimiento futuro';
    END IF;
END$$

CREATE TRIGGER trg_tb_people_bu BEFORE UPDATE ON tb_people FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.given_names)) = 0 OR CHAR_LENGTH(TRIM(NEW.family_names)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre personal vacío';
    END IF;
    IF NEW.birth_date > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nacimiento futuro';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_people_bd BEFORE DELETE ON tb_people FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_people; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_addresses_ai AFTER INSERT ON tb_addresses FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_addresses', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'country_code', NEW.`country_code`, 'state_id', NEW.`state_id`, 'city', NEW.`city`, 'street', NEW.`street`, 'postal_code', NEW.`postal_code`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_addresses_au AFTER UPDATE ON tb_addresses FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_addresses', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'country_code', OLD.`country_code`, 'state_id', OLD.`state_id`, 'city', OLD.`city`, 'street', OLD.`street`, 'postal_code', OLD.`postal_code`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'country_code', NEW.`country_code`, 'state_id', NEW.`state_id`, 'city', NEW.`city`, 'street', NEW.`street`, 'postal_code', NEW.`postal_code`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_addresses_ad AFTER DELETE ON tb_addresses FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_addresses', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'country_code', OLD.`country_code`, 'state_id', OLD.`state_id`, 'city', OLD.`city`, 'street', OLD.`street`, 'postal_code', OLD.`postal_code`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_addresses_bi BEFORE INSERT ON tb_addresses FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.city)) = 0 OR CHAR_LENGTH(TRIM(NEW.street)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dirección incompleta';
    END IF;
END$$

CREATE TRIGGER trg_tb_addresses_bu BEFORE UPDATE ON tb_addresses FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.city)) = 0 OR CHAR_LENGTH(TRIM(NEW.street)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dirección incompleta';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_addresses_bd BEFORE DELETE ON tb_addresses FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_addresses; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_carts_ai AFTER INSERT ON tb_carts FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_carts', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'status', NEW.`status`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_carts_au AFTER UPDATE ON tb_carts FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_carts', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'status', OLD.`status`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'status', NEW.`status`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_carts_ad AFTER DELETE ON tb_carts FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_carts', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'status', OLD.`status`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_carts_bi BEFORE INSERT ON tb_carts FOR EACH ROW
BEGIN
    IF NEW.status NOT IN ('active','checked_out','abandoned') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de carrito inválido';
    END IF;
END$$

CREATE TRIGGER trg_tb_carts_bu BEFORE UPDATE ON tb_carts FOR EACH ROW
BEGIN
    IF NEW.status NOT IN ('active','checked_out','abandoned') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de carrito inválido';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_carts_bd BEFORE DELETE ON tb_carts FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_carts; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_orders_ai AFTER INSERT ON tb_orders FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_orders', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'cart_id', NEW.`cart_id`, 'status', NEW.`status`, 'total_amount', NEW.`total_amount`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_orders_au AFTER UPDATE ON tb_orders FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_orders', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'cart_id', OLD.`cart_id`, 'status', OLD.`status`, 'total_amount', OLD.`total_amount`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'cart_id', NEW.`cart_id`, 'status', NEW.`status`, 'total_amount', NEW.`total_amount`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_orders_ad AFTER DELETE ON tb_orders FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_orders', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'cart_id', OLD.`cart_id`, 'status', OLD.`status`, 'total_amount', OLD.`total_amount`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_orders_bi BEFORE INSERT ON tb_orders FOR EACH ROW
BEGIN
    IF NEW.total_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Total de pedido no positivo';
    END IF;
    IF NEW.status NOT IN ('pending','paid','cancelled','shipped','delivered') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de pedido inválido';
    END IF;
END$$

CREATE TRIGGER trg_tb_orders_bu BEFORE UPDATE ON tb_orders FOR EACH ROW
BEGIN
    IF NEW.total_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Total de pedido no positivo';
    END IF;
    IF NEW.status NOT IN ('pending','paid','cancelled','shipped','delivered') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de pedido inválido';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_orders_bd BEFORE DELETE ON tb_orders FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_orders; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_wishlists_ai AFTER INSERT ON tb_wishlists FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_wishlists', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'product_id', NEW.`product_id`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_wishlists_au AFTER UPDATE ON tb_wishlists FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_wishlists', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'product_id', OLD.`product_id`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'user_id', NEW.`user_id`, 'product_id', NEW.`product_id`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_wishlists_ad AFTER DELETE ON tb_wishlists FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_wishlists', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'user_id', OLD.`user_id`, 'product_id', OLD.`product_id`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_wishlists_bi BEFORE INSERT ON tb_wishlists FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tb_users u WHERE u.id = NEW.user_id AND u.deleted_at IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wishlist requiere usuario activo';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tb_products p WHERE p.id = NEW.product_id AND p.deleted_at IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wishlist requiere producto activo';
    END IF;
END$$

CREATE TRIGGER trg_tb_wishlists_bu BEFORE UPDATE ON tb_wishlists FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tb_users u WHERE u.id = NEW.user_id AND u.deleted_at IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wishlist requiere usuario activo';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM tb_products p WHERE p.id = NEW.product_id AND p.deleted_at IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wishlist requiere producto activo';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_wishlists_bd BEFORE DELETE ON tb_wishlists FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_wishlists; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_payments_ai AFTER INSERT ON tb_payments FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_payments', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'order_id', NEW.`order_id`, 'payment_method_id', NEW.`payment_method_id`, 'amount', NEW.`amount`, 'payment_status', NEW.`payment_status`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_payments_au AFTER UPDATE ON tb_payments FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_payments', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'order_id', OLD.`order_id`, 'payment_method_id', OLD.`payment_method_id`, 'amount', OLD.`amount`, 'payment_status', OLD.`payment_status`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'order_id', NEW.`order_id`, 'payment_method_id', NEW.`payment_method_id`, 'amount', NEW.`amount`, 'payment_status', NEW.`payment_status`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_payments_ad AFTER DELETE ON tb_payments FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_payments', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'order_id', OLD.`order_id`, 'payment_method_id', OLD.`payment_method_id`, 'amount', OLD.`amount`, 'payment_status', OLD.`payment_status`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_payments_bi BEFORE INSERT ON tb_payments FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pago no positivo';
    END IF;
    IF NEW.payment_status NOT IN ('Pending','Completed','Failed','Refunded') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de pago inválido';
    END IF;
END$$

CREATE TRIGGER trg_tb_payments_bu BEFORE UPDATE ON tb_payments FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pago no positivo';
    END IF;
    IF NEW.payment_status NOT IN ('Pending','Completed','Failed','Refunded') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de pago inválido';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_payments_bd BEFORE DELETE ON tb_payments FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_payments; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_shipments_ai AFTER INSERT ON tb_shipments FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_shipments', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'order_id', NEW.`order_id`, 'carrier_id', NEW.`carrier_id`, 'address_id', NEW.`address_id`, 'tracking_code', NEW.`tracking_code`, 'status', NEW.`status`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_shipments_au AFTER UPDATE ON tb_shipments FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_shipments', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'order_id', OLD.`order_id`, 'carrier_id', OLD.`carrier_id`, 'address_id', OLD.`address_id`, 'tracking_code', OLD.`tracking_code`, 'status', OLD.`status`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'order_id', NEW.`order_id`, 'carrier_id', NEW.`carrier_id`, 'address_id', NEW.`address_id`, 'tracking_code', NEW.`tracking_code`, 'status', NEW.`status`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_shipments_ad AFTER DELETE ON tb_shipments FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_shipments', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'order_id', OLD.`order_id`, 'carrier_id', OLD.`carrier_id`, 'address_id', OLD.`address_id`, 'tracking_code', OLD.`tracking_code`, 'status', OLD.`status`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_shipments_bi BEFORE INSERT ON tb_shipments FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.tracking_code)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tracking vacío';
    END IF;
    IF NEW.status NOT IN ('pending','in_transit','delivered','returned') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de envío inválido';
    END IF;
END$$

CREATE TRIGGER trg_tb_shipments_bu BEFORE UPDATE ON tb_shipments FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.tracking_code)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tracking vacío';
    END IF;
    IF NEW.status NOT IN ('pending','in_transit','delivered','returned') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado de envío inválido';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_shipments_bd BEFORE DELETE ON tb_shipments FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_shipments; use deleted_at.';
END$$

CREATE TRIGGER trg_tb_invoices_ai AFTER INSERT ON tb_invoices FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_invoices', NEW.id, 'INSERT', USER(), NULL, JSON_OBJECT('id', NEW.`id`, 'order_id', NEW.`order_id`, 'invoice_number', NEW.`invoice_number`, 'total_amount', NEW.`total_amount`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_invoices_au AFTER UPDATE ON tb_invoices FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_invoices', NEW.id, 'UPDATE', USER(), JSON_OBJECT('id', OLD.`id`, 'order_id', OLD.`order_id`, 'invoice_number', OLD.`invoice_number`, 'total_amount', OLD.`total_amount`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), JSON_OBJECT('id', NEW.`id`, 'order_id', NEW.`order_id`, 'invoice_number', NEW.`invoice_number`, 'total_amount', NEW.`total_amount`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`, 'deleted_at', NEW.`deleted_at`));
END$$

CREATE TRIGGER trg_tb_invoices_ad AFTER DELETE ON tb_invoices FOR EACH ROW
BEGIN
    INSERT INTO tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
    VALUES ('tb_invoices', OLD.id, 'DELETE', USER(), JSON_OBJECT('id', OLD.`id`, 'order_id', OLD.`order_id`, 'invoice_number', OLD.`invoice_number`, 'total_amount', OLD.`total_amount`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`, 'deleted_at', OLD.`deleted_at`), NULL);
END$$

CREATE TRIGGER trg_tb_invoices_bi BEFORE INSERT ON tb_invoices FOR EACH ROW
BEGIN
    IF NEW.total_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Total de factura no positivo';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.invoice_number)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Folio vacío';
    END IF;
END$$

CREATE TRIGGER trg_tb_invoices_bu BEFORE UPDATE ON tb_invoices FOR EACH ROW
BEGIN
    IF NEW.total_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Total de factura no positivo';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.invoice_number)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Folio vacío';
    END IF;
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER trg_tb_invoices_bd BEFORE DELETE ON tb_invoices FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_invoices; use deleted_at.';
END$$

DELIMITER ;

-- Verificación: debe devolver 72 para este espacio de nombres.
SELECT COUNT(*) AS total_triggers FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'db_test_ecosystem';

-- ============================================================
-- VARIANTE POSTGRESQL: ejecutar por separado.
-- ============================================================
-- Fase 2: 26 tablas y exactamente 72 triggers.
-- Nuevo diseño: ejecutar solo en el espacio nuevo indicado; no es una migración.
-- Sin DROP TABLE, sin modificaciones del Docker o de los datos anteriores.
BEGIN;
CREATE SCHEMA IF NOT EXISTS ecommerce;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE ecommerce.tb_users (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "email" VARCHAR(254) NOT NULL UNIQUE,
    "nickname" VARCHAR(100) NOT NULL UNIQUE,
    "password" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL
);

CREATE TABLE ecommerce.tb_roles (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "name" VARCHAR(80) NOT NULL UNIQUE,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecommerce.tb_user_roles (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "role_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES ecommerce.tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (role_id) REFERENCES ecommerce.tb_roles (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_user_roles_1 ON ecommerce.tb_user_roles (user_id);
CREATE INDEX ix_tb_user_roles_2 ON ecommerce.tb_user_roles (role_id);

CREATE TABLE ecommerce.tb_permissions (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "code" VARCHAR(100) NOT NULL UNIQUE,
    "description" TEXT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecommerce.tb_role_permissions (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "role_id" BIGINT NOT NULL,
    "permission_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES ecommerce.tb_roles (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES ecommerce.tb_permissions (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_role_permissions_1 ON ecommerce.tb_role_permissions (role_id);
CREATE INDEX ix_tb_role_permissions_2 ON ecommerce.tb_role_permissions (permission_id);

CREATE TABLE ecommerce.tb_categories (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "name" VARCHAR(150) NOT NULL UNIQUE,
    "description" TEXT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL
);

CREATE TABLE ecommerce.tb_products (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "SKU" VARCHAR(50) NOT NULL UNIQUE,
    "name" VARCHAR(250) NOT NULL,
    "description" TEXT NULL,
    "current_price" DECIMAL(12,2) NOT NULL CHECK (current_price > 0),
    "current_stock" INT NOT NULL DEFAULT 0 CHECK (current_stock >= 0),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL
);

CREATE TABLE ecommerce.tb_product_categories (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "product_id" BIGINT NOT NULL,
    "category_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES ecommerce.tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES ecommerce.tb_categories (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_product_categories_1 ON ecommerce.tb_product_categories (product_id);
CREATE INDEX ix_tb_product_categories_2 ON ecommerce.tb_product_categories (category_id);

CREATE TABLE ecommerce.tb_tags (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "name" VARCHAR(80) NOT NULL UNIQUE,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecommerce.tb_product_tags (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "product_id" BIGINT NOT NULL,
    "tag_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, tag_id),
    FOREIGN KEY (product_id) REFERENCES ecommerce.tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES ecommerce.tb_tags (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_product_tags_1 ON ecommerce.tb_product_tags (product_id);
CREATE INDEX ix_tb_product_tags_2 ON ecommerce.tb_product_tags (tag_id);

CREATE TABLE ecommerce.tb_reviews (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "product_id" BIGINT NOT NULL,
    "rating" INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    "comment" TEXT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL,
    UNIQUE (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES ecommerce.tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES ecommerce.tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_reviews_1 ON ecommerce.tb_reviews (user_id);
CREATE INDEX ix_tb_reviews_2 ON ecommerce.tb_reviews (product_id);

CREATE TABLE ecommerce.tbc_countries (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "code" CHAR(2) NOT NULL UNIQUE,
    "name" VARCHAR(100) NOT NULL UNIQUE,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecommerce.tbc_states (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "country_code" CHAR(2) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (country_code, name),
    UNIQUE (id, country_code),
    FOREIGN KEY (country_code) REFERENCES ecommerce.tbc_countries (code) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tbc_states_1 ON ecommerce.tbc_states (country_code);

CREATE TABLE ecommerce.tb_people (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "user_id" BIGINT NOT NULL UNIQUE,
    "given_names" VARCHAR(150) NOT NULL,
    "family_names" VARCHAR(150) NOT NULL,
    "birth_date" DATE NOT NULL,
    "country_code" CHAR(2) NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES ecommerce.tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (country_code) REFERENCES ecommerce.tbc_countries (code) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_people_1 ON ecommerce.tb_people (user_id);
CREATE INDEX ix_tb_people_2 ON ecommerce.tb_people (country_code);

CREATE TABLE ecommerce.tb_addresses (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "country_code" CHAR(2) NOT NULL,
    "state_id" BIGINT NULL,
    "city" VARCHAR(120) NOT NULL,
    "street" VARCHAR(250) NOT NULL,
    "postal_code" VARCHAR(20) NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES ecommerce.tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (country_code) REFERENCES ecommerce.tbc_countries (code) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (state_id, country_code) REFERENCES ecommerce.tbc_states (id, country_code) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_addresses_1 ON ecommerce.tb_addresses (user_id);
CREATE INDEX ix_tb_addresses_2 ON ecommerce.tb_addresses (country_code);
CREATE INDEX ix_tb_addresses_3 ON ecommerce.tb_addresses (state_id, country_code);

CREATE TABLE ecommerce.tb_carts (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "status" VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active','checked_out','abandoned')),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL,
    UNIQUE (id, user_id),
    FOREIGN KEY (user_id) REFERENCES ecommerce.tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_carts_1 ON ecommerce.tb_carts (user_id);

CREATE TABLE ecommerce.tbd_shopping_cart (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "cart_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "product_id" BIGINT NOT NULL,
    "quantity" INT NOT NULL CHECK (quantity > 0),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (cart_id, product_id),
    FOREIGN KEY (cart_id, user_id) REFERENCES ecommerce.tb_carts (id, user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES ecommerce.tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES ecommerce.tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tbd_shopping_cart_1 ON ecommerce.tbd_shopping_cart (cart_id, user_id);
CREATE INDEX ix_tbd_shopping_cart_2 ON ecommerce.tbd_shopping_cart (user_id);
CREATE INDEX ix_tbd_shopping_cart_3 ON ecommerce.tbd_shopping_cart (product_id);

CREATE TABLE ecommerce.tb_orders (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "cart_id" BIGINT NULL UNIQUE,
    "status" VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','paid','cancelled','shipped','delivered')),
    "total_amount" DECIMAL(12,2) NOT NULL CHECK (total_amount > 0),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL,
    UNIQUE (id, user_id),
    FOREIGN KEY (user_id) REFERENCES ecommerce.tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (cart_id, user_id) REFERENCES ecommerce.tb_carts (id, user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_orders_1 ON ecommerce.tb_orders (user_id);
CREATE INDEX ix_tb_orders_2 ON ecommerce.tb_orders (cart_id, user_id);

CREATE TABLE ecommerce.tb_order_items (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "order_id" BIGINT NOT NULL,
    "product_id" BIGINT NOT NULL,
    "product_name" VARCHAR(250) NOT NULL,
    "quantity" INT NOT NULL CHECK (quantity > 0),
    "unit_price" DECIMAL(12,2) NOT NULL CHECK (unit_price > 0),
    "subtotal" DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES ecommerce.tb_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES ecommerce.tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_order_items_1 ON ecommerce.tb_order_items (order_id);
CREATE INDEX ix_tb_order_items_2 ON ecommerce.tb_order_items (product_id);

CREATE TABLE ecommerce.tb_wishlists (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "product_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL,
    UNIQUE (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES ecommerce.tb_users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES ecommerce.tb_products (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_wishlists_1 ON ecommerce.tb_wishlists (user_id);
CREATE INDEX ix_tb_wishlists_2 ON ecommerce.tb_wishlists (product_id);

CREATE TABLE ecommerce.tbc_payment_methods (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "code" VARCHAR(40) NOT NULL UNIQUE,
    "name" VARCHAR(100) NOT NULL UNIQUE,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecommerce.tb_payments (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "order_id" BIGINT NOT NULL,
    "payment_method_id" BIGINT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    "payment_status" VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (payment_status IN ('Pending','Completed','Failed','Refunded')),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES ecommerce.tb_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES ecommerce.tbc_payment_methods (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_payments_1 ON ecommerce.tb_payments (order_id);
CREATE INDEX ix_tb_payments_2 ON ecommerce.tb_payments (payment_method_id);

CREATE TABLE ecommerce.tb_carriers (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "name" VARCHAR(150) NOT NULL UNIQUE,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecommerce.tb_shipments (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "order_id" BIGINT NOT NULL,
    "carrier_id" BIGINT NOT NULL,
    "address_id" BIGINT NOT NULL,
    "tracking_code" VARCHAR(150) NOT NULL UNIQUE,
    "status" VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','in_transit','delivered','returned')),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES ecommerce.tb_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (carrier_id) REFERENCES ecommerce.tb_carriers (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (address_id) REFERENCES ecommerce.tb_addresses (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_shipments_1 ON ecommerce.tb_shipments (order_id);
CREATE INDEX ix_tb_shipments_2 ON ecommerce.tb_shipments (carrier_id);
CREATE INDEX ix_tb_shipments_3 ON ecommerce.tb_shipments (address_id);

CREATE TABLE ecommerce.tb_invoices (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "order_id" BIGINT NOT NULL UNIQUE,
    "invoice_number" VARCHAR(80) NOT NULL UNIQUE,
    "total_amount" DECIMAL(12,2) NOT NULL CHECK (total_amount > 0),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES ecommerce.tb_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX ix_tb_invoices_1 ON ecommerce.tb_invoices (order_id);

CREATE TABLE ecommerce.tb_logs (
    "id" BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "table_name" VARCHAR(100) NOT NULL,
    "entity_id" BIGINT NOT NULL,
    "operation" VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT','UPDATE','DELETE')),
    "db_actor" VARCHAR(288) NOT NULL,
    "old_data" JSONB NULL,
    "new_data" JSONB NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE FUNCTION ecommerce.fn_audit_row() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO ecommerce.tb_logs(table_name, entity_id, operation, db_actor, new_data)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, session_user, to_jsonb(NEW) - 'password');
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO ecommerce.tb_logs(table_name, entity_id, operation, db_actor, old_data, new_data)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, session_user, to_jsonb(OLD) - 'password', to_jsonb(NEW) - 'password');
    ELSE
        INSERT INTO ecommerce.tb_logs(table_name, entity_id, operation, db_actor, old_data)
        VALUES (TG_TABLE_NAME, OLD.id, TG_OP, session_user, to_jsonb(OLD) - 'password');
    END IF;
    RETURN NULL;
END;
$$;

CREATE FUNCTION ecommerce.fn_block_physical_delete() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'DELETE físico bloqueado en %. Use UPDATE deleted_at.', TG_TABLE_NAME;
END;
$$;

CREATE TRIGGER trg_tb_users_ai AFTER INSERT ON ecommerce.tb_users
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_users_au AFTER UPDATE ON ecommerce.tb_users
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_users_ad AFTER DELETE ON ecommerce.tb_users
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_users() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Email inválido';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.nickname)) = 0 THEN
        RAISE EXCEPTION 'Nickname vacío';
    END IF;
    IF CHAR_LENGTH(NEW.password) < 32 THEN
        RAISE EXCEPTION 'Hash de contraseña inválido';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_users_bi BEFORE INSERT ON ecommerce.tb_users
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_users();

CREATE TRIGGER trg_tb_users_bu BEFORE UPDATE ON ecommerce.tb_users
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_users();

CREATE TRIGGER trg_tb_users_bd BEFORE DELETE ON ecommerce.tb_users
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_categories_ai AFTER INSERT ON ecommerce.tb_categories
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_categories_au AFTER UPDATE ON ecommerce.tb_categories
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_categories_ad AFTER DELETE ON ecommerce.tb_categories
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_categories() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.name)) = 0 THEN
        RAISE EXCEPTION 'Categoría sin nombre';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_categories_bi BEFORE INSERT ON ecommerce.tb_categories
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_categories();

CREATE TRIGGER trg_tb_categories_bu BEFORE UPDATE ON ecommerce.tb_categories
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_categories();

CREATE TRIGGER trg_tb_categories_bd BEFORE DELETE ON ecommerce.tb_categories
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_products_ai AFTER INSERT ON ecommerce.tb_products
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_products_au AFTER UPDATE ON ecommerce.tb_products
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_products_ad AFTER DELETE ON ecommerce.tb_products
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_products() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.current_price <= 0 THEN
        RAISE EXCEPTION 'Precio debe ser positivo';
    END IF;
    IF NEW.current_stock < 0 THEN
        RAISE EXCEPTION 'Stock negativo';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.name)) = 0 THEN
        RAISE EXCEPTION 'Producto sin nombre';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW."SKU")) = 0 THEN
        RAISE EXCEPTION 'SKU vacío';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_products_bi BEFORE INSERT ON ecommerce.tb_products
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_products();

CREATE TRIGGER trg_tb_products_bu BEFORE UPDATE ON ecommerce.tb_products
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_products();

CREATE TRIGGER trg_tb_products_bd BEFORE DELETE ON ecommerce.tb_products
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_reviews_ai AFTER INSERT ON ecommerce.tb_reviews
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_reviews_au AFTER UPDATE ON ecommerce.tb_reviews
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_reviews_ad AFTER DELETE ON ecommerce.tb_reviews
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_reviews() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        RAISE EXCEPTION 'Rating fuera de rango';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_reviews_bi BEFORE INSERT ON ecommerce.tb_reviews
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_reviews();

CREATE TRIGGER trg_tb_reviews_bu BEFORE UPDATE ON ecommerce.tb_reviews
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_reviews();

CREATE TRIGGER trg_tb_reviews_bd BEFORE DELETE ON ecommerce.tb_reviews
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_people_ai AFTER INSERT ON ecommerce.tb_people
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_people_au AFTER UPDATE ON ecommerce.tb_people
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_people_ad AFTER DELETE ON ecommerce.tb_people
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_people() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.given_names)) = 0 OR CHAR_LENGTH(TRIM(NEW.family_names)) = 0 THEN
        RAISE EXCEPTION 'Nombre personal vacío';
    END IF;
    IF NEW.birth_date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Nacimiento futuro';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_people_bi BEFORE INSERT ON ecommerce.tb_people
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_people();

CREATE TRIGGER trg_tb_people_bu BEFORE UPDATE ON ecommerce.tb_people
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_people();

CREATE TRIGGER trg_tb_people_bd BEFORE DELETE ON ecommerce.tb_people
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_addresses_ai AFTER INSERT ON ecommerce.tb_addresses
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_addresses_au AFTER UPDATE ON ecommerce.tb_addresses
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_addresses_ad AFTER DELETE ON ecommerce.tb_addresses
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_addresses() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.city)) = 0 OR CHAR_LENGTH(TRIM(NEW.street)) = 0 THEN
        RAISE EXCEPTION 'Dirección incompleta';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_addresses_bi BEFORE INSERT ON ecommerce.tb_addresses
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_addresses();

CREATE TRIGGER trg_tb_addresses_bu BEFORE UPDATE ON ecommerce.tb_addresses
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_addresses();

CREATE TRIGGER trg_tb_addresses_bd BEFORE DELETE ON ecommerce.tb_addresses
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_carts_ai AFTER INSERT ON ecommerce.tb_carts
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_carts_au AFTER UPDATE ON ecommerce.tb_carts
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_carts_ad AFTER DELETE ON ecommerce.tb_carts
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_carts() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.status NOT IN ('active','checked_out','abandoned') THEN
        RAISE EXCEPTION 'Estado de carrito inválido';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_carts_bi BEFORE INSERT ON ecommerce.tb_carts
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_carts();

CREATE TRIGGER trg_tb_carts_bu BEFORE UPDATE ON ecommerce.tb_carts
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_carts();

CREATE TRIGGER trg_tb_carts_bd BEFORE DELETE ON ecommerce.tb_carts
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_orders_ai AFTER INSERT ON ecommerce.tb_orders
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_orders_au AFTER UPDATE ON ecommerce.tb_orders
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_orders_ad AFTER DELETE ON ecommerce.tb_orders
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_orders() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.total_amount <= 0 THEN
        RAISE EXCEPTION 'Total de pedido no positivo';
    END IF;
    IF NEW.status NOT IN ('pending','paid','cancelled','shipped','delivered') THEN
        RAISE EXCEPTION 'Estado de pedido inválido';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_orders_bi BEFORE INSERT ON ecommerce.tb_orders
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_orders();

CREATE TRIGGER trg_tb_orders_bu BEFORE UPDATE ON ecommerce.tb_orders
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_orders();

CREATE TRIGGER trg_tb_orders_bd BEFORE DELETE ON ecommerce.tb_orders
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_wishlists_ai AFTER INSERT ON ecommerce.tb_wishlists
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_wishlists_au AFTER UPDATE ON ecommerce.tb_wishlists
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_wishlists_ad AFTER DELETE ON ecommerce.tb_wishlists
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_wishlists() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ecommerce.tb_users u WHERE u.id = NEW.user_id AND u.deleted_at IS NULL) THEN
        RAISE EXCEPTION 'Wishlist requiere usuario activo';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ecommerce.tb_products p WHERE p.id = NEW.product_id AND p.deleted_at IS NULL) THEN
        RAISE EXCEPTION 'Wishlist requiere producto activo';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_wishlists_bi BEFORE INSERT ON ecommerce.tb_wishlists
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_wishlists();

CREATE TRIGGER trg_tb_wishlists_bu BEFORE UPDATE ON ecommerce.tb_wishlists
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_wishlists();

CREATE TRIGGER trg_tb_wishlists_bd BEFORE DELETE ON ecommerce.tb_wishlists
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_payments_ai AFTER INSERT ON ecommerce.tb_payments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_payments_au AFTER UPDATE ON ecommerce.tb_payments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_payments_ad AFTER DELETE ON ecommerce.tb_payments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_payments() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.amount <= 0 THEN
        RAISE EXCEPTION 'Pago no positivo';
    END IF;
    IF NEW.payment_status NOT IN ('Pending','Completed','Failed','Refunded') THEN
        RAISE EXCEPTION 'Estado de pago inválido';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_payments_bi BEFORE INSERT ON ecommerce.tb_payments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_payments();

CREATE TRIGGER trg_tb_payments_bu BEFORE UPDATE ON ecommerce.tb_payments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_payments();

CREATE TRIGGER trg_tb_payments_bd BEFORE DELETE ON ecommerce.tb_payments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_shipments_ai AFTER INSERT ON ecommerce.tb_shipments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_shipments_au AFTER UPDATE ON ecommerce.tb_shipments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_shipments_ad AFTER DELETE ON ecommerce.tb_shipments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_shipments() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF CHAR_LENGTH(TRIM(NEW.tracking_code)) = 0 THEN
        RAISE EXCEPTION 'Tracking vacío';
    END IF;
    IF NEW.status NOT IN ('pending','in_transit','delivered','returned') THEN
        RAISE EXCEPTION 'Estado de envío inválido';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_shipments_bi BEFORE INSERT ON ecommerce.tb_shipments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_shipments();

CREATE TRIGGER trg_tb_shipments_bu BEFORE UPDATE ON ecommerce.tb_shipments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_shipments();

CREATE TRIGGER trg_tb_shipments_bd BEFORE DELETE ON ecommerce.tb_shipments
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

CREATE TRIGGER trg_tb_invoices_ai AFTER INSERT ON ecommerce.tb_invoices
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_invoices_au AFTER UPDATE ON ecommerce.tb_invoices
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE TRIGGER trg_tb_invoices_ad AFTER DELETE ON ecommerce.tb_invoices
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_audit_row();

CREATE FUNCTION ecommerce.fn_validate_tb_invoices() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.total_amount <= 0 THEN
        RAISE EXCEPTION 'Total de factura no positivo';
    END IF;
    IF CHAR_LENGTH(TRIM(NEW.invoice_number)) = 0 THEN
        RAISE EXCEPTION 'Folio vacío';
    END IF;
    IF TG_OP = 'UPDATE' THEN
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_tb_invoices_bi BEFORE INSERT ON ecommerce.tb_invoices
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_invoices();

CREATE TRIGGER trg_tb_invoices_bu BEFORE UPDATE ON ecommerce.tb_invoices
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_validate_tb_invoices();

CREATE TRIGGER trg_tb_invoices_bd BEFORE DELETE ON ecommerce.tb_invoices
FOR EACH ROW EXECUTE FUNCTION ecommerce.fn_block_physical_delete();

COMMIT;

-- Verificación: debe devolver 72 para este espacio de nombres.
SELECT COUNT(*) AS total_triggers FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='ecommerce' AND NOT t.tgisinternal;

```

## Bloque 3 — Funciones y procedimiento masivo por motor

```sql
-- ============================================================
-- VARIANTE MYSQL: ejecutar por separado.
-- ============================================================
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

-- ============================================================
-- VARIANTE POSTGRESQL: ejecutar por separado.
-- ============================================================
-- Fase 3: PostgreSQL 16+. CALL es atómico; no hay COMMIT dentro de las rutinas.
-- Puede usarse BEGIN; CALL ecommerce.sp_massive_user_generation(1); COMMIT;
-- pgcrypto debe estar instalado en public por el archivo 02_postgresql.sql.

CREATE OR REPLACE FUNCTION ecommerce.fn_gen_us_name() RETURNS TEXT
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    first_names TEXT[] := ARRAY['James', 'Olivia', 'William', 'Emma', 'Benjamin', 'Charlotte', 'Henry', 'Amelia', 'Michael', 'Sophia', 'Daniel', 'Isabella'];
    last_names TEXT[] := ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Miller', 'Davis', 'Wilson', 'Anderson', 'Taylor', 'Thomas', 'Moore'];
BEGIN
    RETURN first_names[1 + floor(random()*12)::int] || '|' || last_names[1 + floor(random()*12)::int];
END;
$$;

CREATE OR REPLACE FUNCTION ecommerce.fn_gen_latam_name() RETURNS TEXT
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    first_names TEXT[] := ARRAY['Santiago', 'Valentina', 'Mateo', 'Camila', 'Sebastián', 'Mariana', 'Diego', 'Lucía', 'Alejandro', 'Daniela', 'Nicolás', 'Gabriela'];
    last_names TEXT[] := ARRAY['García', 'Rodríguez', 'Martínez', 'Hernández', 'López', 'González', 'Pérez', 'Sánchez', 'Ramírez', 'Torres', 'Flores', 'Rivera'];
BEGIN
    RETURN first_names[1 + floor(random()*12)::int] || '|' || last_names[1 + floor(random()*12)::int];
END;
$$;

CREATE OR REPLACE FUNCTION ecommerce.fn_gen_random_date(min_age INT,max_age INT)
RETURNS DATE LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    oldest DATE;
    youngest DATE;
    born DATE;
    age_years INT;
BEGIN
    IF min_age IS NULL OR max_age IS NULL OR min_age<0 OR max_age<min_age OR max_age>120 THEN
        RAISE EXCEPTION 'Edades inválidas.';
    END IF;
    oldest := (CURRENT_DATE-make_interval(years=>max_age+1))::date+1;
    youngest := (CURRENT_DATE-make_interval(years=>min_age))::date;
    born := oldest+floor(random()*(youngest-oldest+1))::int;
    age_years := extract(year FROM age(CURRENT_DATE,born))::int;
    WHILE age_years < min_age OR age_years > max_age LOOP
        born := oldest+floor(random()*(youngest-oldest+1))::int;
        age_years := extract(year FROM age(CURRENT_DATE,born))::int;
    END LOOP;
    RETURN born;
END;
$$;

CREATE OR REPLACE FUNCTION ecommerce.fn_get_random_active_product()
RETURNS BIGINT LANGUAGE plpgsql VOLATILE AS $$
DECLARE chosen BIGINT;
BEGIN
    SELECT id INTO chosen FROM ecommerce.tb_products
    WHERE deleted_at IS NULL AND current_stock>0
    ORDER BY random() LIMIT 1 FOR UPDATE;
    IF chosen IS NULL THEN RAISE EXCEPTION 'No hay productos activos con existencias.'; END IF;
    RETURN chosen;
END;
$$;

-- Responsabilidad: cuenta y ficha; misma transacción que el llamador.
CREATE OR REPLACE FUNCTION ecommerce.fn_create_user_person(
    p_name TEXT,p_country CHAR(2),p_birth DATE,p_deleted TIMESTAMP
) RETURNS BIGINT LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    token TEXT := replace(pg_catalog.gen_random_uuid()::text,'-','');
    created_user BIGINT;
BEGIN
    INSERT INTO ecommerce.tb_users(email,nickname,password,deleted_at)
    VALUES('mass_'||token||'@example.test','gen_'||token,
           public.crypt(pg_catalog.gen_random_uuid()::text,public.gen_salt('bf',10)),p_deleted)
    RETURNING id INTO created_user;
    INSERT INTO ecommerce.tb_people(user_id,given_names,family_names,birth_date,country_code,deleted_at)
    VALUES(created_user,split_part(p_name,'|',1),split_part(p_name,'|',2),p_birth,p_country,p_deleted);
    RETURN created_user;
END;
$$;

CREATE OR REPLACE FUNCTION ecommerce.fn_assign_purchase(p_user_id BIGINT)
RETURNS VOID LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    selected_product BIGINT;
    created_cart BIGINT;
    created_order BIGINT;
    selected_price DECIMAL(12,2);
    selected_name VARCHAR(250);
    selected_method BIGINT;
BEGIN
    IF NOT EXISTS(SELECT 1 FROM ecommerce.tb_users WHERE id=p_user_id AND deleted_at IS NULL) THEN
        RAISE EXCEPTION 'La compra requiere un usuario activo.';
    END IF;
    selected_product := ecommerce.fn_get_random_active_product();
    SELECT current_price,name INTO selected_price,selected_name
    FROM ecommerce.tb_products WHERE id=selected_product FOR UPDATE;
    INSERT INTO ecommerce.tb_carts(user_id,status) VALUES(p_user_id,'checked_out') RETURNING id INTO created_cart;
    INSERT INTO ecommerce.tbd_shopping_cart(cart_id,user_id,product_id,quantity)
    VALUES(created_cart,p_user_id,selected_product,1);
    INSERT INTO ecommerce.tb_orders(user_id,cart_id,status,total_amount)
    VALUES(p_user_id,created_cart,'paid',selected_price) RETURNING id INTO created_order;
    INSERT INTO ecommerce.tb_order_items(order_id,product_id,product_name,quantity,unit_price)
    VALUES(created_order,selected_product,selected_name,1,selected_price);
    selected_method := 1+floor(random()*3)::int;
    INSERT INTO ecommerce.tb_payments(order_id,payment_method_id,amount,payment_status)
    VALUES(created_order,selected_method,selected_price,'Completed');
    UPDATE ecommerce.tb_products SET current_stock=current_stock-1
    WHERE id=selected_product AND deleted_at IS NULL AND current_stock>0;
    IF NOT FOUND THEN RAISE EXCEPTION 'No se pudo descontar inventario.'; END IF;
END;
$$;

-- CALL se ejecuta en una sola transacción; una excepción revierte el lote.
-- No se hace COMMIT interno para permitir también BEGIN/CALL/COMMIT del cliente.
CREATE OR REPLACE PROCEDURE ecommerce.sp_massive_user_generation(IN p_scenario INT)
LANGUAGE plpgsql AS $$
DECLARE
    total_count INT;
    counter INT := 0;
    active_count INT := 0;
    created_user BIGINT;
    generated_name TEXT;
    country_codes TEXT[] := ARRAY['MX','CO','AR','CL','PE','EC','CR','UY'];
    generated_country CHAR(2);
    generated_birth DATE;
    deleted_time TIMESTAMP;
    is_active BOOLEAN;
BEGIN
    IF p_scenario IS NULL OR p_scenario NOT IN(1,2,3) THEN
        RAISE EXCEPTION 'Escenario válido: 1, 2 o 3.';
    END IF;
    total_count := CASE p_scenario WHEN 1 THEN 1000 WHEN 2 THEN 2000 ELSE 7222 END;
    IF (SELECT count(*) FROM ecommerce.tbc_payment_methods WHERE id IN(1,2,3)) <> 3 THEN
        RAISE EXCEPTION 'Faltan métodos de pago 1, 2 o 3.';
    END IF;
    IF (SELECT count(*) FROM ecommerce.tbc_countries WHERE code IN('US','MX','CO','AR','CL','PE','EC','CR','UY')) <> 9 THEN
        RAISE EXCEPTION 'Ejecute primero las semillas de países.';
    END IF;
    WHILE counter < total_count LOOP
        IF p_scenario=1 THEN
            generated_name := ecommerce.fn_gen_us_name();
            generated_country := 'US';
        ELSE
            generated_name := ecommerce.fn_gen_latam_name();
            generated_country := country_codes[1+floor(random()*8)::int];
        END IF;
        generated_birth := ecommerce.fn_gen_random_date(18,CASE WHEN p_scenario=2 THEN 30 ELSE 80 END);
        is_active := TRUE;
        deleted_time := NULL;
        IF p_scenario=3 THEN
            is_active := (random() <= 0.85);
            IF NOT is_active THEN deleted_time := CURRENT_TIMESTAMP; END IF;
        END IF;
        created_user := ecommerce.fn_create_user_person(generated_name,generated_country,generated_birth,deleted_time);
        IF is_active THEN
            PERFORM ecommerce.fn_assign_purchase(created_user);
            active_count := active_count+1;
        END IF;
        counter := counter+1;
    END LOOP;
    RAISE NOTICE 'Escenario %: total %, activos %, bajas %, carritos/pedidos/pagos %',
        p_scenario,total_count,active_count,total_count-active_count,active_count;
END;
$$;

-- CALL ecommerce.sp_massive_user_generation(1);
-- CALL ecommerce.sp_massive_user_generation(2);
-- CALL ecommerce.sp_massive_user_generation(3);

```

