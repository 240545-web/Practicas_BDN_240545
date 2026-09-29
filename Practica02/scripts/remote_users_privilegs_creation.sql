/* ============================================================
   PRÁCTICA 02 - USUARIOS REMOTOS, PRIVILEGIOS Y ROLES
   Alumno: Emigdio Aguirre - 240545 - Puerto: 40545
   Base de datos: db_test
   ============================================================ */

USE db_test;

/* ============================================================
   1. CREACIÓN DE USUARIOS REMOTOS - TUS 4 USUARIOS REALES
   ============================================================ */
CREATE USER IF NOT EXISTS 'emigdio.aguirre'@'%' IDENTIFIED BY '240545'; -- Tú Superadmin
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123'; -- Profe Admin
CREATE USER IF NOT EXISTS 'alan.cruz'@'%' IDENTIFIED BY '240516'; -- Support
CREATE USER IF NOT EXISTS 'bryan.javier'@'%' IDENTIFIED BY '240078'; -- Seller

/* ============================================================
   2. ACTUALIZACIÓN DE CONTRASEÑAS
   ============================================================ */
ALTER USER 'emigdio.aguirre'@'%' IDENTIFIED BY '240545';
ALTER USER 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
ALTER USER 'alan.cruz'@'%' IDENTIFIED BY '240516';
ALTER USER 'bryan.javier'@'%' IDENTIFIED BY '240078';

/* ============================================================
   3. CREACIÓN DE ROLES
   ============================================================ */
CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'support';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'user_not_registered';

/* ============================================================
   4. PRIVILEGIOS SUPERADMIN - CORREGIDO *.*
   ============================================================ */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin';

/* ============================================================
   5. PRIVILEGIOS ADMIN
   ============================================================ */
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';

/* ============================================================
   6. PRIVILEGIOS SUPPORT
   ============================================================ */
GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'support';
GRANT SELECT ON db_test.tb_logs TO 'support';

/* ============================================================
   7. PRIVILEGIOS SELLER
   ============================================================ */
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';
GRANT SELECT ON db_test.tb_logs TO 'seller';

/* ============================================================
   8. PRIVILEGIOS USER_NOT_REGISTERED
   ============================================================ */
GRANT SELECT ON db_test.tb_products TO 'user_not_registered';

/* ============================================================
   9. ASIGNACIÓN DE ROLES
   ============================================================ */
GRANT 'superadmin' TO 'emigdio.aguirre'@'%'; -- Tú 240545
GRANT 'admin' TO 'marco.ramirez'@'%'; -- Profe Marco
GRANT 'support' TO 'alan.cruz'@'%'; -- Alan 240516
GRANT 'seller' TO 'bryan.javier'@'%'; -- Bryan 240078

/* ============================================================
   10. ACTIVAR ROLES POR DEFECTO
   ============================================================ */
SET DEFAULT ROLE 'superadmin' TO 'emigdio.aguirre'@'%';
SET DEFAULT ROLE 'admin' TO 'marco.ramirez'@'%';
SET DEFAULT ROLE 'support' TO 'alan.cruz'@'%';
SET DEFAULT ROLE 'seller' TO 'bryan.javier'@'%';

/* ============================================================
   11. APLICAR CAMBIOS
   ============================================================ */
FLUSH PRIVILEGES;

/* ============================================================
   12. VERIFICACIÓN - Esto es lo que te pide Marco
   ============================================================ */
SELECT user AS Usuario, host AS Host FROM mysql.user 
WHERE user IN ('emigdio.aguirre','marco.ramirez','alan.cruz','bryan.javier') ORDER BY user;

SELECT FROM_USER AS Rol, TO_USER AS Usuario FROM mysql.role_edges 
WHERE TO_USER IN ('emigdio.aguirre','marco.ramirez','alan.cruz','bryan.javier') ORDER BY FROM_USER;

SHOW GRANTS FOR 'superadmin';
SHOW GRANTS FOR 'admin';
SHOW GRANTS FOR 'support';
SHOW GRANTS FOR 'seller';

SHOW GRANTS FOR 'emigdio.aguirre'@'%';
SHOW GRANTS FOR 'marco.ramirez'@'%';
SHOW GRANTS FOR 'alan.cruz'@'%';
SHOW GRANTS FOR 'bryan.javier'@'%';

SELECT 'SCRIPT EJECUTADO CORRECTAMENTE - Emigdio Aguirre 240545 Puerto 40545' AS Resultado;