-- ============================================================
-- PRÁCTICA 03 - db_test
-- Alumno: Emigdio Aguirre
-- Matrícula: 240545
-- Puerto MySQL: 40545
-- ============================================================

DROP DATABASE IF EXISTS `db_test`;
CREATE DATABASE `db_test`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `db_test`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;

-- ------------------------------------------------------------
-- Eliminar objetos existentes
-- ------------------------------------------------------------
DROP VIEW IF EXISTS `vw_logs`;
DROP VIEW IF EXISTS `vw_products`;
DROP VIEW IF EXISTS `vw_categories`;
DROP VIEW IF EXISTS `vw_users`;

DROP TRIGGER IF EXISTS `trg_products_after_delete`;
DROP TRIGGER IF EXISTS `trg_products_after_update`;
DROP TRIGGER IF EXISTS `trg_products_after_insert`;
DROP TRIGGER IF EXISTS `trg_users_after_delete`;
DROP TRIGGER IF EXISTS `trg_users_after_update`;
DROP TRIGGER IF EXISTS `trg_users_after_insert`;

DROP TABLE IF EXISTS `tb_products`;
DROP TABLE IF EXISTS `tb_users`;
DROP TABLE IF EXISTS `tb_logs`;
DROP TABLE IF EXISTS `tb_categories`;

-- ------------------------------------------------------------
-- 1. Tabla de categorías
-- ------------------------------------------------------------
CREATE TABLE `tb_categories` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    `status` BIT(1) NOT NULL DEFAULT b'1',
    `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_update` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    UNIQUE KEY `uk_tb_categories_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 2. Tabla de logs
-- ------------------------------------------------------------
CREATE TABLE `tb_logs` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `table_name` VARCHAR(100) NOT NULL,
    `operation` ENUM('Create','Read','Update','Delete') NOT NULL,
    `db_user` VARCHAR(80) NOT NULL,
    `description` TEXT NOT NULL,
    `operation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `operation_status` BIT(1) NOT NULL DEFAULT b'1',
    PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 3. Tabla de usuarios
-- ------------------------------------------------------------
CREATE TABLE `tb_users` (
    `ID` INT NOT NULL AUTO_INCREMENT,
    `email` VARCHAR(80) NOT NULL,
    `nickname` VARCHAR(100) NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_update` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    `last_login` DATETIME NULL DEFAULT NULL,
    PRIMARY KEY (`ID`),
    UNIQUE KEY `uk_tb_users_email` (`email`),
    UNIQUE KEY `uk_tb_users_nickname` (`nickname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 4. Tabla de productos con FK a categorías
-- ------------------------------------------------------------
CREATE TABLE `tb_products` (
    `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `SKU` VARCHAR(50) NOT NULL,
    `name` VARCHAR(250) NOT NULL,
    `description` TEXT NULL,
    `category_id` INT UNSIGNED NULL,
    `current_price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `current_stock` INT UNSIGNED NOT NULL DEFAULT 0,
    `status` BIT(1) NOT NULL DEFAULT b'1',
    `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_update` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID`),
    UNIQUE KEY `uk_tb_products_sku` (`SKU`),
    KEY `fk_tb_products_categories` (`category_id`),
    CONSTRAINT `fk_tb_products_categories`
        FOREIGN KEY (`category_id`)
        REFERENCES `tb_categories` (`ID`)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT `chk_price` CHECK (`current_price` >= 0),
    CONSTRAINT `chk_stock` CHECK (`current_stock` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 5. Datos iniciales
-- ------------------------------------------------------------
INSERT INTO `tb_categories` (`ID`, `name`, `description`) VALUES
(1, 'Electrónica', 'Dispositivos y accesorios electrónicos'),
(2, 'Ropa', 'Prendas de vestir y accesorios'),
(3, 'Hogar', 'Artículos para el hogar y decoración');

INSERT INTO `tb_users` (`ID`, `email`, `nickname`, `password`, `creation_date`) VALUES
(1, 'marco.admin@utd.edu.mx', 'Marco Admin', SHA2('admin123',256), NOW()),
(240545, 'emigdio.aguirre@alumno.utd.edu.mx', 'Emigdio Aguirre', SHA2('240545',256), NOW());

INSERT INTO `tb_products` (`SKU`, `name`, `description`, `category_id`, `current_price`, `current_stock`) VALUES
('SKU-001', 'Laptop Lenovo', 'Laptop 15 pulgadas', 1, 12000.00, 10),
('SKU-002', 'Camiseta Negra', 'Camiseta algodón', 2, 250.00, 50),
('SKU-003', 'Lámpara LED', 'Lámpara de escritorio', 3, 450.00, 30);

-- ------------------------------------------------------------
-- 6. Triggers de auditoría
-- ------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER `trg_users_after_insert` AFTER INSERT ON `tb_users` FOR EACH ROW
BEGIN
    INSERT INTO `tb_logs` (`table_name`, `operation`, `db_user`, `description`)
    VALUES ('tb_users', 'Create', USER(), CONCAT('Usuario creado. ID=', NEW.ID, ', email=', NEW.email, ', nickname=', NEW.nickname));
END$$

CREATE TRIGGER `trg_users_after_update` AFTER UPDATE ON `tb_users` FOR EACH ROW
BEGIN
    DECLARE cambios TEXT;
    SET cambios = CONCAT_WS(', ',
        IF(NOT (OLD.email <=> NEW.email), CONCAT('email: [', OLD.email, '] -> [', NEW.email, ']'), NULL),
        IF(NOT (OLD.nickname <=> NEW.nickname), CONCAT('nickname: [', OLD.nickname, '] -> [', NEW.nickname, ']'), NULL)
    );
    INSERT INTO `tb_logs` (`table_name`, `operation`, `db_user`, `description`)
    VALUES ('tb_users', 'Update', USER(), CONCAT('Usuario actualizado. ID=', NEW.ID, '. Cambios: ', IF(COALESCE(cambios,'')='', 'Sin cambios', cambios)));
END$$

CREATE TRIGGER `trg_users_after_delete` AFTER DELETE ON `tb_users` FOR EACH ROW
BEGIN
    INSERT INTO `tb_logs` (`table_name`, `operation`, `db_user`, `description`)
    VALUES ('tb_users', 'Delete', USER(), CONCAT('Usuario eliminado. ID=', OLD.ID, ', email=', OLD.email));
END$$

CREATE TRIGGER `trg_products_after_insert` AFTER INSERT ON `tb_products` FOR EACH ROW
BEGIN
    INSERT INTO `tb_logs` (`table_name`, `operation`, `db_user`, `description`)
    VALUES ('tb_products', 'Create', USER(), CONCAT('Producto creado - ID: ', NEW.ID, ', SKU: ', NEW.SKU));
END$$

CREATE TRIGGER `trg_products_after_update` AFTER UPDATE ON `tb_products` FOR EACH ROW
BEGIN
    DECLARE cambios TEXT;
    SET cambios = CONCAT_WS(', ',
        IF(NOT (OLD.current_price <=> NEW.current_price), CONCAT('precio: [', OLD.current_price, '] -> [', NEW.current_price, ']'), NULL),
        IF(NOT (OLD.current_stock <=> NEW.current_stock), CONCAT('stock: [', OLD.current_stock, '] -> [', NEW.current_stock, ']'), NULL),
        IF(NOT (OLD.category_id <=> NEW.category_id), CONCAT('categoría: [', OLD.category_id, '] -> [', NEW.category_id, ']'), NULL)
    );
    INSERT INTO `tb_logs` (`table_name`, `operation`, `db_user`, `description`)
    VALUES ('tb_products', 'Update', USER(), CONCAT('Producto actualizado - ID: ', NEW.ID, '. Cambios: ', IF(COALESCE(cambios,'')='', 'Sin cambios', cambios)));
END$$

CREATE TRIGGER `trg_products_after_delete` AFTER DELETE ON `tb_products` FOR EACH ROW
BEGIN
    INSERT INTO `tb_logs` (`table_name`, `operation`, `db_user`, `description`)
    VALUES ('tb_products', 'Delete', USER(), CONCAT('Producto eliminado - ID: ', OLD.ID, ', SKU: ', OLD.SKU));
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- 7. Vistas
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW `vw_users` AS
SELECT ID, email, nickname, creation_date, last_update, last_login
FROM tb_users;

CREATE OR REPLACE VIEW `vw_categories` AS
SELECT ID, name, description, status, creation_date, last_update
FROM tb_categories;

CREATE OR REPLACE VIEW `vw_products` AS
SELECT
    p.ID,
    p.SKU,
    p.name,
    p.description,
    p.current_price,
    p.current_stock,
    p.status,
    c.ID   AS category_id,
    c.name AS category_name,
    p.creation_date,
    p.last_update
FROM tb_products p
LEFT JOIN tb_categories c ON p.category_id = c.ID;

CREATE OR REPLACE VIEW `vw_logs` AS
SELECT ID, table_name, operation, db_user, description, operation_date, operation_status
FROM tb_logs;
-- ------------------------------------------------------------
-- 8. Reactivar comprobaciones
-- ------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;