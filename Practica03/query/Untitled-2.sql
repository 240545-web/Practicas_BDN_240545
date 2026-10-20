/* ============================================================
   PRÁCTICA 03 - USUARIOS REMOTOS, PRIVILEGIOS Y ROLES
 TablesTables
   Base de datos: db_test
   ============================================================ */

USE db_test;

/* ============================================================
   1. CREACIÓN DE USUARIOS REMOTOS - 4 USUARIOS REALES
   ============================================================ */
DROP USER IF EXISTS 'emigdio.aguirre'@'%';
DROP USER IF EXISTS 'marco.ramirez'@'%';
DROP USER IF EXISTS 'jose.luis'@'%';
DROP USER IF EXISTS 'adrian.gonzales'@'%';

CREATE USER 'emigdio.aguirre'@'%' IDENTIFIED BY '240545';   -- Tú Superadmin
CREATE USER 'marco.ramirez'@'%'   IDENTIFIED BY 'qwerty123'; -- Profe Admin
CREATE USER 'jose.luis'@'%'       IDENTIFIED BY '240480';    -- Support
CREATE USER 'adrian.gonzales'@'%'    IDENTIFIED BY '240784';    -- Seller

/* ============================================================
   2. ACTUALIZACIÓN DE CONTRASEÑAS (por si ya existían)
   ============================================================ */
ALTER USER 'emigdio.aguirre'@'%' IDENTIFIED BY '240545';
ALTER USER 'marco.ramirez'@'%'   IDENTIFIED BY 'qwerty123';
ALTER USER 'jose.luis'@'%'       IDENTIFIED BY '240480';    -- Support
ALTER USER 'adrian.gonzales'@'%'    IDENTIFIED BY '240784';

/* ============================================================
   3. CREACIÓN DE ROLES
   ============================================================ */
DROP ROLE IF EXISTS 'superadmin';
DROP ROLE IF EXISTS 'admin';
DROP ROLE IF EXISTS 'seller';
DROP ROLE IF EXISTS 'support';
DROP ROLE IF EXISTS 'buyer';
DROP ROLE IF EXISTS 'user_not_registered';

CREATE ROLE 'superadmin';
CREATE ROLE 'admin';
CREATE ROLE 'seller';
CREATE ROLE 'support';
CREATE ROLE 'buyer';
CREATE ROLE 'user_not_registered';

/* ============================================================
   4. PRIVILEGIOS SUPERADMIN - Control total del servidor
   ============================================================ */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin' WITH GRANT OPTION;

/* ============================================================
   5. PRIVILEGIOS ADMIN - Control total sobre db_test
   ============================================================ */
GRANT ALL PRIVILEGES ON db_test.* TO 'admin';

/* ============================================================
   6. PRIVILEGIOS SUPPORT - Atención al cliente
   - Lee todo (tablas + vistas)
   - Actualiza usuarios (email, nickname, last_login)
   - Inserta en logs
   - NO modifica productos
   ============================================================ */
-- Lectura general
GRANT SELECT ON db_test.tb_users        TO 'support';
GRANT SELECT ON db_test.tb_products     TO 'support';
GRANT SELECT ON db_test.tb_categories   TO 'support';
GRANT SELECT ON db_test.tb_logs         TO 'support';

-- Lectura de vistas
GRANT SELECT ON db_test.vw_users        TO 'support';
GRANT SELECT ON db_test.vw_products     TO 'support';
GRANT SELECT ON db_test.vw_categories   TO 'support';
GRANT SELECT ON db_test.vw_logs         TO 'support';

-- Actualización de columnas específicas de usuarios
GRANT UPDATE (email, nickname, last_login) ON db_test.tb_users TO 'support';

-- Inserción de notas en logs
GRANT INSERT ON db_test.tb_logs TO 'support';

/* ============================================================
   7. PRIVILEGIOS SELLER - Vendedor
   - Gestiona productos y stock
   - NO puede eliminar
   - NO accede a usuarios
   ============================================================ */
GRANT SELECT ON db_test.tb_products    TO 'seller';
GRANT SELECT ON db_test.tb_categories  TO 'seller';
GRANT SELECT ON db_test.vw_products    TO 'seller';
GRANT SELECT ON db_test.vw_categories  TO 'seller';

GRANT INSERT ON db_test.tb_products    TO 'seller';
GRANT UPDATE (name, description, category_id, current_price, current_stock, status)
ON db_test.tb_products TO 'seller';

/* ============================================================
   8. PRIVILEGIOS BUYER - Comprador registrado
   - Solo lectura del catálogo (tablas + vistas)
   - NO toca usuarios ni logs
   ============================================================ */
GRANT SELECT ON db_test.tb_products    TO 'buyer';
GRANT SELECT ON db_test.tb_categories  TO 'buyer';
GRANT SELECT ON db_test.vw_products    TO 'buyer';
GRANT SELECT ON db_test.vw_categories  TO 'buyer';

/* ============================================================
   9. PRIVILEGIOS USER_NOT_REGISTERED - Visitante anónimo
   - Solo vistas públicas del catálogo
   ============================================================ */
GRANT SELECT ON db_test.vw_products    TO 'user_not_registered';
GRANT SELECT ON db_test.vw_categories  TO 'user_not_registered';

/* ============================================================
   10. ASIGNACIÓN DE ROLES A USUARIOS
   ============================================================ */
GRANT 'superadmin' TO 'emigdio.aguirre'@'%';   -- Emigdio 240545
GRANT 'admin'      TO 'marco.ramirez'@'%';     -- Profe Marco
GRANT 'support'    TO 'jose.luis'@'%';         -- Alan 240516
GRANT 'seller'     TO 'adrian.gonzales'@'%';      -- Bryan 240078

/* ============================================================
   11. ACTIVAR ROLES POR DEFECTO
   ============================================================ */
SET DEFAULT ROLE 'superadmin' TO 'emigdio.aguirre'@'%';
SET DEFAULT ROLE 'admin'      TO 'marco.ramirez'@'%';
SET DEFAULT ROLE 'support'    TO 'jose.luis'@'%';
SET DEFAULT ROLE 'seller'     TO 'adrian.gonzales'@'%';

/* ============================================================
   12. APLICAR CAMBIOS
   ============================================================ */
FLUSH PRIVILEGES;

/* ============================================================
   13. VERIFICACIÓN - Usuarios creados
   ============================================================ */
SELECT user AS Usuario, host AS Host FROM mysql.user
WHERE user IN ('emigdio.aguirre','marco.ramirez','jose.luis','adrian.gonzales')
ORDER BY user;

/* ============================================================
   14. VERIFICACIÓN - Roles creados
   ============================================================ */
SELECT DISTINCT FROM_USER AS Rol FROM mysql.role_edges
ORDER BY Rol;

/* ============================================================
   15. VERIFICACIÓN - Asignación Rol → Usuario
   ============================================================ */
SELECT FROM_USER AS Rol, TO_USER AS Usuario, TO_HOST AS Host
FROM mysql.role_edges
WHERE TO_USER IN ('emigdio.aguirre','marco.ramirez','jose.luis','adrian.gonzales')
ORDER BY Rol;

/* ============================================================
   16. VERIFICACIÓN - Privilegios por rol
   ============================================================ */
SELECT '=== GRANTS superadmin ===' AS seccion;
SHOW GRANTS FOR 'superadmin';

SELECT '=== GRANTS admin ===' AS seccion;
SHOW GRANTS FOR 'admin';

SELECT '=== GRANTS support ===' AS seccion;
SHOW GRANTS FOR 'support';

SELECT '=== GRANTS seller ===' AS seccion;
SHOW GRANTS FOR 'seller';

SELECT '=== GRANTS buyer ===' AS seccion;
SHOW GRANTS FOR 'buyer';

SELECT '=== GRANTS user_not_registered ===' AS seccion;
SHOW GRANTS FOR 'user_not_registered';

/* ============================================================
   17. VERIFICACIÓN - Grants efectivos por usuario
   ============================================================ */
SELECT '=== GRANTS EMIGDIO (superadmin) ===' AS seccion;
SHOW GRANTS FOR 'emigdio.aguirre'@'%';

SELECT '=== GRANTS MARCO (admin) ===' AS seccion;
SHOW GRANTS FOR 'marco.ramirez'@'%';

SELECT '=== GRANTS ALAN (support) ===' AS seccion;
SHOW GRANTS FOR 'jose.luis'@'%';

SELECT '=== GRANTS BRYAN (seller) ===' AS seccion;
SHOW GRANTS FOR 'adrian.gonzales'@'%';

/* ============================================================
   18. REPORTE FINAL
   ============================================================ */
SELECT 'SCRIPT EJECUTADO CORRECTAMENTE - Emigdio Aguirre 240545 Puerto 40545' AS Resultado;

/* ============================================================
   19. SCRIPT DE REVOCACIÓN (para re-ejecutar limpio)
   ============================================================
   REVOKE ALL PRIVILEGES ON *.* FROM 'superadmin';
   REVOKE ALL PRIVILEGES ON db_test.* FROM 'admin';
   DROP ROLE IF EXISTS 'superadmin','admin','seller','support','buyer','user_not_registered';
   DROP USER IF EXISTS 'emigdio.aguirre'@'%','marco.ramirez'@'%','jose.luis'@'%','adrian.gonzales'@'%';
   FLUSH PRIVILEGES;
   ============================================================ */