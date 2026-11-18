# Diccionario de Datos — db_test

## 1. Tabla de contenidos

- [2. Diagrama Entidad-Relación (ERD)](#diagrama-erd)
- [3. Diccionario de tablas y columnas](#diccionario-tablas)
  - [tb_users](#tb_users)
  - [tb_products](#tb_products)
  - [tb_categories](#tb_categories)
  - [tb_seller_orders](#tb_seller_orders)
  - [tb_order_items](#tb_order_items)
  - [tbd_address_componentes](#tbd_address_componentes)
  - [tb_payments](#tb_payments)
  - [tb_logs](#tb_logs)
  - [tb_orders](#tb_orders)
  - [tb_carts](#tb_carts)
  - [tbc_payment_methods](#tbc_payment_methods)
  - [tbd_order_details](#tbd_order_details)
  - [tbd_shopping_cart](#tbd_shopping_cart)
  - [tb_products_categories](#tb_products_categories)
  - [tbd_users_offer_products](#tbd_users_offer_products)
  - [tbd_wishlist](#tbd_wishlist)
  - [tbd_users_wishlist_products](#tbd_users_wishlist_products)
  - [tbc_categories](#tbc_categories)
- [4. Documentación de los 42 Triggers](#documentacion-triggers)
  - [Trazabilidad: 12](#trazabilidad)
  - [Soft Delete: 3](#soft-delete)
  - [Lógica de Negocio: 27](#logica-negocio)

<a id="diagrama-erd"></a>
## 2. Diagrama Entidad-Relación (ERD)

**Proyecto:** Base de Datos en la Nube. **Esquema:** `db_test`. **Fecha de revisión:** 21 de octubre de 2026. **Alcance:** documentación estática de los scripts del repositorio; no certifica el estado de una instancia desplegada.

**Fuentes:** [tablas base](Practica03/backups/Untitled-1.sql), [tablas complementarias](Practica03/scripts/create_tables.sql), [pedidos de vendedor](Practica03/scripts/Create_order_tables.sql), [borrado lógico](Practica03/scripts/soft_delete_system.sql) y [conjunto de 42 triggers](Practica03/scripts/42_triggers.sql). Los tipos corresponden a MySQL/InnoDB, con `utf8mb4_unicode_ci` en las tablas definidas.

**Lectura del ERD:** `||` significa exactamente uno, `o|` cero o uno y `o{` cero o muchos. Cada FK no única permite una relación 1:N; una FK nullable permite que el hijo no tenga padre. No se encontró ninguna FK UNIQUE que garantice una relación 1:1. Las relaciones N:M se materializan mediante tablas puente.

**Diferencias verificadas:** `tbd_address_componentes` no tiene definición SQL localizada; se incluye como entidad pendiente sin inventar atributos ni relaciones. `tbc_categories` es el destino literal de una FK, pero tampoco tiene definición localizada: no se sustituye silenciosamente por `tb_categories`. `tb_orders` y `tb_seller_orders` son cabeceras distintas sin FK entre sí; los pagos pertenecen a la primera. `tb_logs` no tiene FK hacia las entidades auditadas.

```mermaid
erDiagram
    tb_users {
        INT ID PK
        VARCHAR(80) email UK
        VARCHAR(100) nickname UK
        VARCHAR(255) password
        DATETIME creation_date
        DATETIME last_update
        DATETIME last_login
        DATETIME deleted_at
    }
    tb_products {
        INT_UNSIGNED ID PK
        VARCHAR(50) SKU UK
        VARCHAR(250) name
        TEXT description
        INT_UNSIGNED category_id FK
        DECIMAL(10,2) current_price
        INT_UNSIGNED current_stock
        BIT(1) status
        DATETIME creation_date
        DATETIME last_update
        DATETIME deleted_at
    }
    tb_categories {
        INT_UNSIGNED ID PK
        VARCHAR(150) name UK
        TEXT description
        BIT(1) status
        DATETIME creation_date
        DATETIME last_update
        DATETIME deleted_at
    }
    tb_seller_orders {
        INT_UNSIGNED ID PK
        VARCHAR(40) key UK
        INT seller_ID FK
        INT buyer_ID FK
        VARCHAR(50) status_string
        BIT(1) status
        INT_UNSIGNED total_items
        DECIMAL(12,2) total_amount
        DATETIME creation_date
        DATETIME last_update
    }
    tb_order_items {
        INT_UNSIGNED ID PK
        INT_UNSIGNED seller_order_ID FK
        INT_UNSIGNED product_ID FK
        INT_UNSIGNED provider_ID FK
        VARCHAR(255) product_name
        INT_UNSIGNED quantity
        DECIMAL(12,2) unit_price
        DECIMAL(12,2) subtotal
        DATETIME creation_date
    }
    tbd_address_componentes {
        string estado "DDL no localizado"
    }
    tb_payments {
        INT_UNSIGNED ID PK
        INT_UNSIGNED order_ID FK
        INT_UNSIGNED payment_method_ID FK
        DECIMAL(10,2) amount
        ENUM payment_status
        VARCHAR(150) transaction_reference
        DATETIME payment_date
    }
    tb_logs {
        INT ID PK
        VARCHAR(100) table_name
        ENUM operation
        VARCHAR(80) db_user
        TEXT description
        DATETIME operation_date
        BIT(1) operation_status
    }
    tb_orders {
        INT_UNSIGNED ID PK
        VARCHAR(40) key UK
        INT user_ID FK
        INT_UNSIGNED total_products
        DECIMAL(10,3) total_cost
        VARCHAR(50) status_string
        BIT(1) status
        DATETIME creation_date
        DATETIME last_update
    }
    tb_carts {
        INT_UNSIGNED ID PK
        INT user_ID FK
        BIT(1) status
        DATETIME creation_date
        DATETIME last_update
    }
    tbc_payment_methods {
        INT_UNSIGNED ID PK
        VARCHAR(100) name UK
        TEXT description
        BIT(1) status
        DATETIME creation_date
    }
    tbd_order_details {
        INT_UNSIGNED ID PK
        INT_UNSIGNED order_ID FK
        INT_UNSIGNED product_ID FK
        INT_UNSIGNED quantity
        DECIMAL(10,2) unit_price
        DECIMAL(10,2) subtotal
        DATETIME creation_date
    }
    tbd_shopping_cart {
        INT_UNSIGNED ID PK
        INT user_ID FK
        INT_UNSIGNED offer_ID
        INT_UNSIGNED product_ID FK
        INT_UNSIGNED quantity
        DATETIME creation_date
        DATETIME last_update
    }
    tb_products_categories {
        INT_UNSIGNED category_ID PK,FK
        INT_UNSIGNED product_ID PK,FK
        BIT(1) status
        DATETIME creation_date
        DATETIME last_update
    }
    tbd_users_offer_products {
        INT_UNSIGNED ID PK
        INT user_ID FK
        INT_UNSIGNED product_ID FK
        INT_UNSIGNED available_stock
        BIT(1) status
        DATETIME creation_date
        DATETIME available_date
        DATETIME last_update
    }
    tbd_wishlist {
        INT_UNSIGNED ID PK
        INT user_ID FK
        INT_UNSIGNED product_ID FK
        DATETIME creation_date
    }
    tbd_users_wishlist_products {
        INT user_ID PK,FK
        INT_UNSIGNED product_ID PK,FK
        BIT(1) status
        DATETIME creation_date
        DATETIME last_update
    }
    tbc_categories {
        string estado "DDL no localizado"
    }
    tb_categories |o--o{ tb_products : "category_id"
    tb_users ||--o{ tb_orders : "user_ID"
    tb_users ||--o{ tb_carts : "user_ID"
    tb_orders ||--o{ tb_payments : "order_ID"
    tbc_payment_methods ||--o{ tb_payments : "payment_method_ID"
    tb_orders ||--o{ tbd_order_details : "order_ID"
    tb_products ||--o{ tbd_order_details : "product_ID"
    tb_users ||--o{ tbd_shopping_cart : "user_ID"
    tb_products ||--o{ tbd_shopping_cart : "product_ID"
    tbc_categories ||--o{ tb_products_categories : "category_ID"
    tb_products ||--o{ tb_products_categories : "product_ID"
    tb_users ||--o{ tbd_users_offer_products : "user_ID"
    tb_products ||--o{ tbd_users_offer_products : "product_ID"
    tb_users ||--o{ tbd_wishlist : "user_ID"
    tb_products ||--o{ tbd_wishlist : "product_ID"
    tb_users ||--o{ tbd_users_wishlist_products : "user_ID"
    tb_products ||--o{ tbd_users_wishlist_products : "product_ID"
    tb_users ||--o{ tb_seller_orders : "seller_ID"
    tb_users ||--o{ tb_seller_orders : "buyer_ID"
    tb_seller_orders ||--o{ tb_order_items : "seller_order_ID"
    tb_products ||--o{ tb_order_items : "product_ID"
    tbd_users_offer_products ||--o{ tb_order_items : "provider_ID"
```

**Integridad referencial:** los campos de FK se describen individualmente abajo con sus acciones `ON DELETE` y `ON UPDATE`. El ERD expresa restricciones declaradas, incluida la referencia no resuelta a `tbc_categories`; no asegura que todos los scripts puedan desplegarse juntos sin corregirla.

<a id="diccionario-tablas"></a>
## 3. Diccionario de tablas y columnas

**Convenciones:** PK = clave primaria; FK = clave foránea; PK, FK = ambas; N/A = ninguna. Los identificadores numéricos y los estados son cualitativos porque representan categorías, no magnitudes. Importes, cantidades y existencias son cuantitativos. Las fechas se clasifican como cualitativas temporales. `Almacenado` indica dato base persistido; `Derivado` indica cálculo o metadato temporal automático. Una relación con múltiples filas no convierte una columna escalar en multivalor; no se encontraron columnas de arreglos o listas multivalor. Las restricciones se distinguen de las interpretaciones funcionales; una regla en INSERT no se presupone vigente en UPDATE.

<a id="tb_users"></a>
## tb_users

Identidades de las personas que compran, venden y mantienen ofertas o listas de deseos. Email y nickname son únicos; el DDL no define roles ni perfiles separados.

**Triggers asociados: 6.** Trazabilidad (3): `trg_users_ai`, `trg_users_au`, `trg_users_ad`; Soft Delete (1): `trg_users_bd`; Lógica de Negocio (2): `trg_users_pass_bi`, `trg_users_email_bi`.

**Fuente física:** [Practica03/backups/Untitled-1.sql](Practica03/backups/Untitled-1.sql). `deleted_at` se incorpora desde [soft_delete_system.sql](Practica03/scripts/soft_delete_system.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT` | PK | Obligatorio | Cualitativa | Almacenado | Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `email` | `VARCHAR(80)` | N/A | Obligatorio | Cualitativa | Almacenado | UNIQUE `uk_tb_users_email` (email); Sin DEFAULT explícito; Hasta 80 caracteres; Reglas: `trg_users_email_bi` (BEFORE INSERT); véase sección 4 | Dirección de correo que identifica la cuenta; el trigger solo comprueba el patrón básico al insertar. |
| `nickname` | `VARCHAR(100)` | N/A | Obligatorio | Cualitativa | Almacenado | UNIQUE `uk_tb_users_nickname` (nickname); Sin DEFAULT explícito; Hasta 100 caracteres | Alias público de la cuenta; su unicidad se impone mediante índice UNIQUE. |
| `password` | `VARCHAR(255)` | N/A | Obligatorio | Cualitativa | Almacenado | Sin DEFAULT explícito; Hasta 255 caracteres; Reglas: `trg_users_pass_bi` (BEFORE INSERT); véase sección 4 | Representación persistida de la credencial. El DDL no exige un algoritmo de hash; LENGTH valida los bytes almacenados, no la contraseña original. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |
| `last_update` | `DATETIME` | N/A | Opcional | Cualitativa | Derivado | DEFAULT NULL; ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación, mantenida mediante ON UPDATE CURRENT_TIMESTAMP. |
| `last_login` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado | DEFAULT NULL | Fecha y hora del último acceso; no existe trigger de los 42 que la establezca. |
| `deleted_at` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado | DEFAULT NULL | Marca de borrado lógico: NULL indica ausencia de borrado; una fecha indica cuándo se eliminó lógicamente. Se agrega mediante soft_delete_system.sql. |

<a id="tb_products"></a>
## tb_products

Catálogo de productos con SKU, precio vigente, existencias globales y categoría principal opcional. El inventario global se modifica al insertar o borrar partidas de pedidos de vendedor.

**Triggers asociados: 8.** Trazabilidad (3): `trg_products_ai`, `trg_products_au`, `trg_products_ad`; Soft Delete (1): `trg_products_bd`; Lógica de Negocio (4): `trg_products_price_bi`, `trg_products_stock_bu`, `trg_products_sku_bu`, `trg_products_sku_fmt_bi`.

**Fuente física:** [Practica03/backups/Untitled-1.sql](Practica03/backups/Untitled-1.sql). `deleted_at` se incorpora desde [soft_delete_system.sql](Practica03/scripts/soft_delete_system.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `SKU` | `VARCHAR(50)` | N/A | Obligatorio | Cualitativa | Almacenado | UNIQUE `uk_tb_products_sku` (SKU); Sin DEFAULT explícito; Hasta 50 caracteres; Reglas: `trg_products_sku_bu` (BEFORE UPDATE), `trg_products_sku_fmt_bi` (BEFORE INSERT); véase sección 4 | Identificador comercial único del producto; se exige prefijo SKU- al insertar y se impide modificarlo. |
| `name` | `VARCHAR(250)` | N/A | Obligatorio | Cualitativa | Almacenado | Sin DEFAULT explícito; Hasta 250 caracteres | Nombre legible del registro dentro del catálogo correspondiente. |
| `description` | `TEXT` | N/A | Opcional | Cualitativa | Almacenado | Sin DEFAULT explícito | Descripción ampliada del registro o, en la bitácora, texto que explica la operación. |
| `category_id` | `INT UNSIGNED` | FK | Opcional | Cualitativa | Almacenado | Entero ≥ 0; FK → tb_categories.ID; DELETE SET NULL; UPDATE CASCADE; Sin DEFAULT explícito | Categoría principal opcional del producto; no sincroniza automáticamente la tabla puente. |
| `current_price` | `DECIMAL(10,2)` | N/A | Obligatorio | Cuantitativa | Almacenado | DEFAULT 0.00; Precisión y escala 10,2; CHECK current_price >= 0; Reglas: `trg_products_price_bi` (BEFORE INSERT); véase sección 4 | Precio vigente del catálogo; puede diferir del precio histórico de una partida. |
| `current_stock` | `INT UNSIGNED` | N/A | Obligatorio | Cuantitativa | Almacenado | Entero ≥ 0; DEFAULT 0; CHECK current_stock >= 0; Reglas: `trg_products_stock_bu` (BEFORE UPDATE); véase sección 4 | Existencias globales del producto; se descuentan al insertar partidas y se restituyen al borrarlas explícitamente. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT b'1'; 0 o 1 | Indicador binario de habilitación del registro; no sustituye a deleted_at. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP; ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación, mantenida mediante ON UPDATE CURRENT_TIMESTAMP. |
| `deleted_at` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado | DEFAULT NULL | Marca de borrado lógico: NULL indica ausencia de borrado; una fecha indica cuándo se eliminó lógicamente. Se agrega mediante soft_delete_system.sql. |

<a id="tb_categories"></a>
## tb_categories

Catálogo de clasificación principal de productos. El nombre es único; el borrado lógico conserva las referencias existentes.

**Triggers asociados: 5.** Trazabilidad (3): `trg_cats_ai`, `trg_cats_au`, `trg_cats_ad`; Soft Delete (1): `trg_cats_bd`; Lógica de Negocio (1): `trg_cats_name_bi`.

**Fuente física:** [Practica03/backups/Untitled-1.sql](Practica03/backups/Untitled-1.sql). `deleted_at` se incorpora desde [soft_delete_system.sql](Practica03/scripts/soft_delete_system.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `name` | `VARCHAR(150)` | N/A | Obligatorio | Cualitativa | Almacenado | UNIQUE `uk_tb_categories_name` (name); Sin DEFAULT explícito; Hasta 150 caracteres; Reglas: `trg_cats_name_bi` (BEFORE INSERT); véase sección 4 | Nombre legible del registro dentro del catálogo correspondiente. |
| `description` | `TEXT` | N/A | Opcional | Cualitativa | Almacenado | Sin DEFAULT explícito | Descripción ampliada del registro o, en la bitácora, texto que explica la operación. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT b'1'; 0 o 1 | Indicador binario de habilitación del registro; no sustituye a deleted_at. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP; ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación, mantenida mediante ON UPDATE CURRENT_TIMESTAMP. |
| `deleted_at` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado | DEFAULT NULL | Marca de borrado lógico: NULL indica ausencia de borrado; una fecha indica cuándo se eliminó lógicamente. Se agrega mediante soft_delete_system.sql. |

<a id="tb_seller_orders"></a>
## tb_seller_orders

Cabecera comercial que vincula un vendedor y un comprador con sus partidas. Es independiente de tb_orders; el esquema no proporciona una relación entre ambas cabeceras.

**Triggers asociados: 5.** Trazabilidad (3): `trg_sorders_ai`, `trg_sorders_au`, `trg_sorders_ad`; Lógica de Negocio (2): `trg_sorders_diff_bi`, `trg_sorders_cancel_bu`.

**Fuente física:** [Practica03/scripts/Create_order_tables.sql](Practica03/scripts/Create_order_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `key` | `VARCHAR(40)` | N/A | Obligatorio | Cualitativa | Almacenado | UNIQUE uk_seller_orders_key (key); Sin DEFAULT explícito; Hasta 40 caracteres | Clave pública alternativa de la cabecera; única y obligatoria, sin generación automática declarada. |
| `seller_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado | FK → tb_users.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito; Reglas: `trg_sorders_diff_bi` (BEFORE INSERT); véase sección 4 | Usuario que vende los productos de este pedido. |
| `buyer_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado | FK → tb_users.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito; Reglas: `trg_sorders_diff_bi` (BEFORE INSERT); véase sección 4 | Usuario que compra los productos de este pedido. |
| `status_string` | `VARCHAR(50)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT 'pending'; Hasta 50 caracteres; Reglas: `trg_sorders_cancel_bu` (BEFORE UPDATE); véase sección 4 | Estado comercial textual del pedido; VARCHAR sin enumeración ni máquina de estados declarada. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT b'1'; 0 o 1 | Indicador binario de habilitación del registro; no sustituye a deleted_at. |
| `total_items` | `INT UNSIGNED` | N/A | Obligatorio | Cuantitativa | Almacenado | Entero ≥ 0; DEFAULT 0 | Total declarado de unidades o partidas del pedido; el SQL no define qué criterio usa ni lo recalcula. Se clasifica como dato base porque no existe cálculo impuesto por el esquema, aunque funcionalmente represente un agregado. |
| `total_amount` | `DECIMAL(12,2)` | N/A | Obligatorio | Cuantitativa | Almacenado | DEFAULT 0.00; Precisión y escala 12,2 | Importe total declarado del pedido de vendedor; no existe suma automática de subtotales. Se clasifica como dato base porque no existe cálculo impuesto por el esquema, aunque funcionalmente represente un agregado. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP; ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación, mantenida mediante ON UPDATE CURRENT_TIMESTAMP. |

<a id="tb_order_items"></a>
## tb_order_items

Partidas de pedidos de vendedor. Conserva nombre y precio de la compra, referencia el producto y la oferta del proveedor y calcula el subtotal mediante una columna generada almacenada.

**Triggers asociados: 6.** Lógica de Negocio (6): `trg_oitems_qty_bi`, `trg_oitems_price_bi`, `trg_oitems_stock_bi`, `trg_oitems_stock_ai`, `trg_oitems_stock_ad`, `trg_oitems_order_bu`.

**Fuente física:** [Practica03/scripts/Create_order_tables.sql](Practica03/scripts/Create_order_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `seller_order_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; FK → tb_seller_orders.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito; Reglas: `trg_oitems_order_bu` (BEFORE UPDATE); véase sección 4 | Cabecera de pedido de vendedor que contiene la partida; el trigger impide reasignarla por UPDATE. |
| `product_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; FK → tb_products.ID; DELETE RESTRICT; UPDATE CASCADE; Sin DEFAULT explícito; Reglas: `trg_oitems_stock_bi` (BEFORE INSERT), `trg_oitems_stock_ai` (AFTER INSERT), `trg_oitems_stock_ad` (AFTER DELETE); véase sección 4 | Producto al que corresponde el registro. |
| `provider_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; FK → tbd_users_offer_products.ID; DELETE RESTRICT; UPDATE CASCADE; Sin DEFAULT explícito | Identificador de oferta en tbd_users_offer_products; no es directamente un ID de usuario. |
| `product_name` | `VARCHAR(255)` | N/A | Obligatorio | Cualitativa | Almacenado | Sin DEFAULT explícito; Hasta 255 caracteres | Nombre del producto conservado en la partida; no se copia ni sincroniza automáticamente mediante los 42 triggers. |
| `quantity` | `INT UNSIGNED` | N/A | Obligatorio | Cuantitativa | Almacenado | Entero ≥ 0; Sin DEFAULT explícito; CHECK quantity > 0; Reglas: `trg_oitems_qty_bi` (BEFORE INSERT), `trg_oitems_stock_bi` (BEFORE INSERT), `trg_oitems_stock_ai` (AFTER INSERT), `trg_oitems_stock_ad` (AFTER DELETE); véase sección 4 | Número de unidades del producto en la partida o selección. |
| `unit_price` | `DECIMAL(12,2)` | N/A | Obligatorio | Cuantitativa | Almacenado | Sin DEFAULT explícito; Precisión y escala 12,2; CHECK unit_price >= 0; Reglas: `trg_oitems_price_bi` (BEFORE INSERT); véase sección 4 | Precio unitario persistido para la operación; no se obtiene automáticamente del catálogo. |
| `subtotal` | `DECIMAL(12,2)` | N/A | Opcional | Cuantitativa | Derivado | Precisión y escala 12,2 | Importe de la partida. Calculado como quantity * unit_price mediante GENERATED ALWAYS AS (...) STORED; no se captura manualmente. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |

<a id="tbd_address_componentes"></a>
## tbd_address_componentes

Entidad solicitada para componentes de direcciones, pendiente de definición: no es posible establecer propósito físico, columnas, llaves, tipos, nulabilidad o cardinalidades verificables.

**Triggers asociados:** 0 en el conjunto de 42; no se identificaron triggers con este nombre de tabla.

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| No documentable: DDL no localizado | No determinado | No determinado | No determinado | No determinada | No determinada | Pendiente de aportar el DDL | Esta fila es una nota de ausencia de definición, no una columna física. |

<a id="tb_payments"></a>
## tb_payments

Registros de pago de pedidos generales, con importe, método, estado y referencia externa opcional. Un pedido admite varios pagos: order_ID no es único.

**Triggers asociados: 3.** Lógica de Negocio (3): `trg_payments_bu`, `trg_payments_amt_bi`, `trg_payments_status_bi`.

**Fuente física:** [Practica03/scripts/create_tables.sql](Practica03/scripts/create_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `order_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; FK → tb_orders.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito | Cabecera general tb_orders a la que pertenece el pago o detalle. |
| `payment_method_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; FK → tbc_payment_methods.ID; DELETE RESTRICT; UPDATE CASCADE; Sin DEFAULT explícito | Método de pago registrado en el catálogo. |
| `amount` | `DECIMAL(10,2)` | N/A | Obligatorio | Cuantitativa | Almacenado | DEFAULT 0.00; Precisión y escala 10,2; Reglas: `trg_payments_amt_bi` (BEFORE INSERT); véase sección 4 | Importe de este pago; no se verifica automáticamente contra el total del pedido. |
| `payment_status` | `ENUM('Pending','Completed','Failed','Refunded')` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT 'Pending'; Enum: 'Pending','Completed','Failed','Refunded'; Reglas: `trg_payments_bu` (BEFORE UPDATE), `trg_payments_status_bi` (BEFORE INSERT); véase sección 4 | Estado del pago. Una fila cuyo estado previo es Completed rechaza cualquier UPDATE. |
| `transaction_reference` | `VARCHAR(150)` | N/A | Opcional | Cualitativa | Almacenado | Sin DEFAULT explícito; Hasta 150 caracteres | Referencia externa del proveedor de pagos; no tiene índice UNIQUE declarado. |
| `payment_date` | `DATETIME` | N/A | Opcional | Cualitativa | Almacenado | Sin DEFAULT explícito | Fecha efectiva del pago; opcional y sin asignación automática declarada. |

<a id="tb_logs"></a>
## tb_logs

Bitácora de operaciones emitidas por triggers y procedimientos. Guarda el usuario de conexión y una descripción textual, sin FK al registro auditado ni al usuario de la aplicación.

**Triggers asociados: 0.** ninguno en este conjunto.

**Fuente física:** [Practica03/backups/Untitled-1.sql](Practica03/backups/Untitled-1.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT` | PK | Obligatorio | Cualitativa | Almacenado | Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `table_name` | `VARCHAR(100)` | N/A | Obligatorio | Cualitativa | Almacenado | Sin DEFAULT explícito; Hasta 100 caracteres | Nombre textual de la tabla auditada; no constituye una FK al catálogo SQL. |
| `operation` | `ENUM('Create','Read','Update','Delete')` | N/A | Obligatorio | Cualitativa | Almacenado | Sin DEFAULT explícito; Enum: 'Create','Read','Update','Delete' | Categoría de operación registrada. Los 12 triggers de trazabilidad generan Create, Update o Delete. |
| `db_user` | `VARCHAR(80)` | N/A | Obligatorio | Cualitativa | Almacenado | Sin DEFAULT explícito; Hasta 80 caracteres | Identidad de conexión retornada por USER(); no equivale necesariamente a un usuario de tb_users. |
| `description` | `TEXT` | N/A | Obligatorio | Cualitativa | Almacenado | Sin DEFAULT explícito | Descripción ampliada del registro o, en la bitácora, texto que explica la operación. Los triggers del conjunto de 42 no guardan una copia completa de OLD/NEW. |
| `operation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de escritura de la entrada de bitácora. |
| `operation_status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT b'1'; 0 o 1 | Indicador binario persistido de la entrada; no prueba que se auditen transacciones fallidas. |

<a id="tb_orders"></a>
## tb_orders

Cabecera general de pedidos vinculada a un usuario; sus detalles están en tbd_order_details y sus pagos en tb_payments. No existe FK a tb_seller_orders.

**Triggers asociados: 1.** Lógica de Negocio (1): `trg_orders_total_bi`.

**Fuente física:** [Practica03/scripts/create_tables.sql](Practica03/scripts/create_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `key` | `VARCHAR(40)` | N/A | Obligatorio | Cualitativa | Almacenado | UNIQUE uk_orders_key (key); Sin DEFAULT explícito; Hasta 40 caracteres | Clave pública alternativa de la cabecera; única y obligatoria, sin generación automática declarada. |
| `user_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado | FK → tb_users.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito | Usuario propietario o responsable de este registro. |
| `total_products` | `INT UNSIGNED` | N/A | Obligatorio | Cuantitativa | Almacenado | Entero ≥ 0; DEFAULT 0 | Total declarado de productos del pedido; no existe actualización automática desde los detalles. Se clasifica como dato base porque no existe cálculo impuesto por el esquema, aunque funcionalmente represente un agregado. |
| `total_cost` | `DECIMAL(10,3)` | N/A | Obligatorio | Cuantitativa | Almacenado | DEFAULT 0.000; Precisión y escala 10,3; Reglas: `trg_orders_total_bi` (BEFORE INSERT); véase sección 4 | Importe total declarado del pedido general; no existe cálculo automático desde los detalles. Se clasifica como dato base porque no existe cálculo impuesto por el esquema, aunque funcionalmente represente un agregado. |
| `status_string` | `VARCHAR(50)` | N/A | Obligatorio | Cualitativa | Almacenado | Sin DEFAULT explícito; Hasta 50 caracteres | Estado comercial textual del pedido; VARCHAR sin enumeración ni máquina de estados declarada. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT b'1'; 0 o 1 | Indicador binario de habilitación del registro; no sustituye a deleted_at. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP; ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación, mantenida mediante ON UPDATE CURRENT_TIMESTAMP. |

<a id="tb_carts"></a>
## tb_carts

Cabeceras de carrito por usuario. No existe FK desde tbd_shopping_cart hacia esta tabla ni unicidad de carrito por usuario.

**Triggers asociados: 0.** ninguno en este conjunto.

**Fuente física:** [Practica03/scripts/create_tables.sql](Practica03/scripts/create_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `user_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado | FK → tb_users.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito | Usuario propietario o responsable de este registro. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT b'1'; 0 o 1 | Indicador binario de habilitación del registro; no sustituye a deleted_at. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP; ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación, mantenida mediante ON UPDATE CURRENT_TIMESTAMP. |

<a id="tbc_payment_methods"></a>
## tbc_payment_methods

Catálogo de métodos de pago con nombre único, descripción y estado de habilitación.

**Triggers asociados: 0.** ninguno en este conjunto.

**Fuente física:** [Practica03/scripts/create_tables.sql](Practica03/scripts/create_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `name` | `VARCHAR(100)` | N/A | Obligatorio | Cualitativa | Almacenado | UNIQUE uk_payment_methods_name (name); Sin DEFAULT explícito; Hasta 100 caracteres | Nombre legible del registro dentro del catálogo correspondiente. |
| `description` | `TEXT` | N/A | Opcional | Cualitativa | Almacenado | Sin DEFAULT explícito | Descripción ampliada del registro o, en la bitácora, texto que explica la operación. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT b'1'; 0 o 1 | Indicador binario de habilitación del registro; no sustituye a deleted_at. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |

<a id="tbd_order_details"></a>
## tbd_order_details

Partidas del pedido general. El subtotal es un dato persistido ordinario; ningún trigger de los 42 lo calcula ni actualiza automáticamente la cabecera.

**Triggers asociados: 2.** Lógica de Negocio (2): `trg_odetails_qty_bi`, `trg_odetails_price_bi`.

**Fuente física:** [Practica03/scripts/create_tables.sql](Practica03/scripts/create_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `order_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; FK → tb_orders.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito | Cabecera general tb_orders a la que pertenece el pago o detalle. |
| `product_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; FK → tb_products.ID; DELETE RESTRICT; UPDATE CASCADE; Sin DEFAULT explícito | Producto al que corresponde el registro. |
| `quantity` | `INT UNSIGNED` | N/A | Obligatorio | Cuantitativa | Almacenado | Entero ≥ 0; DEFAULT 1; Reglas: `trg_odetails_qty_bi` (BEFORE INSERT); véase sección 4 | Número de unidades del producto en la partida o selección. |
| `unit_price` | `DECIMAL(10,2)` | N/A | Obligatorio | Cuantitativa | Almacenado | DEFAULT 0.00; Precisión y escala 10,2; Reglas: `trg_odetails_price_bi` (BEFORE INSERT); véase sección 4 | Precio unitario persistido para la operación; no se obtiene automáticamente del catálogo. |
| `subtotal` | `DECIMAL(10,2)` | N/A | Obligatorio | Cuantitativa | Almacenado | DEFAULT 0.00; Precisión y escala 10,2 | Importe de la partida. No tiene expresión GENERATED ni trigger de cálculo; la aplicación debe mantener su coherencia con quantity * unit_price. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |

<a id="tbd_shopping_cart"></a>
## tbd_shopping_cart

Productos seleccionados por usuario. La referencia offer_ID es opcional y carece de FK; la prevención de duplicados se implementa únicamente al insertar mediante trigger.

**Triggers asociados: 2.** Lógica de Negocio (2): `trg_cart_dup_bi`, `trg_cart_qty_bi`.

**Fuente física:** [Practica03/scripts/create_tables.sql](Practica03/scripts/create_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `user_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado | FK → tb_users.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito; Reglas: `trg_cart_dup_bi` (BEFORE INSERT); véase sección 4 | Usuario propietario o responsable de este registro. |
| `offer_ID` | `INT UNSIGNED` | N/A | Opcional | Cualitativa | Almacenado | Entero ≥ 0; Sin DEFAULT explícito | Referencia lógica opcional a una oferta; no está respaldada por una FK en el DDL. |
| `product_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; FK → tb_products.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito; Reglas: `trg_cart_dup_bi` (BEFORE INSERT); véase sección 4 | Producto al que corresponde el registro. |
| `quantity` | `INT UNSIGNED` | N/A | Obligatorio | Cuantitativa | Almacenado | Entero ≥ 0; DEFAULT 1; Reglas: `trg_cart_qty_bi` (BEFORE INSERT); véase sección 4 | Número de unidades del producto en la partida o selección. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP; ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación, mantenida mediante ON UPDATE CURRENT_TIMESTAMP. |

<a id="tb_products_categories"></a>
## tb_products_categories

Tabla puente de clasificación múltiple por producto. Su FK de categoría apunta a tbc_categories, nombre sin definición CREATE TABLE localizada en las fuentes.

**Triggers asociados: 1.** Lógica de Negocio (1): `trg_pc_delete_bd`.

**Fuente física:** [Practica03/scripts/create_tables.sql](Practica03/scripts/create_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `category_ID` | `INT UNSIGNED` | PK, FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único en combinación con product_ID; FK → tbc_categories.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito; Reglas: `trg_pc_delete_bd` (BEFORE DELETE); véase sección 4 | Categoría de la asociación; el destino literal de la FK es tbc_categories.ID. |
| `product_ID` | `INT UNSIGNED` | PK, FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único en combinación con category_ID; FK → tb_products.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito | Producto al que corresponde el registro. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT b'1'; 0 o 1 | Indicador binario de habilitación del registro; no sustituye a deleted_at. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP; ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación, mantenida mediante ON UPDATE CURRENT_TIMESTAMP. |

<a id="tbd_users_offer_products"></a>
## tbd_users_offer_products

Ofertas de productos publicadas por usuarios, con stock ofertado y fecha de disponibilidad. Su ID es el destino de provider_ID en tb_order_items.

**Triggers asociados: 2.** Lógica de Negocio (2): `trg_offer_stock_bi`, `trg_offer_date_bi`.

**Fuente física:** [Practica03/scripts/create_tables.sql](Practica03/scripts/create_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `user_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado | FK → tb_users.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito | Usuario propietario o responsable de este registro. |
| `product_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; FK → tb_products.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito | Producto al que corresponde el registro. |
| `available_stock` | `INT UNSIGNED` | N/A | Obligatorio | Cuantitativa | Almacenado | Entero ≥ 0; DEFAULT 0; Reglas: `trg_offer_stock_bi` (BEFORE INSERT); véase sección 4 | Unidades declaradas como disponibles en la oferta; no se sincronizan con current_stock ni con las partidas. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT b'1'; 0 o 1 | Indicador binario de habilitación del registro; no sustituye a deleted_at. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |
| `available_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Almacenado | Sin DEFAULT explícito; Reglas: `trg_offer_date_bi` (BEFORE INSERT); véase sección 4 | Fecha de disponibilidad de la oferta; al insertar no puede ser anterior a NOW(). |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP; ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación, mantenida mediante ON UPDATE CURRENT_TIMESTAMP. |

<a id="tbd_wishlist"></a>
## tbd_wishlist

Lista de deseos de usuarios con identificador propio y restricción única sobre el par usuario-producto.

**Triggers asociados: 1.** Lógica de Negocio (1): `trg_wishlist_bi`.

**Fuente física:** [Practica03/scripts/create_tables.sql](Practica03/scripts/create_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `ID` | `INT UNSIGNED` | PK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único; AUTO_INCREMENT | Identificador técnico de la fila, generado con AUTO_INCREMENT. |
| `user_ID` | `INT` | FK | Obligatorio | Cualitativa | Almacenado | UNIQUE uk_wishlist_user_product (user_ID, product_ID); FK → tb_users.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito | Usuario propietario o responsable de este registro. |
| `product_ID` | `INT UNSIGNED` | FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; UNIQUE uk_wishlist_user_product (user_ID, product_ID); FK → tb_products.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito; Reglas: `trg_wishlist_bi` (BEFORE INSERT); véase sección 4 | Producto al que corresponde el registro. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |

<a id="tbd_users_wishlist_products"></a>
## tbd_users_wishlist_products

Asociación alternativa entre usuarios y productos deseados, con PK compuesta y estado. Coexiste con tbd_wishlist sin FK ni sincronización entre ambas.

**Triggers asociados: 0.** ninguno en este conjunto.

**Fuente física:** [Practica03/scripts/create_tables.sql](Practica03/scripts/create_tables.sql).

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| `user_ID` | `INT` | PK, FK | Obligatorio | Cualitativa | Almacenado | Único en combinación con product_ID; FK → tb_users.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito | Usuario propietario o responsable de este registro. |
| `product_ID` | `INT UNSIGNED` | PK, FK | Obligatorio | Cualitativa | Almacenado | Entero ≥ 0; Único en combinación con user_ID; FK → tb_products.ID; DELETE CASCADE; UPDATE CASCADE; Sin DEFAULT explícito | Producto al que corresponde el registro. |
| `status` | `BIT(1)` | N/A | Obligatorio | Cualitativa | Almacenado | DEFAULT b'1'; 0 o 1 | Indicador binario de habilitación del registro; no sustituye a deleted_at. |
| `creation_date` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro, inicializada por el servidor. |
| `last_update` | `DATETIME` | N/A | Obligatorio | Cualitativa | Derivado | DEFAULT CURRENT_TIMESTAMP; ON UPDATE CURRENT_TIMESTAMP | Fecha y hora de la última modificación, mantenida mediante ON UPDATE CURRENT_TIMESTAMP. |

<a id="tbc_categories"></a>
## tbc_categories

Destino literal de tb_products_categories.category_ID. No se encontró CREATE TABLE de este catálogo; su estructura y relación con tb_categories están pendientes de resolución.

**Triggers asociados:** 0 en el conjunto de 42; no se identificaron triggers con este nombre de tabla.

| Nombre de la Columna | Tipo de Dato / Composición | Llave | Obligatoriedad | Naturaleza | Clasificación | Dominio | Descripción Detallada |
|---|---|---|---|---|---|---|---|
| No documentable: DDL no localizado | No determinado | No determinado | No determinado | No determinada | No determinada | Pendiente de aportar el DDL | Esta fila es una nota de ausencia de definición, no una columna física. |

<a id="documentacion-triggers"></a>
## Documentación de los 42 Triggers

**Fuente canónica del inventario:** `Practica03/scripts/42_triggers.sql`: 12 de Trazabilidad + 3 de Soft Delete + 27 de Lógica de Negocio = **42 definiciones distintas**. Todos son `FOR EACH ROW`. “Tabla Afectada” identifica la tabla del evento; la lógica indica escrituras secundarias.

**Alcance y límites de ejecución:** los triggers de bloqueo emiten `SIGNAL SQLSTATE '45000'`; no realizan el borrado lógico por sí mismos. Los procedimientos `sp_soft_delete_user`, `sp_soft_delete_product` y `sp_soft_delete_category` establecen `deleted_at` mediante UPDATE; sus equivalentes `sp_restore_*` lo restauran a NULL. Un DELETE directo bloqueado no llega al AFTER DELETE de auditoría. Los triggers de auditoría no cubren SELECT ni escrituras directas a todas las tablas.

Las acciones referenciales en cascada no deben tratarse como DELETE explícitos de cada fila hija: no se puede asumir que el trigger de reposición de inventario se ejecute por una cascada. No existe compensación de stock por UPDATE de cantidad, producto o proveedor, ni por cancelación de una cabecera. Los 42 triggers tampoco mantienen los totales de cabecera.

El archivo elimina previamente solo sus propios nombres abreviados; otros scripts definen nombres como `trg_users_after_insert` y `trg_users_before_delete`. Si siguen instalados, pueden coexistir y duplicar auditoría o bloqueos: 42 es el inventario de este archivo, no un conteo verificado en servidor. La aplicación de `soft_delete_system.sql` requiere las columnas agregadas y no constituye una migración idempotente.

| Nombre del Trigger | Tabla Afectada | Evento (INSERT/UPDATE/DELETE) | Momento (BEFORE/AFTER) | Lógica/Propósito |
|---|---|---|---|---|
| <a id="trazabilidad"></a>`trg_users_ai` | `tb_users` | INSERT | AFTER | Inserta en tb_logs una operación Create sobre tb_users, con USER() y NEW.ID. No conserva el registro completo. |
| `trg_users_au` | `tb_users` | UPDATE | AFTER | Inserta en tb_logs una operación Update sobre tb_users, con USER() y NEW.ID. No conserva el registro completo. |
| `trg_users_ad` | `tb_users` | DELETE | AFTER | Inserta en tb_logs una operación Delete sobre tb_users, con USER() y OLD.ID. No conserva el registro completo. |
| `trg_products_ai` | `tb_products` | INSERT | AFTER | Inserta en tb_logs una operación Create sobre tb_products, con USER() y NEW.SKU. No conserva el registro completo. |
| `trg_products_au` | `tb_products` | UPDATE | AFTER | Inserta en tb_logs una operación Update sobre tb_products, con USER() y NEW.SKU. No conserva el registro completo. |
| `trg_products_ad` | `tb_products` | DELETE | AFTER | Inserta en tb_logs una operación Delete sobre tb_products, con USER() y OLD.SKU. No conserva el registro completo. |
| `trg_cats_ai` | `tb_categories` | INSERT | AFTER | Inserta en tb_logs una operación Create sobre tb_categories, con USER() y NEW.name. No conserva el registro completo. |
| `trg_cats_au` | `tb_categories` | UPDATE | AFTER | Inserta en tb_logs una operación Update sobre tb_categories, con USER() y NEW.name. No conserva el registro completo. |
| `trg_cats_ad` | `tb_categories` | DELETE | AFTER | Inserta en tb_logs una operación Delete sobre tb_categories, con USER() y OLD.name. No conserva el registro completo. |
| `trg_sorders_ai` | `tb_seller_orders` | INSERT | AFTER | Inserta en tb_logs una operación Create sobre tb_seller_orders, con USER() y NEW.key. No conserva el registro completo. |
| `trg_sorders_au` | `tb_seller_orders` | UPDATE | AFTER | Inserta en tb_logs una operación Update sobre tb_seller_orders, con USER() y NEW.ID. No conserva el registro completo. |
| `trg_sorders_ad` | `tb_seller_orders` | DELETE | AFTER | Inserta en tb_logs una operación Delete sobre tb_seller_orders, con USER() y OLD.key. No conserva el registro completo. |
| <a id="soft-delete"></a>`trg_users_bd` | `tb_users` | DELETE | BEFORE | Bloquea el DELETE físico con SIGNAL SQLSTATE 45000. El borrado lógico debe realizarse mediante el procedimiento correspondiente que actualiza deleted_at. |
| `trg_products_bd` | `tb_products` | DELETE | BEFORE | Bloquea el DELETE físico con SIGNAL SQLSTATE 45000. El borrado lógico debe realizarse mediante el procedimiento correspondiente que actualiza deleted_at. |
| `trg_cats_bd` | `tb_categories` | DELETE | BEFORE | Bloquea el DELETE físico con SIGNAL SQLSTATE 45000. El borrado lógico debe realizarse mediante el procedimiento correspondiente que actualiza deleted_at. |
| <a id="logica-negocio"></a>`trg_users_pass_bi` | `tb_users` | INSERT | BEFORE | Rechaza INSERT cuando LENGTH(NEW.password) < 8; LENGTH mide bytes de la representación almacenada. |
| `trg_users_email_bi` | `tb_users` | INSERT | BEFORE | Rechaza INSERT si email no satisface LIKE '%@%.%'; es una comprobación básica, sin validación completa del correo. |
| `trg_products_price_bi` | `tb_products` | INSERT | BEFORE | Exige current_price > 0 al insertar; el CHECK de la tabla admite cero en UPDATE. |
| `trg_products_stock_bu` | `tb_products` | UPDATE | BEFORE | Rechaza UPDATE con current_stock < 0; el tipo UNSIGNED y el CHECK también restringen el stock. |
| `trg_products_sku_bu` | `tb_products` | UPDATE | BEFORE | Rechaza UPDATE si NEW.SKU <> OLD.SKU; la comparación utiliza la intercalación de la columna. |
| `trg_products_sku_fmt_bi` | `tb_products` | INSERT | BEFORE | Exige que el SKU insertado cumpla LIKE 'SKU-%'. |
| `trg_cats_name_bi` | `tb_categories` | INSERT | BEFORE | Rechaza INSERT si NEW.name = ''; no aplica TRIM ni valida UPDATE. |
| `trg_sorders_diff_bi` | `tb_seller_orders` | INSERT | BEFORE | Rechaza INSERT si seller_ID = buyer_ID; no vuelve a comprobarlo al actualizar. |
| `trg_sorders_cancel_bu` | `tb_seller_orders` | UPDATE | BEFORE | Cuando el estado pasa a cancelled, agrega una entrada Update en tb_logs. No restituye inventario ni cambia partidas o pagos. |
| `trg_oitems_qty_bi` | `tb_order_items` | INSERT | BEFORE | Exige quantity > 0 al insertar una partida; el CHECK también protege las modificaciones. |
| `trg_oitems_price_bi` | `tb_order_items` | INSERT | BEFORE | Exige unit_price >= 0 al insertar; el CHECK también protege las modificaciones. |
| `trg_oitems_stock_bi` | `tb_order_items` | INSERT | BEFORE | Consulta tb_products.current_stock por product_ID y rechaza si quantity supera el stock leído. No valida la correspondencia entre producto y oferta ni bloquea explícitamente la lectura con FOR UPDATE. |
| `trg_oitems_stock_ai` | `tb_order_items` | INSERT | AFTER | Resta NEW.quantity a tb_products.current_stock del producto insertado; esta actualización activa los triggers UPDATE de productos. |
| `trg_oitems_stock_ad` | `tb_order_items` | DELETE | AFTER | Suma OLD.quantity a tb_products.current_stock al borrar explícitamente la partida. No cubre cambios de cantidad por UPDATE. |
| `trg_oitems_order_bu` | `tb_order_items` | UPDATE | BEFORE | Impide cambiar seller_order_ID de una partida mediante UPDATE; permite modificar otros atributos sujetos a sus restricciones. |
| `trg_payments_bu` | `tb_payments` | UPDATE | BEFORE | Rechaza cualquier UPDATE si OLD.payment_status = 'Completed', incluso para cambiar a Refunded o actualizar solo la referencia. |
| `trg_payments_amt_bi` | `tb_payments` | INSERT | BEFORE | Exige amount > 0 en INSERT; no aplica la misma validación al actualizar pagos que aún no están Completed. |
| `trg_payments_status_bi` | `tb_payments` | INSERT | BEFORE | Comprueba en INSERT que payment_status pertenezca a Pending, Completed, Failed o Refunded; coincide con el dominio ENUM. |
| `trg_odetails_qty_bi` | `tbd_order_details` | INSERT | BEFORE | Exige quantity > 0 al insertar detalles del pedido general; no calcula subtotal. |
| `trg_odetails_price_bi` | `tbd_order_details` | INSERT | BEFORE | Exige unit_price >= 0 al insertar detalles del pedido general; no calcula subtotal. |
| `trg_offer_stock_bi` | `tbd_users_offer_products` | INSERT | BEFORE | Rechaza INSERT con available_stock < 0; el tipo UNSIGNED añade una restricción de representación. |
| `trg_offer_date_bi` | `tbd_users_offer_products` | INSERT | BEFORE | Rechaza INSERT si available_date < NOW(); permite igualdad y no valida UPDATE. |
| `trg_cart_dup_bi` | `tbd_shopping_cart` | INSERT | BEFORE | Cuenta filas con el mismo user_ID y product_ID y rechaza INSERT si existe alguna. No hay UNIQUE equivalente ni validación de duplicados por UPDATE. |
| `trg_cart_qty_bi` | `tbd_shopping_cart` | INSERT | BEFORE | Exige quantity > 0 al insertar en el carrito; no valida UPDATE. |
| `trg_orders_total_bi` | `tb_orders` | INSERT | BEFORE | Exige total_cost >= 0 al insertar tb_orders; no verifica que coincida con sus detalles ni valida UPDATE. |
| `trg_pc_delete_bd` | `tb_products_categories` | DELETE | BEFORE | Al borrar una asociación, cuenta productos cuyo category_id = OLD.category_ID y bloquea si existen. No se ejecuta sobre la tabla de categorías ni consulta las asociaciones de la tabla puente. |
| `trg_wishlist_bi` | `tbd_wishlist` | INSERT | BEFORE | Rechaza INSERT si product_ID IS NULL; refuerza el NOT NULL ya declarado en la columna. |

