/* ============================================================
   PASOS 4, 5 Y 6 DE LA PRESENTACIÓN
   Alumno: Emigdio Yair Aguirre Martínez - 240545
   ============================================================ */

USE db_test;

/* ============================================================
   4. ASIGNAR PRIVILEGIOS DE INSERCIÓN AL ROL "user_not_registered"
   ============================================================ */
GRANT INSERT ON db_test.tb_users TO 'user_not_registered';
GRANT INSERT ON db_test.tb_people TO 'user_not_registered';

/* ============================================================
   5. CREAR 2 NUEVOS USUARIOS
   ============================================================ */
DROP USER IF EXISTS 'app_web'@'%';
DROP USER IF EXISTS 'app_movil'@'%';

CREATE USER 'app_web'@'%' IDENTIFIED BY 'Web123';
CREATE USER 'app_movil'@'%' IDENTIFIED BY 'Mobile890';

/* ============================================================
   6. ASIGNARLES EL ROL POR DEFECTO
   ============================================================ */
GRANT 'user_not_registered' TO 'app_web'@'%';
GRANT 'user_not_registered' TO 'app_movil'@'%';

SET DEFAULT ROLE 'user_not_registered' TO 'app_web'@'%';
SET DEFAULT ROLE 'user_not_registered' TO 'app_movil'@'%';

-- Aplicar cambios de seguridad
FLUSH PRIVILEGES;

/* ============================================================
   VERIFICACIÓN FINAL
   ============================================================ */

-- 1. Verificar permisos del rol
SHOW GRANTS FOR 'user_not_registered';

-- 2. Verificar que los usuarios existen
SELECT user, host FROM mysql.user WHERE user IN ('app_web', 'app_movil');

-- 3. Verificar el rol por defecto
SELECT 
    u.user AS Usuario, 
    d.DEFAULT_ROLE_USER AS Rol_Por_Defecto
FROM mysql.user u
JOIN mysql.default_roles d ON u.user = d.USER
WHERE u.user IN ('app_web', 'app_movil');