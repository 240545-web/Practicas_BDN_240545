-- PostgreSQL 16 | db_test (modelo) en practica03_db (base de Docker).
-- Fuentes: diccionario_datos.md y sus DDL originales. No importa datos.
-- Se conserva la grafía de ID, SKU y *_ID usando identificadores entre comillas.
-- CREATE TABLE IF NOT EXISTS no migra/repara una tabla previamente existente.
-- Sin reemplazos de tablas, sin cambios de secuencias existentes, sin DML.
-- No instala los 42 triggers/procedimientos MySQL ni emula last_update automático.
-- SERIAL utiliza INTEGER con signo (máximo 2147483647), como se solicitó.
-- Los demás INT UNSIGNED se traducen a BIGINT CHECK >= 0 para conservar su rango.
-- No replica la comparación insensible a mayúsculas/acentos de MySQL.
-- tbd_address_componentes carece de DDL: no se inventa su estructura.
BEGIN;
SET LOCAL lock_timeout = '5s';
CREATE SCHEMA IF NOT EXISTS api;

CREATE TABLE IF NOT EXISTS api.tb_categories (
    "ID" SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_tb_categories_name UNIQUE (name),
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    CHECK ("ID" >= 0 AND "ID" <= 4294967295)
);
CREATE INDEX IF NOT EXISTS idx_categories_deleted_at ON api.tb_categories (deleted_at);

CREATE TABLE IF NOT EXISTS api.tb_logs (
    "ID" SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    operation TEXT CHECK (operation IN ('Create','Read','Update','Delete')) NOT NULL,
    db_user VARCHAR(80) NOT NULL,
    description TEXT NOT NULL,
    operation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    operation_status BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS api.tb_users (
    "ID" SERIAL PRIMARY KEY,
    email VARCHAR(80) NOT NULL,
    nickname VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMP NULL DEFAULT NULL,
    last_login TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT uk_tb_users_email UNIQUE (email),
    CONSTRAINT uk_tb_users_nickname UNIQUE (nickname),
    deleted_at TIMESTAMP NULL DEFAULT NULL
);
CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON api.tb_users (deleted_at);

CREATE TABLE IF NOT EXISTS api.tb_products (
    "ID" SERIAL PRIMARY KEY,
    "SKU" VARCHAR(50) NOT NULL,
    name VARCHAR(250) NOT NULL,
    description TEXT NULL,
    category_id BIGINT NULL,
    current_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    current_stock BIGINT NOT NULL DEFAULT 0,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_tb_products_sku UNIQUE ("SKU"),
    CONSTRAINT fk_tb_products_categories
        FOREIGN KEY (category_id)
        REFERENCES api.tb_categories ("ID")
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_price CHECK (current_price >= 0),
    CONSTRAINT chk_stock CHECK (current_stock >= 0),
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    CHECK ("ID" >= 0 AND "ID" <= 4294967295),
    CHECK (category_id >= 0 AND category_id <= 4294967295),
    CHECK (current_stock >= 0 AND current_stock <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_tb_products_categories ON api.tb_products (category_id);
CREATE INDEX IF NOT EXISTS idx_products_deleted_at ON api.tb_products (deleted_at);

CREATE TABLE IF NOT EXISTS api.tb_orders (
    "ID" SERIAL PRIMARY KEY,
    "key" VARCHAR(40) NOT NULL,
    "user_ID" INT NOT NULL,
    total_products BIGINT NOT NULL DEFAULT 0,
    total_cost DECIMAL(10,3) NOT NULL DEFAULT 0.000,
    status_string VARCHAR(50) NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_orders_key UNIQUE ("key"),
    CONSTRAINT fk_orders_user
        FOREIGN KEY ("user_ID") REFERENCES api.tb_users ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK ("ID" >= 0 AND "ID" <= 4294967295),
    CHECK (total_products >= 0 AND total_products <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_orders_user ON api.tb_orders ("user_ID");

CREATE TABLE IF NOT EXISTS api.tb_carts (
    "ID" SERIAL PRIMARY KEY,
    "user_ID" INT NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_carts_user
        FOREIGN KEY ("user_ID") REFERENCES api.tb_users ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK ("ID" >= 0 AND "ID" <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_carts_user ON api.tb_carts ("user_ID");

CREATE TABLE IF NOT EXISTS api.tbc_payment_methods (
    "ID" SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_payment_methods_name UNIQUE (name),
    CHECK ("ID" >= 0 AND "ID" <= 4294967295)
);

CREATE TABLE IF NOT EXISTS api.tb_payments (
    "ID" SERIAL PRIMARY KEY,
    "order_ID" BIGINT NOT NULL,
    "payment_method_ID" BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    payment_status TEXT CHECK (payment_status IN ('Pending','Completed','Failed','Refunded')) NOT NULL DEFAULT 'Pending',
    transaction_reference VARCHAR(150) NULL,
    payment_date TIMESTAMP NULL,
    CONSTRAINT fk_payments_order
        FOREIGN KEY ("order_ID") REFERENCES api.tb_orders ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payments_method
        FOREIGN KEY ("payment_method_ID") REFERENCES api.tbc_payment_methods ("ID")
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK ("ID" >= 0 AND "ID" <= 4294967295),
    CHECK ("order_ID" >= 0 AND "order_ID" <= 4294967295),
    CHECK ("payment_method_ID" >= 0 AND "payment_method_ID" <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_payments_order ON api.tb_payments ("order_ID");
CREATE INDEX IF NOT EXISTS fk_payments_method ON api.tb_payments ("payment_method_ID");

CREATE TABLE IF NOT EXISTS api.tbd_order_details (
    "ID" SERIAL PRIMARY KEY,
    "order_ID" BIGINT NOT NULL,
    "product_ID" BIGINT NOT NULL,
    quantity BIGINT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_details_order
        FOREIGN KEY ("order_ID") REFERENCES api.tb_orders ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_order_details_product
        FOREIGN KEY ("product_ID") REFERENCES api.tb_products ("ID")
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK ("ID" >= 0 AND "ID" <= 4294967295),
    CHECK ("order_ID" >= 0 AND "order_ID" <= 4294967295),
    CHECK ("product_ID" >= 0 AND "product_ID" <= 4294967295),
    CHECK (quantity >= 0 AND quantity <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_order_details_order ON api.tbd_order_details ("order_ID");
CREATE INDEX IF NOT EXISTS fk_order_details_product ON api.tbd_order_details ("product_ID");

CREATE TABLE IF NOT EXISTS api.tbd_shopping_cart (
    "ID" SERIAL PRIMARY KEY,
    "user_ID" INT NOT NULL,
    "offer_ID" BIGINT NULL,
    "product_ID" BIGINT NOT NULL,
    quantity BIGINT NOT NULL DEFAULT 1,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_shopping_cart_user
        FOREIGN KEY ("user_ID") REFERENCES api.tb_users ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_shopping_cart_product
        FOREIGN KEY ("product_ID") REFERENCES api.tb_products ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK ("ID" >= 0 AND "ID" <= 4294967295),
    CHECK ("offer_ID" >= 0 AND "offer_ID" <= 4294967295),
    CHECK ("product_ID" >= 0 AND "product_ID" <= 4294967295),
    CHECK (quantity >= 0 AND quantity <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_shopping_cart_user ON api.tbd_shopping_cart ("user_ID");
CREATE INDEX IF NOT EXISTS fk_shopping_cart_product ON api.tbd_shopping_cart ("product_ID");

CREATE TABLE IF NOT EXISTS api.tbd_users_offer_products (
    "ID" SERIAL PRIMARY KEY,
    "user_ID" INT NOT NULL,
    "product_ID" BIGINT NOT NULL,
    available_stock BIGINT NOT NULL DEFAULT 0,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    available_date TIMESTAMP NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_offer_user
        FOREIGN KEY ("user_ID") REFERENCES api.tb_users ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_offer_product
        FOREIGN KEY ("product_ID") REFERENCES api.tb_products ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK ("ID" >= 0 AND "ID" <= 4294967295),
    CHECK ("product_ID" >= 0 AND "product_ID" <= 4294967295),
    CHECK (available_stock >= 0 AND available_stock <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_offer_user ON api.tbd_users_offer_products ("user_ID");
CREATE INDEX IF NOT EXISTS fk_offer_product ON api.tbd_users_offer_products ("product_ID");

CREATE TABLE IF NOT EXISTS api.tb_seller_orders (
    "ID" SERIAL PRIMARY KEY,
    "key" VARCHAR(40) NOT NULL,
    "seller_ID" INT NOT NULL,
    "buyer_ID" INT NOT NULL,
    status_string VARCHAR(50) NOT NULL DEFAULT 'pending',
    status BOOLEAN NOT NULL DEFAULT TRUE,
    total_items BIGINT NOT NULL DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_seller_orders_key UNIQUE ("key"),
    CONSTRAINT fk_seller_orders_seller
        FOREIGN KEY ("seller_ID") REFERENCES api.tb_users ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_seller_orders_buyer
        FOREIGN KEY ("buyer_ID") REFERENCES api.tb_users ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK ("ID" >= 0 AND "ID" <= 4294967295),
    CHECK (total_items >= 0 AND total_items <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_seller_orders_seller ON api.tb_seller_orders ("seller_ID");
CREATE INDEX IF NOT EXISTS fk_seller_orders_buyer ON api.tb_seller_orders ("buyer_ID");

CREATE TABLE IF NOT EXISTS api.tb_order_items (
    "ID" SERIAL PRIMARY KEY,
    "seller_order_ID" BIGINT NOT NULL,
    "product_ID" BIGINT NOT NULL,
    "provider_ID" BIGINT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity BIGINT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_items_order
        FOREIGN KEY ("seller_order_ID") REFERENCES api.tb_seller_orders ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_order_items_product
        FOREIGN KEY ("product_ID") REFERENCES api.tb_products ("ID")
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_items_provider
        FOREIGN KEY ("provider_ID") REFERENCES api.tbd_users_offer_products ("ID")
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0),
    CHECK ("ID" >= 0 AND "ID" <= 4294967295),
    CHECK ("seller_order_ID" >= 0 AND "seller_order_ID" <= 4294967295),
    CHECK ("product_ID" >= 0 AND "product_ID" <= 4294967295),
    CHECK ("provider_ID" >= 0 AND "provider_ID" <= 4294967295),
    CHECK (quantity >= 0 AND quantity <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_order_items_order ON api.tb_order_items ("seller_order_ID");
CREATE INDEX IF NOT EXISTS fk_order_items_product ON api.tb_order_items ("product_ID");
CREATE INDEX IF NOT EXISTS fk_order_items_provider ON api.tb_order_items ("provider_ID");

CREATE TABLE IF NOT EXISTS api.tbd_wishlist (
    "ID" SERIAL PRIMARY KEY,
    "user_ID" INT NOT NULL,
    "product_ID" BIGINT NOT NULL,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_wishlist_user_product UNIQUE ("user_ID", "product_ID"),
    CONSTRAINT fk_wishlist_user
        FOREIGN KEY ("user_ID") REFERENCES api.tb_users ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_wishlist_product
        FOREIGN KEY ("product_ID") REFERENCES api.tb_products ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK ("ID" >= 0 AND "ID" <= 4294967295),
    CHECK ("product_ID" >= 0 AND "product_ID" <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_wishlist_product ON api.tbd_wishlist ("product_ID");

CREATE TABLE IF NOT EXISTS api.tbd_users_wishlist_products (
    "user_ID" INT NOT NULL,
    "product_ID" BIGINT NOT NULL,
    status BOOLEAN NOT NULL DEFAULT TRUE,
    creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("user_ID", "product_ID"),
    CONSTRAINT fk_uwp_user
        FOREIGN KEY ("user_ID") REFERENCES api.tb_users ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_uwp_product
        FOREIGN KEY ("product_ID") REFERENCES api.tb_products ("ID")
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK ("product_ID" >= 0 AND "product_ID" <= 4294967295)
);
CREATE INDEX IF NOT EXISTS fk_uwp_product ON api.tbd_users_wishlist_products ("product_ID");

-- FK original no resuelta: no sustituir tbc_categories por tb_categories.
-- Solo se crea la tabla puente si el destino literal ya existe en api.
DO $pending_category$
BEGIN
    IF to_regclass('api.tbc_categories') IS NOT NULL THEN
        CREATE TABLE IF NOT EXISTS api.tb_products_categories (
            "category_ID" BIGINT NOT NULL,
            "product_ID" BIGINT NOT NULL,
            status BOOLEAN NOT NULL DEFAULT TRUE,
            creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY ("category_ID", "product_ID"),
            CONSTRAINT fk_pc_category
                FOREIGN KEY ("category_ID") REFERENCES api.tbc_categories ("ID")
                ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT fk_pc_product
                FOREIGN KEY ("product_ID") REFERENCES api.tb_products ("ID")
                ON DELETE CASCADE ON UPDATE CASCADE,
            CHECK ("category_ID" >= 0 AND "category_ID" <= 4294967295),
            CHECK ("product_ID" >= 0 AND "product_ID" <= 4294967295)
        );
        CREATE INDEX IF NOT EXISTS fk_pc_product ON api.tb_products_categories ("product_ID");
    ELSE
        RAISE WARNING 'Pendiente: api.tb_products_categories requiere el DDL de api.tbc_categories; no se crea ni altera la tabla puente.';
    END IF;
END;
$pending_category$;

COMMIT;
