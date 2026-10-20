-- ============================================================
-- TRIGGERS DE AUDITORÍA Y SOFT DELETE
-- Práctica 03 - Emigdio Aguirre 240545
-- Base de datos: db_test
-- ============================================================

USE db_test;

-- ============================================================
-- LIMPIAR TRIGGERS EXISTENTES
-- ============================================================
DROP TRIGGER IF EXISTS trg_users_after_insert;
DROP TRIGGER IF EXISTS trg_users_after_update;
DROP TRIGGER IF EXISTS trg_users_after_delete;
DROP TRIGGER IF EXISTS trg_users_before_delete;

DROP TRIGGER IF EXISTS trg_products_after_insert;
DROP TRIGGER IF EXISTS trg_products_after_update;
DROP TRIGGER IF EXISTS trg_products_after_delete;
DROP TRIGGER IF EXISTS trg_products_before_delete;

DROP TRIGGER IF EXISTS trg_categories_after_insert;
DROP TRIGGER IF EXISTS trg_categories_after_update;
DROP TRIGGER IF EXISTS trg_categories_after_delete;
DROP TRIGGER IF EXISTS trg_categories_before_delete;

DELIMITER $$

-- ============================================================
-- TRIGGERS: tb_users
-- ============================================================

CREATE TRIGGER trg_users_after_insert
AFTER INSERT ON tb_users FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_users', 'Create', USER(),
            CONCAT('Usuario creado. ID=', NEW.ID,
                   ', email=', NEW.email,
                   ', nickname=', NEW.nickname));
END$$

CREATE TRIGGER trg_users_after_update
AFTER UPDATE ON tb_users FOR EACH ROW
BEGIN
    DECLARE cambios TEXT;
    SET cambios = CONCAT_WS(', ',
        IF(NOT (OLD.email <=> NEW.email),
           CONCAT('email: [', OLD.email, '] -> [', NEW.email, ']'), NULL),
        IF(NOT (OLD.nickname <=> NEW.nickname),
           CONCAT('nickname: [', OLD.nickname, '] -> [', NEW.nickname, ']'), NULL),
        IF(NOT (OLD.last_login <=> NEW.last_login),
           CONCAT('last_login: [', OLD.last_login, '] -> [', NEW.last_login, ']'), NULL),
        IF(NOT (OLD.deleted_at <=> NEW.deleted_at),
           CONCAT('deleted_at: [', OLD.deleted_at, '] -> [', NEW.deleted_at, ']'), NULL)
    );

    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_users', 'Update', USER(),
            CONCAT('Usuario actualizado. ID=', NEW.ID,
                   '. Cambios: ',
                   IF(COALESCE(cambios,'') = '', 'Sin cambios', cambios)));
END$$

CREATE TRIGGER trg_users_after_delete
AFTER DELETE ON tb_users FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_users', 'Delete', USER(),
            CONCAT('Usuario eliminado físicamente. ID=', OLD.ID,
                   ', email=', OLD.email));
END$$

CREATE TRIGGER trg_users_before_delete
BEFORE DELETE ON tb_users FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_users. Usa CALL sp_soft_delete_user(ID).';
END$$


-- ============================================================
-- TRIGGERS: tb_products
-- ============================================================

CREATE TRIGGER trg_products_after_insert
AFTER INSERT ON tb_products FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_products', 'Create', USER(),
            CONCAT('Producto creado. ID=', NEW.ID,
                   ', SKU=', NEW.SKU,
                   ', nombre=', NEW.name));
END$$

CREATE TRIGGER trg_products_after_update
AFTER UPDATE ON tb_products FOR EACH ROW
BEGIN
    DECLARE cambios TEXT;
    SET cambios = CONCAT_WS(', ',
        IF(NOT (OLD.name <=> NEW.name),
           CONCAT('nombre: [', OLD.name, '] -> [', NEW.name, ']'), NULL),
        IF(NOT (OLD.current_price <=> NEW.current_price),
           CONCAT('precio: [', OLD.current_price, '] -> [', NEW.current_price, ']'), NULL),
        IF(NOT (OLD.current_stock <=> NEW.current_stock),
           CONCAT('stock: [', OLD.current_stock, '] -> [', NEW.current_stock, ']'), NULL),
        IF(NOT (OLD.category_id <=> NEW.category_id),
           CONCAT('categoría: [', OLD.category_id, '] -> [', NEW.category_id, ']'), NULL),
        IF(NOT (OLD.status <=> NEW.status),
           CONCAT('status: [', OLD.status, '] -> [', NEW.status, ']'), NULL),
        IF(NOT (OLD.deleted_at <=> NEW.deleted_at),
           CONCAT('deleted_at: [', OLD.deleted_at, '] -> [', NEW.deleted_at, ']'), NULL)
    );

    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_products', 'Update', USER(),
            CONCAT('Producto actualizado. ID=', NEW.ID,
                   ', SKU=', NEW.SKU,
                   '. Cambios: ',
                   IF(COALESCE(cambios,'') = '', 'Sin cambios', cambios)));
END$$

CREATE TRIGGER trg_products_after_delete
AFTER DELETE ON tb_products FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_products', 'Delete', USER(),
            CONCAT('Producto eliminado físicamente. ID=', OLD.ID,
                   ', SKU=', OLD.SKU));
END$$

CREATE TRIGGER trg_products_before_delete
BEFORE DELETE ON tb_products FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_products. Usa CALL sp_soft_delete_product(ID).';
END$$


-- ============================================================
-- TRIGGERS: tb_categories
-- ============================================================

CREATE TRIGGER trg_categories_after_insert
AFTER INSERT ON tb_categories FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_categories', 'Create', USER(),
            CONCAT('Categoría creada. ID=', NEW.ID,
                   ', nombre=', NEW.name));
END$$

CREATE TRIGGER trg_categories_after_update
AFTER UPDATE ON tb_categories FOR EACH ROW
BEGIN
    DECLARE cambios TEXT;
    SET cambios = CONCAT_WS(', ',
        IF(NOT (OLD.name <=> NEW.name),
           CONCAT('nombre: [', OLD.name, '] -> [', NEW.name, ']'), NULL),
        IF(NOT (OLD.description <=> NEW.description),
           CONCAT('descripción modificada'), NULL),
        IF(NOT (OLD.status <=> NEW.status),
           CONCAT('status: [', OLD.status, '] -> [', NEW.status, ']'), NULL),
        IF(NOT (OLD.deleted_at <=> NEW.deleted_at),
           CONCAT('deleted_at: [', OLD.deleted_at, '] -> [', NEW.deleted_at, ']'), NULL)
    );

    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_categories', 'Update', USER(),
            CONCAT('Categoría actualizada. ID=', NEW.ID,
                   ', nombre=', NEW.name,
                   '. Cambios: ',
                   IF(COALESCE(cambios,'') = '', 'Sin cambios', cambios)));
END$$

CREATE TRIGGER trg_categories_after_delete
AFTER DELETE ON tb_categories FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_categories', 'Delete', USER(),
            CONCAT('Categoría eliminada físicamente. ID=', OLD.ID,
                   ', nombre=', OLD.name));
END$$

CREATE TRIGGER trg_categories_before_delete
BEFORE DELETE ON tb_categories FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado en tb_categories. Usa CALL sp_soft_delete_category(ID).';
END$$

DELIMITER ;

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
SELECT '=== TRIGGERS CREADOS ===' AS seccion;

SELECT
    TRIGGER_NAME AS Trigger,
    EVENT_MANIPULATION AS Evento,
    EVENT_OBJECT_TABLE AS Tabla,
    ACTION_TIMING AS Momento
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'db_test'
ORDER BY EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION;