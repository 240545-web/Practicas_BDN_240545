# Ecosistema de e-commerce — 26 tablas, 72 triggers y generación masiva

Entrega preparada el 27 de octubre de 2026 en la rama Practica03. Ningún SQL ha sido ejecutado contra los contenedores o bases actuales. El Compose y sus puertos no se modificaron para esta entrega.

## Entrega y variantes

- `ENTREGA_3_FASES.md`: entrega completa con exactamente tres bloques: Mermaid, DDL/triggers y rutinas. Los bloques SQL contienen ambas variantes, claramente separadas; seleccionar solo la correspondiente al motor.
- `01_erd.md`: diagrama de las 26 tablas con sus atributos, FK y cardinalidades.
- `02_mysql.sql`: 26 tablas y 72 triggers; MySQL 8.0.16+ (CHECK aplicado), InnoDB, utf8mb4. Base nueva `db_test_ecosystem`.
- `02_postgresql.sql`: 26 tablas, funciones PL/pgSQL y 72 triggers; PostgreSQL 16+, esquema nuevo `ecommerce`, extensión pgcrypto en public.
- `03_mysql.sql` y `03_postgresql.sql`: funciones reutilizables y procedimiento masivo por motor.
- `04_demo_mysql.sql` y `04_demo_postgresql.sql`: semillas sintéticas opcionales, separadas del DDL y del procedimiento. Ejecutar una vez en el modelo nuevo; incluyen los países, métodos de pago 1/2/3 y un producto con stock 20000.
- `model.json`: especificación de las entidades y su agrupación lógica.

El DDL usa CREATE TABLE sin eliminación previa. Si ya existe alguna tabla, detenerse y revisar: estos archivos NO son una migración automática ni un mecanismo de reparación de un esquema anterior. MySQL puede dejar DDL parcialmente aplicado ante un error porque sus operaciones DDL hacen commit implícito. No usar clientes configurados para continuar tras errores. PostgreSQL agrupa el DDL en una transacción.

## Nombres físicos

| Módulo | Tablas |
|---|---|
| Seguridad | tb_users, tb_roles, tb_user_roles, tb_permissions, tb_role_permissions, tb_logs |
| Catálogo | tb_products, tb_categories, tb_product_categories, tb_tags, tb_product_tags, tb_reviews |
| Clientes y ubicación | tb_people, tb_addresses, tbc_countries, tbc_states |
| Compras | tb_carts, tbd_shopping_cart, tb_orders, tb_order_items, tb_wishlists |
| Pagos y envíos | tb_payments, tbc_payment_methods, tb_shipments, tb_carriers, tb_invoices |

Los prefijos mantienen coherencia con las funciones solicitadas. `tbd_shopping_cart` representa cart_items; `tb_wishlists` representa asociaciones usuario-producto. `tb_people.user_id` es UNIQUE: una cuenta tiene cero o una ficha personal. Una orden tiene cero o una factura y cero o muchos pagos, partidas y envíos. Las relaciones N:M se materializan mediante tablas puente. `tb_logs` guarda identificador de entidad y nombre de tabla, sin FK polimórfica a cada entidad auditada.

## Distribución exacta de los 72 triggers por motor

Las 12 tablas principales son: tb_users, tb_categories, tb_products, tb_reviews, tb_people, tb_addresses, tb_carts, tb_orders, tb_wishlists, tb_payments, tb_shipments y tb_invoices.

Cada una tiene:

| Tipo | Eventos | Cantidad por tabla | Total |
|---|---|---:|---:|
| Auditoría | AFTER INSERT, AFTER UPDATE, AFTER DELETE | 3 | 36 |
| Validación | BEFORE INSERT, BEFORE UPDATE | 2 | 24 |
| Bloqueo físico | BEFORE DELETE | 1 | 12 |
| **Total** | | **6** | **72** |

No se crean triggers en logs para evitar recursión. Los auditores guardan las imágenes OLD/NEW en JSON y excluyen password, incluso su hash. Los validadores actualizan updated_at en UPDATE y verifican campos según la entidad: email, credencial, nombres, nacimiento, existencias, precios/importes, rating, dirección, estados y referencias activas de wishlist. Las columnas obligatorias y las demás relaciones se protegen adicionalmente mediante NOT NULL, CHECK, UNIQUE y FK.

El BEFORE DELETE bloquea siempre el borrado físico de esas 12 tablas, tanto si deleted_at está en NULL como si ya tiene fecha. El borrado lógico se realiza con UPDATE deleted_at y genera auditoría UPDATE. Los AFTER DELETE permanecen definidos para completar la matriz de auditoría, pero no se alcanzan en un DELETE normal bloqueado. Las FK usan RESTRICT para evitar eliminaciones implícitas de entidades relacionadas; no se depende de cascadas de DELETE para auditar.

## Separación de responsabilidades y coherencia de compra

Las cuatro funciones solicitadas generan nombres, fechas y seleccionan producto. Una rutina auxiliar crea cuenta/ficha; otra coordina una compra; el procedimiento principal elige el escenario y controla el lote.

- Escenario 1: 1000 personas de EE. UU., edades de 18 a 80.
- Escenario 2: 2000 personas LATAM, edades de 18 a 30 inclusive.
- Escenario 3: 7222 personas LATAM, edades de 18 a 80; `RAND() <= 0.85` o su equivalente PostgreSQL decide actividad por persona. El resultado es probabilístico, no una cuota exacta.
- Los usuarios de baja solo reciben cuenta y ficha personal, ambas con deleted_at. No se crean carritos, partidas, órdenes ni pagos para ellos. Los triggers sí producen sus entradas de auditoría.
- Los activos reciben un carrito de un producto, una orden real con una partida y un pago cuyo importe coincide con el precio y el total. El carrito queda checked_out. No se confunde order_id con user_id.
- La selección exige deleted_at IS NULL y current_stock > 0 y usa FOR UPDATE; el stock se descuenta dentro de la misma transacción. Si no queda producto elegible, se revierte TODO el lote. La rutina no repone existencias automáticamente por cambios posteriores de estado de pedido.
- El producto de prueba tiene 20000 unidades, suficientes para ejecutar los tres escenarios una vez. No se activa la generación al instalar los scripts.
- MySQL usa LAST_INSERT_ID y SHA2. PostgreSQL usa RETURNING id y pgcrypto crypt/gen_salt con bcrypt y coste 10.
- En MySQL, ejecutar CALL fuera de una transacción previa: START TRANSACTION y COMMIT pertenecen al procedimiento; un handler hace ROLLBACK y RESIGNAL. En PostgreSQL, CALL es una sentencia transaccional atómica; un error revierte el lote y también puede envolverse en BEGIN/CALL/COMMIT del cliente. No se intenta ejecutar START TRANSACTION dentro de PL/pgSQL.

Estas rutinas generan datos sintéticos para práctica. No implementan todos los ciclos operativos de devoluciones, cancelaciones, conciliación, reservas o transición de pedidos de una plataforma de producción. Los CHECK de totales exigen positividad; la rutina mantiene la suma de sus propias partidas, pero los triggers no recalculan agregados para escrituras arbitrarias de terceros.

## Orden de aplicación después de revisar el código

Elegir un motor. Instalar primero 02, luego 03 y opcionalmente 04. Crear el esquema de PostgreSQL y la extensión requiere permisos adecuados; crear funciones MySQL puede requerir permisos adicionales según la política de binary logging del servidor. Los scripts no cambian variables globales, roles ni permisos del entorno existente.

Ejemplo de llamadas, comentadas al final de los archivos 03:

- MySQL: `CALL db_test_ecosystem.sp_massive_user_generation(1);`
- PostgreSQL: `CALL ecommerce.sp_massive_user_generation(1);`

La selección aleatoria con ORDER BY RAND()/random() es deliberadamente simple para la práctica y puede ser costosa para catálogos grandes; el bloqueo protege inventario pero puede generar espera entre lotes concurrentes. Si una transacción falla, los contadores AUTO_INCREMENT/IDENTITY pueden dejar huecos, aunque las filas de negocio se reviertan.

## Comprobación realizada

Validación estática del orden de dependencias de FK, equivalencia del ERD con las 26 tablas y conteo de 72 nombres únicos de trigger por variante, distribuidos 36/24/12 y seis por tabla principal. Se comprobaron las funciones auxiliares, escenarios y mecanismos de recuperación de IDs. No se ha verificado ejecución con MySQL/PostgreSQL ni renderizado visual de Mermaid.

Referencias oficiales: [MySQL CREATE TRIGGER](https://dev.mysql.com/doc/refman/8.0/en/create-trigger.html), [PostgreSQL 16 trigger functions](https://www.postgresql.org/docs/16/plpgsql-trigger.html), [PostgreSQL 16 pgcrypto](https://www.postgresql.org/docs/16/pgcrypto.html).
