/* ============================================================
   PRÁCTICA 02 - USUARIOS REMOTOS, PRIVILEGIOS Y ROLES
   Alumno: Emigdio Aguirre - 240545 - Puerto: 40545
   Base de datos: db_test
   ============================================================ */

USE db_test;

/* ============================================================
   1. CREACIÓN DE USUARIOS REMOTOS
   ============================================================ */
CREATE USER IF NOT EXISTS 'emigdio.aguirre'@'%' IDENTIFIED BY '240545';
CREATE USER IF NOT EXISTS 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER IF NOT EXISTS 'adrian.gonzalez'@'%' IDENTIFIED BY '240XXX';
CREATE USER IF NOT EXISTS 'ivan.alejandro'@'%' IDENTIFIED BY '240XXX';

ALTER USER 'emigdio.aguirre'@'%' IDENTIFIED BY '240545';
ALTER USER 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
ALTER USER 'adrian.gonzalez'@'%' IDENTIFIED BY '240XXX';
ALTER USER 'ivan.alejandro'@'%' IDENTIFIED BY '240XXX';

/* ============================================================
   2. CREACIÓN DE ROLES
   ============================================================ */
CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'support';
CREATE ROLE IF NOT EXISTS 'common';
CREATE ROLE IF NOT EXISTS 'user_not_registered';

/* ============================================================
   3. PRIVILEGIOS DE LOS ROLES
   ============================================================ */
GRANT ALL PRIVILEGES ON . TO 'superadmin';
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';

GRANT SELECT, INSERT, UPDATE ON db_test.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'support';
GRANT SELECT ON db_test.tb_logs TO 'support';

GRANT SELECT, INSERT, UPDATE ON db_test.tb_products TO 'seller';
GRANT SELECT ON db_test.tb_logs TO 'seller';

GRANT SELECT ON db_test.tb_products TO 'buyer';
GRANT SELECT ON db_test.tb_products TO 'common';
GRANT SELECT ON db_test.tb_products TO 'user_not_registered';

/* ============================================================
   4. ASIGNACIÓN DE ROLES A USUARIOS
   ============================================================ */
GRANT 'superadmin' TO 'emigdio.aguirre'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'adrian.gonzalez'@'%';
GRANT 'seller' TO 'ivan.alejandro'@'%';

SET DEFAULT ROLE 'superadmin' TO 'emigdio.aguirre'@'%';
SET DEFAULT ROLE 'admin' TO 'marco.ramirez'@'%';
SET DEFAULT ROLE 'support' TO 'adrian.gonzalez'@'%';
SET DEFAULT ROLE 'seller' TO 'ivan.alejandro'@'%';

FLUSH PRIVILEGES;

/* ============================================================
   5. VERIFICACIÓN DE ROLES Y PRIVILEGIOS
   ============================================================ */
SELECT user AS Usuario, host AS Host FROM mysql.user 
WHERE user IN ('emigdio.aguirre','marco.ramirez','adrian.gonzalez','ivan.alejandro') ORDER BY user;

SELECT FROM_USER AS Rol, TO_USER AS Usuario FROM mysql.role_edges 
WHERE TO_USER IN ('emigdio.aguirre','marco.ramirez','adrian.gonzalez','ivan.alejandro') ORDER BY FROM_USER;

SHOW GRANTS FOR 'superadmin';
SHOW GRANTS FOR 'admin';
SHOW GRANTS FOR 'support';
SHOW GRANTS FOR 'seller';

SHOW GRANTS FOR 'emigdio.aguirre'@'%';
SHOW GRANTS FOR 'marco.ramirez'@'%';
SHOW GRANTS FOR 'adrian.gonzalez'@'%';
SHOW GRANTS FOR 'ivan.alejandro'@'%';

/* ============================================================
   6. CONSULTA DE AUDITORÍA CORREGIDA (LO QUE ESTÁ EN TU PANTALLA)
   ============================================================ */
/* 1. ¿Cuántos triggers existen en la base de datos db_test? */
SHOW TRIGGERS FROM db_test;

/* 2. ¿Cuántos registros existen en la tabla users? */
SELECT COUNT(*) AS total_registros FROM tb_users;

/* 3. Visualización de los Usuarios */
SELECT * FROM tb_users;

/* 4. Consulta para verificar qué usuario de la base de datos realizó la acción */
SELECT 
    u.nickname AS Nickname,
    u.email AS Email,
    b.db_user AS Inserted_by,
    GROUP_CONCAT(DISTINCT re.FROM_USER ORDER BY re.FROM_USER SEPARATOR ', ') AS roles,
    b.operation AS Operacion,
    b.description AS Descripcion,
    b.operation_date AS Fecha
FROM tb_users u
JOIN tb_logs b
    -- CORRECCIONES APLICADAS AQUÍ:
    ON b.description LIKE CONCAT('%', u.nickname, '%')
    AND b.description LIKE CONCAT('%', u.email, '%')
LEFT JOIN mysql.role_edges re
    ON re.TO_USER = SUBSTRING_INDEX(b.db_user, '@', 1)
WHERE b.operation = 'Create' -- Antes decía b.table_operation
  AND b.table_name = 'tb_users'
GROUP BY u.nickname, u.email, b.db_user, b.operation, b.description, b.operation_date
ORDER BY b.operation_date ASC;

SELECT 'SCRIPT EJECUTADO CORRECTAMENTE - Emigdio Aguirre 240545 Puerto 40545' AS Resultado;