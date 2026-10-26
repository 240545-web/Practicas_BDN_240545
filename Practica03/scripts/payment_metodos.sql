USE db_test;

CREATE TABLE IF NOT EXISTS tbc_payment_methods (
    ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    status BIT(1) NOT NULL DEFAULT b'1',
    creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertar datos de prueba por si acaso
INSERT IGNORE INTO tbc_payment_methods (name, description) VALUES
('Tarjeta de Crédito', 'Pago con tarjeta Visa/Mastercard'),
('PayPal', 'Pago a través de PayPal'),
('Transferencia', 'Transferencia bancaria directa');