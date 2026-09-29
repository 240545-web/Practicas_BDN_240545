USE db_test;

-- 2.1 Desactivar checks para carga rápida
SET FOREIGN_KEY_CHECKS=0;
SET UNIQUE_CHECKS=0;
SET @OLD_LOG_BIN = @@SQL_LOG_BIN;
-- Opcional: si no quieres 5000 logs, descomenta la siguiente línea
-- DROP TRIGGER IF EXISTS trg_products_after_insert;

-- 2.2 Procedimiento para generar 5000 productos sin necesidad de CSV
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_carga_masiva_5000$$
CREATE PROCEDURE sp_carga_masiva_5000()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_sku VARCHAR(50);
    
    -- Limpiamos si ya habia prueba
    DELETE FROM tb_products WHERE SKU LIKE 'V2-SKU-%';

    WHILE i <= 5000 DO
        SET v_sku = CONCAT('V2-SKU-', LPAD(i, 5, '0'));
        
        INSERT INTO tb_products (SKU, name, description, current_price, current_stock, status)
        VALUES (
            v_sku,
            CONCAT('Producto Vendedor 2 - ', i),
            CONCAT('Importación masiva - Lote 5000 - Producto ', i, ' - Vendedor 2'),
            ROUND(RAND() * 1000 + 10, 2),
            FLOOR(RAND() * 500),
            1
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL sp_carga_masiva_5000();

-- 2.3 Si desactivaste el trigger, vuelve a crearlo
-- Si no lo borraste, ignora esto
-- Ejecuta de nuevo el CREATE TRIGGER trg_products_after_insert de tu script original

SET FOREIGN_KEY_CHECKS=1;
SET UNIQUE_CHECKS=1;