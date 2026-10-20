-- ============================================================
-- VERIFICACIÓN DE ESTADO: tb_users y tb_categories
-- Práctica 03 - Emigdio Aguirre 240545
-- Puerto MySQL: 40545
-- ============================================================

USE db_test;

-- ============================================================
-- 1. ESTRUCTURA DE LAS TABLAS
-- ============================================================
SELECT '========== ESTRUCTURA: tb_users ==========' AS seccion;
DESCRIBE tb_users;

SELECT '========== ESTRUCTURA: tb_categories ==========' AS seccion;
DESCRIBE tb_categories;

-- ============================================================
-- 2. COLUMNAS DETALLADAS (tipo, null, default, extra)
-- ============================================================
SELECT '========== COLUMNAS DETALLADAS: tb_users ==========' AS seccion;
SELECT
    COLUMN_NAME     AS Columna,
    COLUMN_TYPE     AS Tipo,
    IS_NULLABLE     AS Nulo,
    COLUMN_DEFAULT  AS Defecto,
    COLUMN_KEY      AS Llave,
    EXTRA           AS Extra
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'db_test' AND TABLE_NAME = 'tb_users'
ORDER BY ORDINAL_POSITION;

SELECT '========== COLUMNAS DETALLADAS: tb_categories ==========' AS seccion;
SELECT
    COLUMN_NAME     AS Columna,
    COLUMN_TYPE     AS Tipo,
    IS_NULLABLE     AS Nulo,
    COLUMN_DEFAULT  AS Defecto,
    COLUMN_KEY      AS Llave,
    EXTRA           AS Extra
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'db_test' AND TABLE_NAME = 'tb_categories'
ORDER BY ORDINAL_POSITION;

-- ============================================================
-- 3. ÍNDICES
-- ============================================================
SELECT '========== ÍNDICES: tb_users ==========' AS seccion;
SHOW INDEX FROM tb_users;

SELECT '========== ÍNDICES: tb_categories ==========' AS seccion;
SHOW INDEX FROM tb_categories;

-- ============================================================
-- 4. LLAVES FORÁNEAS
-- ============================================================
SELECT '========== LLAVES FORÁNEAS ==========' AS seccion;
SELECT
    TABLE_NAME         AS Tabla,
    COLUMN_NAME        AS Columna,
    CONSTRAINT_NAME    AS FK,
    REFERENCED_TABLE_NAME  AS Tabla_Referenciada,
    REFERENCED_COLUMN_NAME AS Columna_Referenciada
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'db_test'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- ============================================================
-- 5. CONTEO DE REGISTROS
-- ============================================================
SELECT '========== CONTEO DE REGISTROS ==========' AS seccion;
SELECT 'tb_users' AS Tabla, COUNT(*) AS Total FROM tb_users
UNION ALL
SELECT 'tb_categories', COUNT(*) FROM tb_categories
UNION ALL
SELECT 'tb_products', COUNT(*) FROM tb_products
UNION ALL
SELECT 'tb_logs', COUNT(*) FROM tb_logs;

-- ============================================================
-- 6. CONTEO CON SOFT DELETE
-- ============================================================
SELECT '========== ACTIVOS vs ELIMINADOS ==========' AS seccion;
SELECT
    'tb_users' AS Tabla,
    SUM(CASE WHEN deleted_at IS NULL THEN 1 ELSE 0 END) AS Activos,
    SUM(CASE WHEN deleted_at IS NOT NULL THEN 1 ELSE 0 END) AS Eliminados
FROM tb_users
UNION ALL
SELECT
    'tb_categories',
    SUM(CASE WHEN deleted_at IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN deleted_at IS NOT NULL THEN 1 ELSE 0 END)
FROM tb_categories;

-- ============================================================
-- 7. CONTENIDO DE tb_users
-- ============================================================
SELECT '========== CONTENIDO: tb_users ==========' AS seccion;
SELECT
    ID,
    email,
    nickname,
    LEFT(password, 20) AS password_hash,
    creation_date,
    last_update,
    last_login,
    deleted_at
FROM tb_users
ORDER BY ID;

-- ============================================================
-- 8. CONTENIDO DE tb_categories
-- ============================================================
SELECT '========== CONTENIDO: tb_categories ==========' AS seccion;
SELECT
    ID,
    name,
    LEFT(description, 60) AS descripcion_corta,
    status,
    creation_date,
    last_update,
    deleted_at
FROM tb_categories
ORDER BY ID
LIMIT 30;

-- ============================================================
-- 9. CATEGORÍAS SIN PRODUCTOS
-- ============================================================
SELECT '========== CATEGORÍAS SIN PRODUCTOS ==========' AS seccion;
SELECT
    c.ID,
    c.name,
    c.deleted_at
FROM tb_categories c
LEFT JOIN tb_products p ON p.category_id = c.ID AND p.deleted_at IS NULL
WHERE p.ID IS NULL
ORDER BY c.ID;

-- ============================================================
-- 10. TOP 10 CATEGORÍAS CON MÁS PRODUCTOS
-- ============================================================
SELECT '========== TOP 10 CATEGORÍAS ==========' AS seccion;
SELECT
    c.ID,
    c.name,
    COUNT(p.ID) AS total_productos
FROM tb_categories c
LEFT JOIN tb_products p ON p.category_id = c.ID AND p.deleted_at IS NULL
WHERE c.deleted_at IS NULL
GROUP BY c.ID, c.name
ORDER BY total_productos DESC
LIMIT 10;

-- ============================================================
-- 11. TRIGGERS ACTIVOS SOBRE tb_users Y tb_categories
-- ============================================================
SELECT '========== TRIGGERS: tb_users y tb_categories ==========' AS seccion;
SELECT
    TRIGGER_NAME        AS Trigger,
    EVENT_MANIPULATION  AS Evento,
    EVENT_OBJECT_TABLE  AS Tabla,
    ACTION_TIMING       AS Momento
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'db_test'
  AND EVENT_OBJECT_TABLE IN ('tb_users', 'tb_categories')
ORDER BY EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION;

-- ============================================================
-- 12. RESUMEN FINAL
-- ============================================================
SELECT '========== RESUMEN FINAL ==========' AS seccion;
SELECT
    'tb_users' AS Tabla,
    (SELECT COUNT(*) FROM tb_users) AS Registros,
    (SELECT COUNT(*) FROM information_schema.TRIGGERS
     WHERE TRIGGER_SCHEMA='db_test' AND EVENT_OBJECT_TABLE='tb_users') AS Triggers,
    (SELECT COUNT(*) FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA='db_test' AND TABLE_NAME='tb_users') AS Indices
UNION ALL
SELECT
    'tb_categories',
    (SELECT COUNT(*) FROM tb_categories),
    (SELECT COUNT(*) FROM information_schema.TRIGGERS
     WHERE TRIGGER_SCHEMA='db_test' AND EVENT_OBJECT_TABLE='tb_categories'),
    (SELECT COUNT(*) FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA='db_test' AND TABLE_NAME='tb_categories');