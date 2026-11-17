-- Practica 04 - Emigdio Aguirre 240545 - Verificacion de solo lectura - 2026-11-10
-- Ejecutar manualmente en MySQL Workbench. Resultados esperados, no verificados.

-- Debe dar 1000.
SELECT COUNT(*) AS total_productos
FROM db_test.tb_products;

-- Debe dar 504.
SELECT COUNT(category_id) AS con_categoria
FROM db_test.tb_products;

-- Debe dar 504 despues de completar manualmente la carga de la tabla puente.
SELECT COUNT(*) AS en_puente
FROM db_test.tb_products_categories;

-- Debe devolver solo 240548; no se limita el resultado para ocultar otros elegibles.
SELECT o.user_ID
FROM db_test.tbd_users_offer_products AS o
INNER JOIN db_test.tb_products AS p ON p.ID = o.product_ID
WHERE o.status = b'1'
  AND o.available_stock >= 3
  AND p.status = b'1'
  AND p.deleted_at IS NULL
  AND p.current_stock >= 3
  AND p.current_price > 0
GROUP BY o.user_ID
HAVING COUNT(DISTINCT p.ID) >= 5
ORDER BY o.user_ID;

-- Deben aparecer ambos procedimientos en db_test.
SELECT ROUTINE_NAME
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'db_test'
  AND ROUTINE_TYPE = 'PROCEDURE'
  AND ROUTINE_NAME IN ('p04_caso1_final', 'p04_caso2_error')
ORDER BY ROUTINE_NAME;
