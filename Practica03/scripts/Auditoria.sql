USE db_test;

-- 1. Agregar columnas de auditoría a la tabla de Envíos (Shipments)
ALTER TABLE tb_shipments 
ADD COLUMN status_envio VARCHAR(50) DEFAULT 'Pendiente',
ADD COLUMN fecha_entrada DATETIME DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN fecha_salida DATETIME NULL,
ADD COLUMN auditoria_usuario VARCHAR(100) DEFAULT NULL; -- <--- CORREGIDO AQUÍ

-- 2. Actualizar la tabla de Logs para que guarde la fecha exacta
ALTER TABLE tb_logs
MODIFY COLUMN operation_date DATETIME DEFAULT CURRENT_TIMESTAMP;

-- 3. Crear Triggers para capturar la auditoría automáticamente
DROP TRIGGER IF EXISTS trg_shipments_auditoria_ai;
DROP TRIGGER IF EXISTS trg_shipments_auditoria_au;

DELIMITER $$

-- Trigger para cuando se CREA un envío
CREATE TRIGGER trg_shipments_auditoria_ai
BEFORE INSERT ON tb_shipments FOR EACH ROW
BEGIN
    SET NEW.auditoria_usuario = USER();
END$$

-- Trigger para cuando se ACTUALIZA un envío
CREATE TRIGGER trg_shipments_auditoria_au
BEFORE UPDATE ON tb_shipments FOR EACH ROW
BEGIN
    -- Si el estado cambia a 'Entregado', registramos la fecha de salida
    IF NEW.status_envio = 'Entregado' AND OLD.status_envio != 'Entregado' THEN
        SET NEW.fecha_salida = CURRENT_TIMESTAMP;
    END IF;
    
    -- Actualizamos el usuario que hizo el cambio
    SET NEW.auditoria_usuario = USER();
END$$

DELIMITER ;

-- Verificar que las columnas se agregaron correctamente
DESCRIBE tb_shipments;