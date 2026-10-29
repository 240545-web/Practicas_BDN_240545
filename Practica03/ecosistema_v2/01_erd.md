# Fase 1 — ERD de 26 tablas

Los nombres físicos conservan los prefijos del procedimiento. Las asociaciones N:M se representan con tablas puente; people y invoices tienen FK UNIQUE. Las FK compuestas garantizan país/estado y propietario de carrito/pedido.

```mermaid
erDiagram
    %% Seguridad
    tb_users {
        BIGINT id PK
        VARCHAR(254) email
        VARCHAR(100) nickname
        VARCHAR(255) password
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_roles {
        BIGINT id PK
        VARCHAR(80) name
        TIMESTAMP created_at
    }
    tb_user_roles {
        BIGINT id PK
        BIGINT user_id FK
        BIGINT role_id FK
        TIMESTAMP created_at
    }
    tb_permissions {
        BIGINT id PK
        VARCHAR(100) code
        TEXT description
        TIMESTAMP created_at
    }
    tb_role_permissions {
        BIGINT id PK
        BIGINT role_id FK
        BIGINT permission_id FK
        TIMESTAMP created_at
    }
    tb_logs {
        BIGINT id PK
        VARCHAR(100) table_name
        BIGINT entity_id
        VARCHAR(10) operation
        VARCHAR(288) db_actor
        JSON old_data
        JSON new_data
        TIMESTAMP created_at
    }
    %% Catálogo
    tb_products {
        BIGINT id PK
        VARCHAR(50) SKU
        VARCHAR(250) name
        TEXT description
        DECIMAL(12,2) current_price
        INT current_stock
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_categories {
        BIGINT id PK
        VARCHAR(150) name
        TEXT description
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_product_categories {
        BIGINT id PK
        BIGINT product_id FK
        BIGINT category_id FK
        TIMESTAMP created_at
    }
    tb_tags {
        BIGINT id PK
        VARCHAR(80) name
        TIMESTAMP created_at
    }
    tb_product_tags {
        BIGINT id PK
        BIGINT product_id FK
        BIGINT tag_id FK
        TIMESTAMP created_at
    }
    tb_reviews {
        BIGINT id PK
        BIGINT user_id FK
        BIGINT product_id FK
        INT rating
        TEXT comment
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    %% Clientes y ubicación
    tb_people {
        BIGINT id PK
        BIGINT user_id FK
        VARCHAR(150) given_names
        VARCHAR(150) family_names
        DATE birth_date
        CHAR(2) country_code FK
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_addresses {
        BIGINT id PK
        BIGINT user_id FK
        CHAR(2) country_code FK
        BIGINT state_id FK
        VARCHAR(120) city
        VARCHAR(250) street
        VARCHAR(20) postal_code
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tbc_countries {
        BIGINT id PK
        CHAR(2) code
        VARCHAR(100) name
        TIMESTAMP created_at
    }
    tbc_states {
        BIGINT id PK
        CHAR(2) country_code FK
        VARCHAR(100) name
        TIMESTAMP created_at
    }
    %% Compras
    tb_carts {
        BIGINT id PK
        BIGINT user_id FK
        VARCHAR(20) status
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tbd_shopping_cart {
        BIGINT id PK
        BIGINT cart_id FK
        BIGINT user_id FK
        BIGINT product_id FK
        INT quantity
        TIMESTAMP created_at
    }
    tb_orders {
        BIGINT id PK
        BIGINT user_id FK
        BIGINT cart_id FK
        VARCHAR(20) status
        DECIMAL(12,2) total_amount
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_order_items {
        BIGINT id PK
        BIGINT order_id FK
        BIGINT product_id FK
        VARCHAR(250) product_name
        INT quantity
        DECIMAL(12,2) unit_price
        DECIMAL(12,2) subtotal
        TIMESTAMP created_at
    }
    tb_wishlists {
        BIGINT id PK
        BIGINT user_id FK
        BIGINT product_id FK
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    %% Pagos y envíos
    tb_payments {
        BIGINT id PK
        BIGINT order_id FK
        BIGINT payment_method_id FK
        DECIMAL(12,2) amount
        VARCHAR(20) payment_status
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tbc_payment_methods {
        BIGINT id PK
        VARCHAR(40) code
        VARCHAR(100) name
        TIMESTAMP created_at
    }
    tb_shipments {
        BIGINT id PK
        BIGINT order_id FK
        BIGINT carrier_id FK
        BIGINT address_id FK
        VARCHAR(150) tracking_code
        VARCHAR(20) status
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_carriers {
        BIGINT id PK
        VARCHAR(150) name
        TIMESTAMP created_at
    }
    tb_invoices {
        BIGINT id PK
        BIGINT order_id FK
        VARCHAR(80) invoice_number
        DECIMAL(12,2) total_amount
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }
    tb_users ||--o{ tb_user_roles : "user_id"
    tb_roles ||--o{ tb_user_roles : "role_id"
    tb_roles ||--o{ tb_role_permissions : "role_id"
    tb_permissions ||--o{ tb_role_permissions : "permission_id"
    tb_products ||--o{ tb_product_categories : "product_id"
    tb_categories ||--o{ tb_product_categories : "category_id"
    tb_products ||--o{ tb_product_tags : "product_id"
    tb_tags ||--o{ tb_product_tags : "tag_id"
    tb_users ||--o{ tb_reviews : "user_id"
    tb_products ||--o{ tb_reviews : "product_id"
    tbc_countries ||--o{ tbc_states : "country_code"
    tb_users ||--o| tb_people : "user_id"
    tbc_countries ||--o{ tb_people : "country_code"
    tb_users ||--o{ tb_addresses : "user_id"
    tbc_countries ||--o{ tb_addresses : "country_code"
    tbc_states |o--o{ tb_addresses : "state_id, country_code"
    tb_users ||--o{ tb_carts : "user_id"
    tb_carts ||--o{ tbd_shopping_cart : "cart_id, user_id"
    tb_users ||--o{ tbd_shopping_cart : "user_id"
    tb_products ||--o{ tbd_shopping_cart : "product_id"
    tb_users ||--o{ tb_orders : "user_id"
    tb_carts |o--o| tb_orders : "cart_id, user_id"
    tb_orders ||--o{ tb_order_items : "order_id"
    tb_products ||--o{ tb_order_items : "product_id"
    tb_users ||--o{ tb_wishlists : "user_id"
    tb_products ||--o{ tb_wishlists : "product_id"
    tb_orders ||--o{ tb_payments : "order_id"
    tbc_payment_methods ||--o{ tb_payments : "payment_method_id"
    tb_orders ||--o{ tb_shipments : "order_id"
    tb_carriers ||--o{ tb_shipments : "carrier_id"
    tb_addresses ||--o{ tb_shipments : "address_id"
    tb_orders ||--o| tb_invoices : "order_id"
```
