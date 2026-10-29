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
