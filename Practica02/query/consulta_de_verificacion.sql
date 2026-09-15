/* ============================================================
PRÁCTICA 02 - VERIFICACIÓN DE USUARIOS, ROLES Y PRIVILEGIOS
Base de datos: db_test
   ============================================================ */

USE db_test;


/* 1. Verificar tablas */
SHOW TABLES;


/* 2. Verificar usuarios remotos */
SELECT
    user AS Usuario,
    host AS Host
FROM mysql.user
WHERE user IN (
    'marco.ramirez',
    'emigdio.aguirre',
    'adrian.gonzalez',
    'ivan.alejandro'
)
ORDER BY user;


/* 3. Verificar roles creados */
SELECT
    user AS Rol,
    host AS Host
FROM mysql.user
WHERE user IN (
    'admin',
    'seller',
    'buyer',
    'support',
    'common',
    'user_not_registered'
)
ORDER BY user;


/* 4. Verificar roles asignados */
SELECT
    FROM_USER AS Rol,
    TO_USER AS Usuario
FROM mysql.role_edges
ORDER BY FROM_USER;


/* 5. Verificar privilegios del rol ADMIN */
SHOW GRANTS FOR 'admin';


/* 6. Verificar privilegios del rol SUPPORT */
SHOW GRANTS FOR 'support';