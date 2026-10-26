-- 1. Crear los roles necesarios
-- 'authenticator': rol de conexión para PostgREST. No debe heredar permisos.
CREATE ROLE authenticator LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER PASSWORD 'auth_pass';
-- 'web_anon': rol para peticiones anónimas (sin token).
CREATE ROLE web_anon NOLOGIN;

-- 2. Permitir que 'authenticator' pueda "cambiar" al rol 'web_anon'
GRANT web_anon TO authenticator;

-- 3. Crear un esquema dedicado para la API (buena práctica)
CREATE SCHEMA IF NOT EXISTS api;

-- 4. Otorgar permisos de uso del esquema 'api' al rol anónimo
GRANT USAGE ON SCHEMA api TO web_anon;

-- 5. Otorgar permisos por defecto a futuras tablas en el esquema 'api'
-- Esto es útil si luego creas más tablas para tu API.
ALTER DEFAULT PRIVILEGES IN SCHEMA api GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO web_anon;

-- 6. (Opcional) Si tus tablas están en el esquema 'public'
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO web_anon;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO web_anon;