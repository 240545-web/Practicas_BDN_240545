-- ============================================================
-- PRÁCTICA 03 - USUARIOS REMOTOS Y PRIVILEGIOS (7A)
-- Alumno: Emigdio Aguirre
-- Matrícula: 240545
-- Variante A: Roles administrativos (superadmin, admin)
-- ============================================================

USE db_test;

-- ============================================================
-- 1. SUPERADMIN
--    Control total, incluyendo crear usuarios y otorgar permisos
-- ============================================================
DROP USER IF EXISTS 'superadmin'@'%';
CREATE USER 'superadmin'@'%' IDENTIFIED BY 'SuperAdmin2026$Root';

GRANT ALL PRIVILEGES ON *.* TO 'superadmin'@'%'
WITH GRANT OPTION;

-- ============================================================
-- 2. ADMIN
--    CRUD total sobre db_test, sin poder crear usuarios ni
--    otorgar permisos (no tiene WITH GRANT OPTION)
-- ============================================================
DROP USER IF EXISTS 'admin'@'%';
CREATE USER 'admin'@'%' IDENTIFIED BY 'Admin2026$Full';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER,
      INDEX, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE,
      EXECUTE, TRIGGER, EVENT
ON db_test.* TO 'admin'@'%';

-- ============================================================
-- 3. Aplicar cambios
-- ============================================================
FLUSH PRIVILEGES;

-- ============================================================
-- 4. Verificación
-- ============================================================
SELECT '=== PRIVILEGIOS superadmin ===' AS seccion;
SHOW GRANTS FOR 'superadmin'@'%';

SELECT '=== PRIVILEGIOS admin ===' AS seccion;
SHOW GRANTS FOR 'admin'@'%';

-- ============================================================
-- 5. Pruebas funcionales
-- ============================================================

-- 5.1 superadmin puede crear un usuario
-- CREATE USER 'test_super'@'%' IDENTIFIED BY 'Test123$';
-- DROP USER 'test_super'@'%';

-- 5.2 admin puede hacer CRUD
SELECT COUNT(*) AS total_productos FROM db_test.tb_products;

INSERT INTO db_test.tb_categories (name, description)
VALUES ('Cat Prueba Admin', 'Categoría creada por admin');

UPDATE db_test.tb_categories
SET description = 'Actualizado por admin'
WHERE name = 'Cat Prueba Admin';

DELETE FROM db_test.tb_categories
WHERE name = 'Cat Prueba Admin';

-- 5.3 admin NO puede crear usuarios (debe fallar)
-- CREATE USER 'test_admin'@'%' IDENTIFIED BY 'X';

-- ============================================================
-- 6. Script de revocación
-- ============================================================
-- DROP USER IF EXISTS 'superadmin'@'%';
-- DROP USER IF EXISTS 'admin'@'%';
-- FLUSH PRIVILEGES;