-- Auditoría de destinos FK ausentes, 20 de noviembre de 2026.
-- Tres nombres lógicos y cuatro destinos por motor/esquema:
-- MySQL db_test: tbc_categories, tb_carriers y tb_addresses.
-- PostgreSQL api: tbc_categories (variante opcional al final).
-- Los 26 CREATE TABLE de db_test_ecosystem resuelven todas sus FKs.
-- No ejecutar contra db_test_ecosystem: estos faltantes son del modelo histórico db_test.
-- DDL mínimo NUEVO: solo ID está demostrado por las FK de origen.
-- Tipo y signo se toman de la columna hija. NOT NULL y PRIMARY KEY son
-- decisiones explícitas de esta reparación para ofrecer una clave referenciable;
-- no se presentan como una estructura histórica recuperada.
-- No se deducen nombre, dirección, país, timestamps ni AUTO_INCREMENT.
-- No carga datos ni modifica tablas, procedimientos o triggers existentes.

-- Tabla faltante detectada en auditoría, referenciada en Practica03/backups/respaldo_final_240545.sql:816 y Practica03/scripts/create_tables.sql:152 como FK, no tenía CREATE TABLE
CREATE TABLE IF NOT EXISTS db_test.tbc_categories (
    ID INT UNSIGNED NOT NULL,
    PRIMARY KEY (ID)
) ENGINE=InnoDB;

-- Tabla faltante detectada en auditoría, referenciada en Practica03/scripts/Tablas_mas.sql:25 como FK, no tenía CREATE TABLE
CREATE TABLE IF NOT EXISTS db_test.tb_carriers (
    ID BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (ID)
) ENGINE=InnoDB;

-- Tabla faltante detectada en auditoría, referenciada en Practica03/scripts/Tablas_mas.sql:26 como FK, no tenía CREATE TABLE
CREATE TABLE IF NOT EXISTS db_test.tb_addresses (
    ID BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (ID)
) ENGINE=InnoDB;

/* VARIANTE POSTGRESQL, NO EJECUTAR CON EL CLIENTE MYSQL.
   Este bloque se conserva comentado para no mezclar dialectos ejecutables.
   Ejecutar por separado en PostgreSQL, donde el esquema api ya exista.
   El rango se toma de la columna hija de create_tables_pg.sql:303,315.
   Crear el padre no ejecuta retroactivamente el DO condicional que crea la tabla puente.

-- Tabla faltante detectada en auditoría, referenciada en Practica03/scripts/create_tables_pg.sql:310 como FK, no tenía CREATE TABLE
CREATE TABLE IF NOT EXISTS api.tbc_categories (
    "ID" BIGINT NOT NULL,
    PRIMARY KEY ("ID"),
    CHECK ("ID" >= 0 AND "ID" <= 4294967295)
);
*/
