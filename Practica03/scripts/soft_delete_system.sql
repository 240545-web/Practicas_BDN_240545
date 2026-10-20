-- ============================================================
-- SOFT DELETE - tb_users, tb_products, tb_categories
-- Práctica 03 - Emigdio Aguirre 240545
-- Base de datos: db_test
-- ============================================================

USE db_test;

-- ============================================================
-- 1. AGREGAR COLUMNA deleted_at A CADA TABLA
-- ============================================================
ALTER TABLE tb_users
    ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL AFTER last_login,
    ADD INDEX idx_users_deleted_at (deleted_at);

ALTER TABLE tb_products
    ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL AFTER last_update,
    ADD INDEX idx_products_deleted_at (deleted_at);

ALTER TABLE tb_categories
    ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL AFTER last_update,
    ADD INDEX idx_categories_deleted_at (deleted_at);

-- ============================================================
-- 2. PROCEDIMIENTOS DE SOFT DELETE
-- ============================================================
DROP PROCEDURE IF EXISTS sp_soft_delete_user;
DROP PROCEDURE IF EXISTS sp_soft_delete_product;
DROP PROCEDURE IF EXISTS sp_soft_delete_category;
DROP PROCEDURE IF EXISTS sp_restore_user;
DROP PROCEDURE IF EXISTS sp_restore_product;
DROP PROCEDURE IF EXISTS sp_restore_category;

DELIMITER $$

-- ---------- USUARIOS ----------
CREATE PROCEDURE sp_soft_delete_user(IN p_id INT)
BEGIN
    IF (SELECT deleted_at FROM tb_users WHERE ID = p_id) IS NULL THEN
        UPDATE tb_users SET deleted_at = NOW() WHERE ID = p_id;

        INSERT INTO tb_logs (table_name, operation, db_user, description)
        VALUES ('tb_users', 'Delete', USER(),
                CONCAT('Soft delete usuario ID=', p_id));
    END IF;
END$$

CREATE PROCEDURE sp_restore_user(IN p_id INT)
BEGIN
    IF (SELECT deleted_at FROM tb_users WHERE ID = p_id) IS NOT NULL THEN
        UPDATE tb_users SET deleted_at = NULL WHERE ID = p_id;

        INSERT INTO tb_logs (table_name, operation, db_user, description)
        VALUES ('tb_users', 'Update', USER(),
                CONCAT('Restore usuario ID=', p_id));
    END IF;
END$$

-- ---------- PRODUCTOS ----------
CREATE PROCEDURE sp_soft_delete_product(IN p_id INT)
BEGIN
    IF (SELECT deleted_at FROM tb_products WHERE ID = p_id) IS NULL THEN
        UPDATE tb_products SET deleted_at = NOW() WHERE ID = p_id;

        INSERT INTO tb_logs (table_name, operation, db_user, description)
        VALUES ('tb_products', 'Delete', USER(),
                CONCAT('Soft delete producto ID=', p_id));
    END IF;
END$$

CREATE PROCEDURE sp_restore_product(IN p_id INT)
BEGIN
    IF (SELECT deleted_at FROM tb_products WHERE ID = p_id) IS NOT NULL THEN
        UPDATE tb_products SET deleted_at = NULL WHERE ID = p_id;

        INSERT INTO tb_logs (table_name, operation, db_user, description)
        VALUES ('tb_products', 'Update', USER(),
                CONCAT('Restore producto ID=', p_id));
    END IF;
END$$

-- ---------- CATEGORÍAS ----------
CREATE PROCEDURE sp_soft_delete_category(IN p_id INT)
BEGIN
    IF (SELECT deleted_at FROM tb_categories WHERE ID = p_id) IS NULL THEN
        UPDATE tb_categories SET deleted_at = NOW() WHERE ID = p_id;

        INSERT INTO tb_logs (table_name, operation, db_user, description)
        VALUES ('tb_categories', 'Delete', USER(),
                CONCAT('Soft delete categoría ID=', p_id));
    END IF;
END$$

CREATE PROCEDURE sp_restore_category(IN p_id INT)
BEGIN
    IF (SELECT deleted_at FROM tb_categories WHERE ID = p_id) IS NOT NULL THEN
        UPDATE tb_categories SET deleted_at = NULL WHERE ID = p_id;

        INSERT INTO tb_logs (table_name, operation, db_user, description)
        VALUES ('tb_categories', 'Update', USER(),
                CONCAT('Restore categoría ID=', p_id));
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- 3. TRIGGERS QUE BLOQUEAN EL DELETE FÍSICO
-- ============================================================
DROP TRIGGER IF EXISTS trg_users_before_delete;
DROP TRIGGER IF EXISTS trg_products_before_delete;
DROP TRIGGER IF EXISTS trg_categories_before_delete;

DELIMITER $$

CREATE TRIGGER trg_users_before_delete
BEFORE DELETE ON tb_users FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado. Usa CALL sp_soft_delete_user(ID).';
END$$

CREATE TRIGGER trg_products_before_delete
BEFORE DELETE ON tb_products FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado. Usa CALL sp_soft_delete_product(ID).';
END$$

CREATE TRIGGER trg_categories_before_delete
BEFORE DELETE ON tb_categories FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado. Usa CALL sp_soft_delete_category(ID).';
END$$

DELIMITER ;

-- ============================================================
-- 4. VISTAS ACTUALIZADAS (solo registros activos)
-- ============================================================
CREATE OR REPLACE VIEW vw_users AS
SELECT ID, email, nickname, creation_date, last_update, last_login
FROM tb_users
WHERE deleted_at IS NULL;

CREATE OR REPLACE VIEW vw_products AS
SELECT
    p.ID, p.SKU, p.name, p.description,
    p.current_price, p.current_stock, p.status,
    c.ID AS category_id, c.name AS category_name,
    p.creation_date, p.last_update
FROM tb_products p
LEFT JOIN tb_categories c ON p.category_id = c.ID
WHERE p.deleted_at IS NULL
  AND (c.deleted_at IS NULL OR c.ID IS NULL);

CREATE OR REPLACE VIEW vw_categories AS
SELECT ID, name, description, status, creation_date, last_update
FROM tb_categories
WHERE deleted_at IS NULL;

-- Vistas para ADMIN (incluyen eliminados)
CREATE OR REPLACE VIEW vw_users_all AS
SELECT ID, email, nickname, creation_date, last_update, last_login, deleted_at
FROM tb_users;

CREATE OR REPLACE VIEW vw_products_all AS
SELECT
    p.ID, p.SKU, p.name, p.description,
    p.current_price, p.current_stock, p.status,
    c.ID AS category_id, c.name AS category_name,
    p.creation_date, p.last_update, p.deleted_at
FROM tb_products p
LEFT JOIN tb_categories c ON p.category_id = c.ID;

CREATE OR REPLACE VIEW vw_categories_all AS
SELECT ID, name, description, status, creation_date, last_update, deleted_at
FROM tb_categories;Triggers