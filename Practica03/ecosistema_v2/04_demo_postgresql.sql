-- Datos sintéticos opcionales para probar los tres escenarios.
-- Ejecutar una sola vez sobre el modelo nuevo y vacío; no genera usuarios.
BEGIN;
INSERT INTO ecommerce.tbc_countries(code,name) VALUES
('US','Estados Unidos'),('MX','México'),('CO','Colombia'),('AR','Argentina'),
('CL','Chile'),('PE','Perú'),('EC','Ecuador'),('CR','Costa Rica'),('UY','Uruguay');
INSERT INTO ecommerce.tbc_payment_methods(id,code,name) VALUES
(1,'card','Tarjeta'),(2,'points_card','Tarjeta de Puntos'),(3,'cash','Efectivo');
INSERT INTO ecommerce.tb_products("SKU",name,description,current_price,current_stock) VALUES
('DEMO-001','Producto de prueba','Producto sintético con stock para todos los escenarios.',100.00,20000);
SELECT setval(pg_get_serial_sequence('ecommerce.tbc_payment_methods','id'),(SELECT max(id) FROM ecommerce.tbc_payment_methods),true);
COMMIT;
