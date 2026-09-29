USE db_test;

-- ============================================================
-- INDICES - Practica02 - 240545 - Puerto 40545
-- Optimizacion para carga masiva 5000 Vendedor 2
-- ============================================================

-- 1. Índice para tu verificación principal (el que usas en todas las vistas)
CREATE INDEX idx_sku_v2 ON tb_products(SKU);

-- 2. Índice compuesto para tus vistas de valor e inventario
CREATE INDEX idx_sku_status_price ON tb_products(SKU, status, current_price);

-- 3. Índice para stock bajo
CREATE INDEX idx_stock ON tb_products(current_stock);

-- 4. Índice para logs (tu vw_logs_productos que te dio 1000 rows)
CREATE INDEX idx_logs_table_operation ON tb_logs(table_name, operation);
CREATE INDEX idx_logs_date ON tb_logs(operation_date);

-- Verificación de índices creados
SHOW INDEX FROM tb_products;
SHOW INDEX FROM tb_logs;
