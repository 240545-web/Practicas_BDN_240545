/* ============================================================
   PRÁCTICA 04 - CASOS DE COMPRA (MySQL)
   Alumno: Emigdio Aguirre - 240545
   Base existente: db_test (NO se crea ninguna base nueva)
   Motor: MySQL 8.0
   ------------------------------------------------------------
   5 casos con transacciones, validación de inventario,
   SET ROLE y consulta de verificación al final de cada caso.
   Los datos son inventados; no provienen del ejemplo del
   docente (Puebla/Xicotepec).
   ============================================================ */

USE db_test;
SET NAMES utf8mb4;

/* ============================================================
   0. PREPARACIÓN (solo inserts en tablas existentes)
   - Métodos de pago que los casos necesitan.
   - Ofertas de proveedor para que tb_order_items tenga
     provider_ID válido (FK a tbd_users_offer_products).
   ============================================================ */
INSERT IGNORE INTO tbc_payment_methods (ID, name, description, status) VALUES
(4, 'Tarjeta de Débito',   'Pago con tarjeta de débito',        b'1'),
(5, 'Tarjeta Digital Spin','Monedero digital Spin',             b'1'),
(6, 'Transferencia SPEI',  'Transferencia interbancaria SPEI',  b'1'),
(7, 'Cupón de Regalo',     'Cupón de regalo canjeable',         b'1');

INSERT INTO tbd_users_offer_products
    (user_ID, product_ID, available_stock, status, available_date)
SELECT 1, p.ID, 500, b'1', NOW()
FROM tb_products p
WHERE p.deleted_at IS NULL
  AND p.ID IN (
      11, 23, 37, 42, 58,
      201, 202, 203, 204, 205, 206, 207, 208, 209, 210,
      301, 302, 303,
      401, 402, 403
  )
  AND NOT EXISTS (
      SELECT 1 FROM tbd_users_offer_products o
      WHERE o.user_ID = 1 AND o.product_ID = p.ID
  );

/* ============================================================
   CASO 1 - COMPRA EXITOSA, SIN MODIFICACIONES
   ------------------------------------------------------------
   SET ROLE user_not_registered -> crear usuario -> 5 productos
   -> 1 carrito -> orden -> domicilio casa -> pago débito
   -> procesar orden como atendida -> envío a casa.
   ============================================================ */
SELECT '===== CASO 1: COMPRA EXITOSA =====' AS caso;

/* 1.1 Rol inicial y alta del cliente */
SET ROLE "user_not_registered";

CALL sp_crear_usuario(
    'luna.ferreyra@correo.test', 'Luna Ferreyra', 'Luna2026!',
    'Luna', 'Ferreyra', '1998-03-12', 'MX', '5512348001',
    @u1
);
SELECT @u1 AS usuario_nuevo;

/* 1.2 Selección de 5 productos (el rol not_registered solo lee) */
SELECT ID, SKU, name, current_price, current_stock
FROM tb_products
WHERE ID IN (11, 23, 37, 42, 58)
ORDER BY ID;

/* 1.3 El rol de compra debe poder escribir carrito/orden */
SET ROLE "buyer";

START TRANSACTION;

/* 1.4 Carrito: 1 carrito y 5 partidas con cantidades distintas */
INSERT INTO tb_carts (user_ID, status) VALUES (@u1, b'1');
SET @cart1 = LAST_INSERT_ID();

INSERT INTO tbd_shopping_cart (user_ID, product_ID, quantity) VALUES
(@u1, 11, 1),
(@u1, 23, 2),
(@u1, 37, 3),
(@u1, 42, 1),
(@u1, 58, 2);

/* 1.5 Total calculado desde el catálogo (no inventado) */
SET @total1 = (
    SELECT SUM(p.current_price * x.qty)
    FROM tb_products p
    JOIN (
        SELECT 11 AS pid, 1 AS qty UNION ALL
        SELECT 23, 2 UNION ALL
        SELECT 37, 3 UNION ALL
        SELECT 42, 1 UNION ALL
        SELECT 58, 2
    ) x ON x.pid = p.ID
);

/* 1.6 Orden general del comprador */
INSERT INTO tb_orders
    (`key`, user_ID, total_products, total_cost, status_string, status)
VALUES (
    CONCAT('ORD-C1-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '-', @u1),
    @u1, 5, @total1, 'pendiente', b'1'
);
SET @orden1 = LAST_INSERT_ID();

/* 1.7 Compraventa con el vendedor 1 (vendedor != comprador) */
INSERT INTO tb_seller_orders
    (`key`, seller_ID, buyer_ID, total_items, total_amount, status_string, status)
VALUES (
    CONCAT('SORD-C1-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '-', @u1),
    1, @u1, 5, @total1, 'pendiente', b'1'
);
SET @sorden1 = LAST_INSERT_ID();

/* 1.8 Detalle de venta (los triggers validan y descuentan stock) */
SET @pid_item = 11;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden1, @pid_item, @prov_item, @pname_item, 1, @pprice_item);

SET @pid_item = 23;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden1, @pid_item, @prov_item, @pname_item, 2, @pprice_item);

SET @pid_item = 37;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden1, @pid_item, @prov_item, @pname_item, 3, @pprice_item);

SET @pid_item = 42;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden1, @pid_item, @prov_item, @pname_item, 1, @pprice_item);

SET @pid_item = 58;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden1, @pid_item, @prov_item, @pname_item, 2, @pprice_item);

COMMIT;

/* 1.9 Domicilio de casa con el procedimiento escalado */
CALL sp_crear_domicilio_escalado(
    'México', 'Jalisco', 'Zapopan', 'Zapopan', 'Ladera Norte',
    '45110', 'Real del Valle', 'Av. Patria', '120', '5B',
    5001
);

/* 1.10 Pago con tarjeta de débito de 16 dígitos */
SET ROLE "buyer";

START TRANSACTION;

INSERT INTO tb_payments
    (order_ID, payment_method_ID, amount, payment_status,
     transaction_reference, payment_date)
VALUES (
    @orden1, 4, @total1, 'Completed',
    'DEBITO-4821-9900-1122-3344', NOW()
);

/* 1.11 Procesar la orden como atendida y enviar a casa */
UPDATE tb_orders
SET status_string = 'atendida'
WHERE ID = @orden1;

UPDATE tb_seller_orders
SET status_string = 'atendida'
WHERE ID = @sorden1;

INSERT INTO tb_logs (table_name, operation, db_user, description)
VALUES ('tb_orders', 'Update', USER(),
        CONCAT('CASO 1: orden ', @orden1, ' atendida; envío a casa al domicilio 5001'));

COMMIT;

/* 1.12 Verificación del Caso 1 */
SELECT o.ID AS orden, o.key, o.total_products, o.total_cost,
       o.status_string, s.ID AS seller_order, s.status_string AS seller_status
FROM tb_orders o
JOIN tb_seller_orders s ON s.buyer_ID = o.user_ID
WHERE o.ID = @orden1;

SELECT i.ID, i.product_ID, i.product_name, i.quantity, i.unit_price, i.subtotal
FROM tb_order_items i
WHERE i.seller_order_ID = @sorden1
ORDER BY i.ID;

SELECT ID, amount, payment_status, transaction_reference, payment_date
FROM tb_payments
WHERE order_ID = @orden1;

SELECT ID, component_type, `value`, address_sup_ID
FROM tbd_address_componentes
WHERE address_ID = 5001
ORDER BY FIELD(component_type,
    'País','Estado','Municipio','Ciudad','Localidad',
    'Código Postal','Colonia','Calle/Avenida',
    'Número Exterior','Número Interior');

SELECT u.ID, u.email, p.given_names, p.family_names, p.phone
FROM tb_users u
JOIN tb_people p ON p.user_ID = u.ID
WHERE u.ID = @u1;

/* ============================================================
   CASO 2 - COMPRA CON DETALLES, RECLAMACIÓN Y REENVÍO
   ------------------------------------------------------------
   Usuario registrado (1001), 10 productos, crédito en 6 pagos
   (5 autorizados y el 6º rechazado), reclamo y reenvío.
   ============================================================ */
SELECT '===== CASO 2: DETALLES, RECLAMACIÓN Y REENVÍO =====' AS caso;

SET ROLE "buyer";
SET @u2 = 1001;

SELECT ID, email, nickname FROM tb_users WHERE ID = @u2;

START TRANSACTION;

/* 2.1 Carrito con 10 productos y cantidades 1-5 */
INSERT INTO tb_carts (user_ID, status) VALUES (@u2, b'1');
SET @cart2 = LAST_INSERT_ID();

INSERT INTO tbd_shopping_cart (user_ID, product_ID, quantity) VALUES
(@u2, 201, 3), (@u2, 202, 1), (@u2, 203, 4), (@u2, 204, 2),
(@u2, 205, 5), (@u2, 206, 1), (@u2, 207, 3), (@u2, 208, 2),
(@u2, 209, 4), (@u2, 210, 1);

/* 2.2 Total */
SET @total2 = (
    SELECT SUM(p.current_price * x.qty)
    FROM tb_products p
    JOIN (
        SELECT 201 AS pid, 3 AS qty UNION ALL SELECT 202, 1 UNION ALL
        SELECT 203, 4 UNION ALL SELECT 204, 2 UNION ALL SELECT 205, 5 UNION ALL
        SELECT 206, 1 UNION ALL SELECT 207, 3 UNION ALL SELECT 208, 2 UNION ALL
        SELECT 209, 4 UNION ALL SELECT 210, 1
    ) x ON x.pid = p.ID
);

/* 2.3 Orden y compraventa */
INSERT INTO tb_orders
    (`key`, user_ID, total_products, total_cost, status_string, status)
VALUES (
    CONCAT('ORD-C2-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '-', @u2),
    @u2, 10, @total2, 'pendiente', b'1'
);
SET @orden2 = LAST_INSERT_ID();

INSERT INTO tb_seller_orders
    (`key`, seller_ID, buyer_ID, total_items, total_amount, status_string, status)
VALUES (
    CONCAT('SORD-C2-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '-', @u2),
    1, @u2, 10, @total2, 'pendiente', b'1'
);
SET @sorden2 = LAST_INSERT_ID();

/* 2.4 Detalle: 10 partidas */
SET @pid_item = 201;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden2, @pid_item, @prov_item, @pname_item, 3, @pprice_item);

SET @pid_item = 202;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden2, @pid_item, @prov_item, @pname_item, 1, @pprice_item);

SET @pid_item = 203;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden2, @pid_item, @prov_item, @pname_item, 4, @pprice_item);

SET @pid_item = 204;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden2, @pid_item, @prov_item, @pname_item, 2, @pprice_item);

SET @pid_item = 205;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden2, @pid_item, @prov_item, @pname_item, 5, @pprice_item);

SET @pid_item = 206;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden2, @pid_item, @prov_item, @pname_item, 1, @pprice_item);

SET @pid_item = 207;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden2, @pid_item, @prov_item, @pname_item, 3, @pprice_item);

SET @pid_item = 208;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden2, @pid_item, @prov_item, @pname_item, 2, @pprice_item);

SET @pid_item = 209;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden2, @pid_item, @prov_item, @pname_item, 4, @pprice_item);

SET @pid_item = 210;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden2, @pid_item, @prov_item, @pname_item, 1, @pprice_item);

COMMIT;

/* 2.5 Domicilio de trabajo */
CALL sp_crear_domicilio_escalado(
    'México', 'Nuevo León', 'Monterrey', 'Monterrey', 'Centro',
    '64000', 'Del Valle', 'Av. Gómez Morín', '250', '804',
    5002
);

START TRANSACTION;

/* 2.6 Seis pagos mensuales: 5 autorizados y el 6º rechazado */
SET @cuota2   = ROUND(@total2 / 6, 2);
SET @ultima2  = @total2 - (5 * @cuota2);

INSERT INTO tb_payments
    (order_ID, payment_method_ID, amount, payment_status,
     transaction_reference, payment_date)
VALUES
(@orden2, 1, @cuota2,  'Completed', 'CREDITO-5555-4444-3333-2222-1', NOW()),
(@orden2, 1, @cuota2,  'Completed', 'CREDITO-5555-4444-3333-2222-2', NOW()),
(@orden2, 1, @cuota2,  'Completed', 'CREDITO-5555-4444-3333-2222-3', NOW()),
(@orden2, 1, @cuota2,  'Completed', 'CREDITO-5555-4444-3333-2222-4', NOW()),
(@orden2, 1, @cuota2,  'Completed', 'CREDITO-5555-4444-3333-2222-5', NOW()),
(@orden2, 1, @ultima2, 'Failed',    'CREDITO-5555-4444-3333-2222-6-LIMITE-EXCEDIDO', NOW());

/* 2.7 Orden atendida y envío a casa */
UPDATE tb_orders        SET status_string = 'atendida' WHERE ID = @orden2;
UPDATE tb_seller_orders SET status_string = 'atendida' WHERE ID = @sorden2;

/* 2.8 Reclamo por producto dañado y reenvío en buenas condiciones */
INSERT INTO tb_logs (table_name, operation, db_user, description) VALUES
('tb_orders', 'Update', USER(),
 CONCAT('CASO 2: reclamo por producto dañado en orden ', @orden2,
        '; reenvío en buenas condiciones a domicilio 5002'));

COMMIT;

/* 2.9 Verificación del Caso 2 */
SELECT o.ID AS orden, o.total_products, o.total_cost, o.status_string,
       s.ID AS seller_order, s.status_string AS seller_status
FROM tb_orders o
JOIN tb_seller_orders s ON s.buyer_ID = o.user_ID
WHERE o.ID = @orden2;

SELECT payment_status, COUNT(*) AS pagos, SUM(amount) AS monto
FROM tb_payments
WHERE order_ID = @orden2
GROUP BY payment_status;

SELECT ID, component_type, `value`, address_sup_ID
FROM tbd_address_componentes
WHERE address_ID = 5002
ORDER BY FIELD(component_type,
    'País','Estado','Municipio','Ciudad','Localidad',
    'Código Postal','Colonia','Calle/Avenida',
    'Número Exterior','Número Interior');

/* ============================================================
   CASO 3 - COMPRA CON CANCELACIÓN PARCIAL, AJUSTE Y REEMBOLSO
   ------------------------------------------------------------
   Usuario registrado (1002), 3 productos de la misma categoría,
   pago con Spin, cancela 1 producto, ajusta la orden y reembolsa.
   ============================================================ */
SELECT '===== CASO 3: CANCELACIÓN PARCIAL Y REEMBOLSO =====' AS caso;

SET ROLE "buyer";
SET @u3 = 1002;

SELECT ID, email, nickname FROM tb_users WHERE ID = @u3;

START TRANSACTION;

/* 3.1 Carrito: 3 productos de la misma categoría (37, 58, 202) */
INSERT INTO tb_carts (user_ID, status) VALUES (@u3, b'1');
SET @cart3 = LAST_INSERT_ID();

INSERT INTO tbd_shopping_cart (user_ID, product_ID, quantity) VALUES
(@u3, 37, 2),
(@u3, 58, 5),
(@u3, 202, 3);

/* 3.2 Total */
SET @total3 = (
    SELECT SUM(p.current_price * x.qty)
    FROM tb_products p
    JOIN (
        SELECT 37 AS pid, 2 AS qty UNION ALL
        SELECT 58, 5 UNION ALL
        SELECT 202, 3
    ) x ON x.pid = p.ID
);

/* 3.3 Orden y compraventa */
INSERT INTO tb_orders
    (`key`, user_ID, total_products, total_cost, status_string, status)
VALUES (
    CONCAT('ORD-C3-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '-', @u3),
    @u3, 3, @total3, 'pendiente', b'1'
);
SET @orden3 = LAST_INSERT_ID();

INSERT INTO tb_seller_orders
    (`key`, seller_ID, buyer_ID, total_items, total_amount, status_string, status)
VALUES (
    CONCAT('SORD-C3-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '-', @u3),
    1, @u3, 3, @total3, 'pendiente', b'1'
);
SET @sorden3 = LAST_INSERT_ID();

/* 3.4 Detalle */
SET @pid_item = 37;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden3, @pid_item, @prov_item, @pname_item, 2, @pprice_item);

SET @pid_item = 58;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden3, @pid_item, @prov_item, @pname_item, 5, @pprice_item);

SET @pid_item = 202;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden3, @pid_item, @prov_item, @pname_item, 3, @pprice_item);

COMMIT;

/* 3.5 Domicilio "Casa Papas" */
CALL sp_crear_domicilio_escalado(
    'México', 'Jalisco', 'Guadalajara', 'Guadalajara', 'Chapalita',
    '44500', 'Casa Papas', 'Av. Niño Obrero', '77', '12',
    5003
);

START TRANSACTION;

/* 3.6 Pago total en efectivo con tarjeta digital Spin */
INSERT INTO tb_payments
    (order_ID, payment_method_ID, amount, payment_status,
     transaction_reference, payment_date)
VALUES (
    @orden3, 5, @total3, 'Completed',
    'SPIN-6677-8899-0011-2233', NOW()
);

/* 3.7 Orden atendida */
UPDATE tb_orders        SET status_string = 'atendida' WHERE ID = @orden3;
UPDATE tb_seller_orders SET status_string = 'atendida' WHERE ID = @sorden3;

COMMIT;

/* 3.8 Cancelación de 1 producto: el trigger devuelve el stock */
START TRANSACTION;

SELECT ID, product_ID, quantity, unit_price
INTO @item3, @pid3, @qty3, @precio3
FROM tb_order_items
WHERE seller_order_ID = @sorden3
ORDER BY ID
LIMIT 1;

/* El monto cancelado es precio unitario por cantidad */
SET @monto_cancelado3 = @precio3 * @qty3;

DELETE FROM tb_order_items WHERE ID = @item3;

/* 3.9 Ajuste de la orden y de la compraventa: se cancela 1 línea */
UPDATE tb_orders
SET total_products = total_products - 1,
    total_cost     = total_cost - @monto_cancelado3
WHERE ID = @orden3;

UPDATE tb_seller_orders
SET total_items  = total_items - 1,
    total_amount = total_amount - @monto_cancelado3
WHERE ID = @sorden3;

/* 3.10 Reembolso parcial del monto cancelado */
INSERT INTO tb_payments
    (order_ID, payment_method_ID, amount, payment_status,
     transaction_reference, payment_date)
VALUES (
    @orden3, 5, @monto_cancelado3, 'Refunded',
    CONCAT('REEMBOLSO-C3-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), NOW()
);

/* 3.11 Envío y recepción del cliente */
INSERT INTO tb_logs (table_name, operation, db_user, description)
VALUES ('tb_orders', 'Update', USER(),
        CONCAT('CASO 3: canceló producto ', @pid3, '; reembolso parcial ',
               @monto_cancelado3, '; cliente recibe el resto en domicilio 5003'));

COMMIT;

/* 3.12 Verificación del Caso 3 */
SELECT o.ID AS orden, o.total_products, o.total_cost, o.status_string,
       s.ID AS seller_order, s.total_items, s.total_amount
FROM tb_orders o
JOIN tb_seller_orders s ON s.buyer_ID = o.user_ID
WHERE o.ID = @orden3;

SELECT ID, product_ID, product_name, quantity, unit_price, subtotal
FROM tb_order_items
WHERE seller_order_ID = @sorden3
ORDER BY ID;

SELECT ID, amount, payment_status, transaction_reference
FROM tb_payments
WHERE order_ID = @orden3
ORDER BY ID;

SELECT ID, component_type, `value`, address_sup_ID
FROM tbd_address_componentes
WHERE address_ID = 5003
ORDER BY FIELD(component_type,
    'País','Estado','Municipio','Ciudad','Localidad',
    'Código Postal','Colonia','Calle/Avenida',
    'Número Exterior','Número Interior');

/* ============================================================
   CASO 4 - COMPRA DEL MISMO PROVEEDOR CON PUNTO DE RECOLECCIÓN
   ------------------------------------------------------------
   Usuario registrado (1003), 3 productos del mismo proveedor,
   pago SPEI, nadie recibe y el cliente recoge en el punto.
   ============================================================ */
SELECT '===== CASO 4: MISMO PROVEEDOR Y PUNTO DE RECOLECCIÓN =====' AS caso;

SET ROLE "buyer";
SET @u4 = 1003;

SELECT ID, email, nickname FROM tb_users WHERE ID = @u4;

START TRANSACTION;

/* 4.1 Carrito: 3 productos del mismo proveedor (401, 402, 403) */
INSERT INTO tb_carts (user_ID, status) VALUES (@u4, b'1');
SET @cart4 = LAST_INSERT_ID();

INSERT INTO tbd_shopping_cart (user_ID, product_ID, quantity) VALUES
(@u4, 401, 2),
(@u4, 402, 3),
(@u4, 403, 1);

/* 4.2 Total */
SET @total4 = (
    SELECT SUM(p.current_price * x.qty)
    FROM tb_products p
    JOIN (
        SELECT 401 AS pid, 2 AS qty UNION ALL
        SELECT 402, 3 UNION ALL
        SELECT 403, 1
    ) x ON x.pid = p.ID
);

/* 4.3 Orden y compraventa */
INSERT INTO tb_orders
    (`key`, user_ID, total_products, total_cost, status_string, status)
VALUES (
    CONCAT('ORD-C4-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '-', @u4),
    @u4, 3, @total4, 'pendiente', b'1'
);
SET @orden4 = LAST_INSERT_ID();

INSERT INTO tb_seller_orders
    (`key`, seller_ID, buyer_ID, total_items, total_amount, status_string, status)
VALUES (
    CONCAT('SORD-C4-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '-', @u4),
    1, @u4, 3, @total4, 'pendiente', b'1'
);
SET @sorden4 = LAST_INSERT_ID();

/* 4.4 Detalle */
SET @pid_item = 401;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden4, @pid_item, @prov_item, @pname_item, 2, @pprice_item);

SET @pid_item = 402;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden4, @pid_item, @prov_item, @pname_item, 3, @pprice_item);

SET @pid_item = 403;
SET @pname_item = (SELECT name FROM tb_products WHERE ID = @pid_item);
SET @pprice_item = (SELECT current_price FROM tb_products WHERE ID = @pid_item);
SET @prov_item = (SELECT ID FROM tbd_users_offer_products WHERE product_ID = @pid_item AND user_ID = 1 ORDER BY ID LIMIT 1);
INSERT INTO tb_order_items
    (seller_order_ID, product_ID, provider_ID, product_name, quantity, unit_price)
VALUES (@sorden4, @pid_item, @prov_item, @pname_item, 1, @pprice_item);

COMMIT;

/* 4.5 Domicilio hogar */
CALL sp_crear_domicilio_escalado(
    'México', 'Jalisco', 'Zapopan', 'Zapopan', 'Santa Lucia',
    '45130', 'Santa Lucia', 'Calle Juárez', '18', 'A',
    5004
);

START TRANSACTION;

/* 4.6 Pago por transferencia SPEI (16 dígitos), total en efectivo */
INSERT INTO tb_payments
    (order_ID, payment_method_ID, amount, payment_status,
     transaction_reference, payment_date)
VALUES (
    @orden4, 6, @total4, 'Completed',
    'SPEI-9988-7766-5544-3322', NOW()
);

/* 4.7 Orden atendida y envío */
UPDATE tb_orders        SET status_string = 'atendida' WHERE ID = @orden4;
UPDATE tb_seller_orders SET status_string = 'atendida' WHERE ID = @sorden4;

/* 4.8 Nadie recibe; el cliente recoge en el punto de recolección */
INSERT INTO tb_logs (table_name, operation, db_user, description)
VALUES ('tb_orders', 'Update', USER(),
        CONCAT('CASO 4: envío a domicilio 5004 sin recepción; el cliente recoge ',
               'en el punto de recolección del proveedor'));

COMMIT;

/* 4.9 Verificación del Caso 4 */
SELECT o.ID AS orden, o.total_products, o.total_cost, o.status_string,
       s.ID AS seller_order, s.status_string AS seller_status
FROM tb_orders o
JOIN tb_seller_orders s ON s.buyer_ID = o.user_ID
WHERE o.ID = @orden4;

SELECT i.ID, i.product_ID, i.provider_ID, i.product_name, i.quantity
FROM tb_order_items i
WHERE i.seller_order_ID = @sorden4
ORDER BY i.ID;

SELECT COUNT(DISTINCT o.user_ID) AS proveedores_distintos
FROM tb_order_items i
JOIN tbd_users_offer_products o ON o.ID = i.provider_ID
WHERE i.seller_order_ID = @sorden4;

SELECT ID, amount, payment_status, transaction_reference
FROM tb_payments
WHERE order_ID = @orden4;

SELECT ID, component_type, `value`, address_sup_ID
FROM tbd_address_componentes
WHERE address_ID = 5004
ORDER BY FIELD(component_type,
    'País','Estado','Municipio','Ciudad','Localidad',
    'Código Postal','Colonia','Calle/Avenida',
    'Número Exterior','Número Interior');

/* ============================================================
   CASO 5 - COMPRA FALLIDA POR FALTA DE INVENTARIO
   ------------------------------------------------------------
   Usuario registrado (1004), 1 producto con stock insuficiente,
   orden NO atendida, cancelación y reasignación del cupón.
   ============================================================ */
SELECT '===== CASO 5: COMPRA FALLIDA POR INVENTARIO =====' AS caso;

SET ROLE "buyer";
SET @u5 = 1004;

SELECT ID, email, nickname FROM tb_users WHERE ID = @u5;

/* 5.1 Validación de inventario: se elige el producto con menor stock */
SELECT ID, SKU, name, current_stock, current_price
INTO @pid5, @sku5, @pname5, @stock5, @precio5
FROM tb_products
WHERE deleted_at IS NULL
ORDER BY current_stock ASC, ID ASC
LIMIT 1;

SELECT @pid5 AS producto, @pname5 AS nombre, @stock5 AS stock, @precio5 AS precio;

/* 5.2 El carrito pide 5 unidades, por encima del inventario */
START TRANSACTION;

INSERT INTO tb_carts (user_ID, status) VALUES (@u5, b'1');
SET @cart5 = LAST_INSERT_ID();

INSERT INTO tbd_shopping_cart (user_ID, product_ID, quantity)
VALUES (@u5, @pid5, 5);

/* 5.3 La orden se crea como NO atendida (sin partidas: no hay stock) */
SET @total5 = @precio5 * 5;

INSERT INTO tb_orders
    (`key`, user_ID, total_products, total_cost, status_string, status)
VALUES (
    CONCAT('ORD-C5-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '-', @u5),
    @u5, 1, @total5, 'no_atendida', b'0'
);
SET @orden5 = LAST_INSERT_ID();

/* 5.4 El cupón queda Pendiente hasta que se decide el destino */
INSERT INTO tb_payments
    (order_ID, payment_method_ID, amount, payment_status,
     transaction_reference, payment_date)
VALUES (
    @orden5, 7, @total5, 'Pending',
    CONCAT('CUPON-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')), NOW()
);
SET @pago5 = LAST_INSERT_ID();

/* 5.5 Cancelación por falta de inventario y reasignación del cupón */
UPDATE tb_orders
SET status_string = 'cancelled'
WHERE ID = @orden5;

UPDATE tb_payments
SET payment_status = 'Refunded',
    transaction_reference = CONCAT('CUPON-REASIGNADO-', @pago5)
WHERE ID = @pago5;

INSERT INTO tb_logs (table_name, operation, db_user, description)
VALUES ('tb_orders', 'Update', USER(),
        CONCAT('CASO 5: orden ', @orden5, ' cancelada por falta de inventario; ',
               'cupón ', @pago5, ' reasignado al cliente'));

COMMIT;

/* 5.6 Verificación del Caso 5 */
SELECT ID, `key`, total_products, total_cost, status_string, status
FROM tb_orders
WHERE ID = @orden5;

SELECT ID, order_ID, amount, payment_status, transaction_reference
FROM tb_payments
WHERE order_ID = @orden5;

SELECT @pid5 AS producto, @pname5 AS nombre, @stock5 AS stock_suficiente_para_5;

SELECT COUNT(*) AS partidas_de_la_orden
FROM tb_order_items
WHERE seller_order_ID = @orden5;

SELECT ID, table_name, operation, description
FROM tb_logs
WHERE description LIKE '%CASO 5%'
ORDER BY ID DESC;

/* ============================================================
   FIN DE LOS 5 CASOS
   ============================================================ */
SELECT 'CASOS DE COMPRA EJECUTADOS - Emigdio Aguirre 240545' AS resultado;
