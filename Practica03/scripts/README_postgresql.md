# Carga revisable para PostgreSQL 16 y PostgREST

Preparada para la rama Practica03 el 24 de octubre de 2026. Los scripts no se han ejecutado contra la base actual.

## Archivos para revisar

- `create_tables_pg.sql`: traducción de las 16 definiciones físicas del diccionario, ordenadas por dependencias. Crea 15 tablas de forma incondicional y la tabla puente `tb_products_categories` solo si existe el destino original `api.tbc_categories`. Cada CREATE usa IF NOT EXISTS. No contiene carga de filas ni eliminación de objetos.
- `permissions_pg.sql`: roles ausentes, membresía, permisos de tablas/secuencias existentes y permisos futuros para objetos creados por postgres. No cambia contraseñas ni atributos de roles que ya existan. La contraseña de un authenticator nuevo coincide con el Compose actual.
- `../docker-compose.yaml`: único cambio realizado, `PGRST_DB_SCHEMAS: public` → `PGRST_DB_SCHEMAS: api`. Puertos, imágenes, volumen y credenciales permanecen como estaban. `../init.sql` se conserva: un volumen inicializado no vuelve a ejecutarlo al arrancar.

## Decisiones de traducción y pendientes

- ID autoincremental → SERIAL PRIMARY KEY. SERIAL tiene máximo 2147483647, inferior a INT UNSIGNED de MySQL. No importa IDs ni ajusta secuencias existentes.
- Otros INT UNSIGNED → BIGINT con CHECK entre 0 y 4294967295, para conservar el dominio de 32 bits sin signo. Las FK BIGINT pueden referenciar las PK INTEGER generadas por SERIAL.
- DATETIME → TIMESTAMP; BIT(1) → BOOLEAN; ENUM → TEXT con CHECK de valores permitidos. Se conservan nulabilidad, precisión decimal, claves únicas, FK, acciones referenciales y subtotal generado STORED.
- Se retiran ENGINE, COLLATE y actualización temporal automática. last_update conserva su DEFAULT, pero no cambia automáticamente en UPDATE. No se replica la comparación insensible a mayúsculas/acentos de MySQL.
- Se preservan los nombres `ID`, `SKU` y `*_ID` con comillas dobles: SQL directo y clientes deben respetar esas mayúsculas.
- `tbd_address_componentes` y `tbc_categories` siguen sin definición física. No se inventan columnas ni se cambia la FK a otro catálogo. La tabla puente queda pendiente y emite WARNING si falta api.tbc_categories. Al aportar ese DDL se puede volver a ejecutar este archivo.
- `tb_persons` aparece en un script reciente, mientras el procedimiento de registro y el respaldo reciente usan `tb_people`. Ninguna de esas dos tablas pertenece al diccionario oficial; quedan fuera de esta traducción hasta conciliar la variante. Tampoco se agregan tablas de staging del respaldo.
- Los 42 triggers, los triggers adicionales de personas y los procedimientos MySQL no están portados ni instalados por estos archivos. Por tanto, crear las tablas no activa auditoría, bloqueo de borrado físico, validaciones por evento ni actualización de inventario.
- CREATE TABLE IF NOT EXISTS conserva una tabla existente tal cual. No comprueba que coincidan sus columnas o restricciones. Un índice nuevo puede fallar si la estructura previa difiere; ON_ERROR_STOP y la transacción revierten el archivo de tablas en ese caso.
- No mueve ni copia filas de public a api. Al exponer solo api, los recursos de public dejan de estar expuestos por esta configuración de PostgREST, aunque sus datos siguen allí.

## Comandos de aplicación (no ejecutados)

Ejecutar el bloque completo después de revisar los SQL. El subshell se detiene si falla un comando. El respaldo se guarda antes del primer cambio de base; no se usa TTY para conservar el formato binario de pg_dump.

```bash
(
  set -eu
  cd /Users/yait/Practicas_BDN_240545/Practica03

  # Revisar los dos scripts completos antes de aplicarlos.
  cat scripts/create_tables_pg.sql
  cat scripts/permissions_pg.sql

  # Respaldo completo de la base actual con nombre único.
  backup_pg=$(mktemp ./backups/pre_pg_api_XXXXXX)
  docker exec postgres_practica03 \
    pg_dump -U postgres -d practica03_db -Fc > "$backup_pg"
  test -s "$backup_pg"
  printf 'Respaldo: %s\n' "$backup_pg"

  # Inventario previo: permite identificar dónde viven las tablas actuales.
  docker exec postgres_practica03 \
    psql -X -U postgres -d practica03_db -v ON_ERROR_STOP=1 \
    -c "SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema IN ('public', 'api') AND table_type = 'BASE TABLE' ORDER BY 1, 2;"

  # Inyectar los archivos por stdin, sin copiarlos ni ejecutarlos en MySQL.
  docker exec -i postgres_practica03 \
    psql -X -U postgres -d practica03_db -v ON_ERROR_STOP=1 \
    < scripts/create_tables_pg.sql

  docker exec -i postgres_practica03 \
    psql -X -U postgres -d practica03_db -v ON_ERROR_STOP=1 \
    < scripts/permissions_pg.sql

  # Actualizar la variable del servicio API: solo se recrea PostgREST.
  # Un simple restart no incorporaría el cambio de variable del Compose.
  docker compose -f docker-compose.yaml up -d --no-deps --force-recreate postgrest

  # Solicitar la recarga de metadatos al PostgREST ya configurado con api.
  docker exec postgres_practica03 \
    psql -X -U postgres -d practica03_db -v ON_ERROR_STOP=1 \
    -c "NOTIFY pgrst, 'reload schema';"

  # Comprobar la membresía y los permisos efectivos del rol anónimo.
  docker exec postgres_practica03 \
    psql -X -U postgres -d practica03_db -v ON_ERROR_STOP=1 \
    -c "SELECT pg_has_role('authenticator', 'web_anon', 'MEMBER') AS puede_asumir_rol, has_schema_privilege('web_anon', 'api', 'USAGE') AS usa_api, has_table_privilege('web_anon', 'api.tb_users', 'SELECT') AS puede_leer, has_sequence_privilege('web_anon', pg_get_serial_sequence('api.tb_users', 'ID'), 'USAGE') AS puede_generar_id;"

  # Comprobación SQL de lectura usando el mismo rol de las peticiones anónimas.
  docker exec postgres_practica03 \
    psql -X -U postgres -d practica03_db -v ON_ERROR_STOP=1 \
    -c 'SET ROLE web_anon; SELECT "ID" FROM api.tb_users LIMIT 0; RESET ROLE;'

  # Esperar disponibilidad y comprobar una consulta REST sin mostrar credenciales.
  curl --fail --silent --show-error --retry 10 --retry-delay 2 --retry-all-errors \
    'http://localhost:3000/tb_categories?select=ID,name&limit=1'
)
```

La validación REST puede devolver `[]` si las tablas nuevas están vacías. Si falla autenticación, revisar las credenciales del rol existente: el script no sobrescribe contraseñas previas. Si falla por estructura preexistente, detenerse y preparar una migración específica; no eliminar las tablas para forzar la carga.

Referencias: [CREATE TABLE PostgreSQL 16](https://www.postgresql.org/docs/16/sql-createtable.html), [privilegios PostgreSQL 16](https://www.postgresql.org/docs/16/ddl-priv.html), [recarga de PostgREST 12](https://docs.postgrest.org/en/v12/references/schema_cache.html).
