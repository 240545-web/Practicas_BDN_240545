DELIMITER $$

CREATE TRIGGER trg_persons_ai AFTER INSERT ON tb_persons FOR EACH ROW
BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_persons', 'Create', USER(), CONCAT('Nueva persona ID: ', NEW.person_ID)); END$$

CREATE TRIGGER trg_persons_au AFTER UPDATE ON tb_persons FOR EACH ROW
BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_persons', 'Update', USER(), CONCAT('Persona modificada ID: ', NEW.person_ID)); END$$

CREATE TRIGGER trg_persons_ad AFTER DELETE ON tb_persons FOR EACH ROW
BEGIN INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES ('tb_persons', 'Delete', USER(), CONCAT('Persona eliminada ID: ', OLD.person_ID)); END$$

DELIMITER ;