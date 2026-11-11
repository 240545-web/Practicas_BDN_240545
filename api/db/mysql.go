package db

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/go-sql-driver/mysql"
)

// OpenMySQL configura el pool. sql.Open no abre conexiones ni ejecuta SQL;
// la conexión física se abrirá cuando se implementen las consultas.
// Un DSN vacío permite revisar el esqueleto sin acceso a una base.
func OpenMySQL(dsn string) (*sql.DB, error) {
	if dsn == "" {
		return nil, nil
	}
	cfg, err := mysql.ParseDSN(dsn)
	if err != nil {
		return nil, fmt.Errorf("DSN inválido")
	}
	if cfg.TLSConfig != "true" {
		return nil, fmt.Errorf("MySQL nube requiere TLS verificado: tls=true")
	}
	cfg.Timeout = 5 * time.Second
	cfg.ReadTimeout = 5 * time.Second
	cfg.WriteTimeout = 5 * time.Second
	connection, err := sql.Open("mysql", cfg.FormatDSN())
	if err != nil {
		return nil, fmt.Errorf("no se pudo configurar el pool MySQL")
	}
	connection.SetMaxOpenConns(10)
	connection.SetMaxIdleConns(5)
	connection.SetConnMaxLifetime(3 * time.Minute)
	return connection, nil
}
