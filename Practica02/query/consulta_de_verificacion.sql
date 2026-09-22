/* PRACTICA 02 - Emigdio 240545 Puerto 40545 - FINAL CORREGIDO */
USE db_test;
CREATE USER IF NOT EXISTS 'emigdio.aguirre'@'%' IDENTIFIED BY '240545';
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'adrian.gonzalez'@'%' IDENTIFIED BY '240XXX';
CREATE USER IF NOT EXISTS 'ivan.alejandro'@'%' IDENTIFIED BY '240XXX';

ALTER USER 'emigdio.aguirre'@'%' IDENTIFIED BY '240545';
ALTER USER 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
ALTER USER 'adrian.gonzalez'@'%' IDENTIFIED BY '240XXX';
ALTER USER 'ivan.alejandro'@'%' IDENTIFIED BY '240XXX';

CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'support';
CREATE ROLE IF NOT EXISTS 'common';
CREATE ROLE IF NOT EXISTS 'user_not_registered';

/* PRIVILEGIOS CORREGIDOS - ESTO ES LO QUE CHECA MARCO */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin';
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'support';
GRANT SELECT ON db_test.tb_logs TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';
GRANT SELECT ON db_test.tb_logs TO 'seller';
GRANT SELECT ON db_test.tb_products TO 'buyer';
GRANT SELECT ON db_test.tb_products TO 'common';
GRANT SELECT ON db_test.tb_products TO 'user_not_registered';

GRANT 'superadmin' TO 'emigdio.aguirre'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'adrian.gonzalez'@'%';
GRANT 'seller' TO 'ivan.alejandro'@'%';

SET DEFAULT ROLE 'superadmin' TO 'emigdio.aguirre'@'%';
SET DEFAULT ROLE 'admin' TO 'marco.ramirez'@'%';
SET DEFAULT ROLE 'support' TO 'adrian.gonzalez'@'%';
SET DEFAULT ROLE 'seller' TO 'ivan.alejandro'@'%';
FLUSH PRIVILEGES;