USE db_test;

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

CREATE TRIGGER trg_users_after_insert
AFTER INSERT ON tb_users FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_users', 'Create', USER(),
            CONCAT('Usuario creado. ID=', NEW.ID, ', email=', NEW.email));
END$$

CREATE TRIGGER trg_users_after_update
AFTER UPDATE ON tb_users FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_users', 'Update', USER(),
            CONCAT('Usuario actualizado. ID=', NEW.ID));
END$$

CREATE TRIGGER trg_users_after_delete
AFTER DELETE ON tb_users FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_users', 'Delete', USER(),
            CONCAT('Usuario eliminado. ID=', OLD.ID));
END$$

CREATE TRIGGER trg_users_before_delete
BEFORE DELETE ON tb_users FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE fisico bloqueado en tb_users. Usa CALL sp_soft_delete_user(ID).';
END$$

CREATE TRIGGER trg_products_after_insert
AFTER INSERT ON tb_products FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_products', 'Create', USER(),
            CONCAT('Producto creado. ID=', NEW.ID, ', SKU=', NEW.SKU));
END$$

CREATE TRIGGER trg_products_after_update
AFTER UPDATE ON tb_products FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_products', 'Update', USER(),
            CONCAT('Producto actualizado. ID=', NEW.ID, ', SKU=', NEW.SKU));
END$$

CREATE TRIGGER trg_products_after_delete
AFTER DELETE ON tb_products FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_products', 'Delete', USER(),
            CONCAT('Producto eliminado. ID=', OLD.ID, ', SKU=', OLD.SKU));
END$$

CREATE TRIGGER trg_products_before_delete
BEFORE DELETE ON tb_products FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE fisico bloqueado en tb_products. Usa CALL sp_soft_delete_product(ID).';
END$$

CREATE TRIGGER trg_categories_after_insert
AFTER INSERT ON tb_categories FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_categories', 'Create', USER(),
            CONCAT('Categoria creada. ID=', NEW.ID, ', nombre=', NEW.name));
END$$

CREATE TRIGGER trg_categories_after_update
AFTER UPDATE ON tb_categories FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_categories', 'Update', USER(),
            CONCAT('Categoria actualizada. ID=', NEW.ID, ', nombre=', NEW.name));
END$$

CREATE TRIGGER trg_categories_after_delete
AFTER DELETE ON tb_categories FOR EACH ROW
BEGIN
    INSERT INTO tb_logs (table_name, operation, db_user, description)
    VALUES ('tb_categories', 'Delete', USER(),
            CONCAT('Categoria eliminada. ID=', OLD.ID, ', nombre=', OLD.name));
END$$

CREATE TRIGGER trg_categories_before_delete
BEFORE DELETE ON tb_categories FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE fisico bloqueado en tb_categories. Usa CALL sp_soft_delete_category(ID).';
END$$

DELIMITER ;

SHOW TRIGGERS FROM db_test;