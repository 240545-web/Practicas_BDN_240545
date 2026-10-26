-- Ejecutar como postgres en practica03_db después de create_tables_pg.sql.
-- Reutiliza roles existentes sin restablecer sus contraseñas o atributos.
BEGIN;
SET LOCAL lock_timeout = '5s';
DO $roles$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticator') THEN
        CREATE ROLE authenticator LOGIN NOINHERIT NOCREATEDB NOCREATEROLE
            NOSUPERUSER NOREPLICATION NOBYPASSRLS PASSWORD 'auth_pass';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'web_anon') THEN
        CREATE ROLE web_anon NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE
            NOREPLICATION NOBYPASSRLS;
    END IF;
END;
$roles$;

GRANT CONNECT ON DATABASE practica03_db TO authenticator;
GRANT web_anon TO authenticator;
GRANT USAGE ON SCHEMA api TO web_anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA api TO web_anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA api TO web_anon;

-- Aplican a objetos futuros creados por postgres, el rol usado en la carga.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA api
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO web_anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA api
    GRANT USAGE, SELECT ON SEQUENCES TO web_anon;
COMMIT;
