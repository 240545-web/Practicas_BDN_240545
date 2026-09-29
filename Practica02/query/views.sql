USE db_test;

-- Vista 1: Tus 5000 productos del Vendedor 2
CREATE OR REPLACE VIEW vw_productos_vendedor2 AS
SELECT ID, SKU, name, current_price, current_stock, current_price * current_stock AS valor_total, creation_date
FROM tb_products
WHERE SKU LIKE 'V2-SKU-%';

-- Vista 2: Valor de inventario (la que piden para calificar)
CREATE OR REPLACE VIEW vw_valor_inventario AS
SELECT 
  COUNT(*) AS total_productos,
  SUM(current_stock) AS total_unidades,
  SUM(current_price * current_stock) AS valor_inventario_total,
  AVG(current_price) AS precio_promedio
FROM tb_products
WHERE SKU LIKE 'V2-SKU-%';

-- Vista 3: Logs (esta es la que te dio 1000 rows en tu foto)
CREATE OR REPLACE VIEW vw_logs_productos AS
SELECT ID, table_name, operation, db_user, description, operation_date
FROM tb_logs
WHERE table_name = 'tb_products'
ORDER BY operation_date DESC;

-- Vista 4: Verificacion para el profe (la que te dio 4 rows)
CREATE OR REPLACE VIEW vw_verificacion_carga AS
SELECT 'Total Cargado Vendedor 2' AS concepto, COUNT(*) AS valor FROM tb_products WHERE SKU LIKE 'V2-SKU-%'
UNION ALL
SELECT 'Total Logs', COUNT(*) FROM tb_logs WHERE table_name = 'tb_products';

-- Vista 5: Stock bajo
CREATE OR REPLACE VIEW vw_stock_bajo AS
SELECT ID, SKU, name, current_stock, current_price FROM tb_products WHERE current_stock < 20 AND status = b'1' ORDER BY current_stock ASC;