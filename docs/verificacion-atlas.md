# Verificación del Atlas

Estructura: `Practica03/ecosistema_v2/02_mysql.sql`. Filas: `Practica03/backups/respaldo_final_240545.sql` (2026-10-21 18:09:58).

El respaldo contiene 18 tablas de una versión anterior. Las filas no acreditan un conteo del esquema actual. Sin snapshot no significa cero. Las credenciales están ocultas.

| Tabla | Campos Atlas | Filas respaldo | PK | FK | Ejemplo del respaldo |
|---|---:|---:|---:|---:|---|
| tb_users | 7 | 4 | 1 | 0 | Marco Admin |
| tb_products | 9 | 10505 | 1 | 0 | Laptop Lenovo |
| tb_orders | 8 | 0 | 1 | 2 | — |
| tb_payments | 8 | 0 | 1 | 2 | — |
| tb_people | 9 | 1 | 1 | 2 | Emigdio |
| tb_roles | 3 | Sin snapshot | 1 | 0 | — |
| tb_user_roles | 4 | Sin snapshot | 1 | 2 | — |
| tb_permissions | 4 | Sin snapshot | 1 | 0 | — |
| tb_role_permissions | 4 | Sin snapshot | 1 | 2 | — |
| tb_categories | 6 | 3 | 1 | 0 | Electrónica |
| tb_product_categories | 4 | Sin snapshot | 1 | 2 | — |
| tb_tags | 3 | Sin snapshot | 1 | 0 | — |
| tb_product_tags | 4 | Sin snapshot | 1 | 2 | — |
| tb_reviews | 8 | Sin snapshot | 1 | 2 | — |
| tbc_countries | 4 | Sin snapshot | 1 | 0 | — |
| tbc_states | 4 | Sin snapshot | 1 | 1 | — |
| tb_addresses | 10 | Sin snapshot | 1 | 3 | — |
| tb_carts | 6 | 0 | 1 | 1 | — |
| tbd_shopping_cart | 6 | 0 | 1 | 3 | — |
| tb_order_items | 8 | 0 | 1 | 2 | — |
| tb_wishlists | 6 | Sin snapshot | 1 | 2 | — |
| tbc_payment_methods | 4 | 3 | 1 | 0 | Tarjeta de Crédito |
| tb_carriers | 3 | Sin snapshot | 1 | 0 | — |
| tb_shipments | 9 | Sin snapshot | 1 | 3 | — |
| tb_invoices | 7 | Sin snapshot | 1 | 1 | — |
| tb_logs | 8 | 10515 | 1 | 0 | 1 |

| Categoría | Productos del respaldo |
|---|---:|
| Electrónica | 169 |
| Ropa | 168 |
| Hogar | 167 |
| Sin categoría asignada | 10001 |
| **Total** | **10505** |

No coincide con la referencia solicitada de 5.000 productos: hay 5.505 productos adicionales y 10.001 sin categoría. La referencia de 10.222 usuarios tampoco coincide con los 4 usuarios del respaldo.
