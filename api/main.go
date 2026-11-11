package main

import (
	"log"
	"net/http"
	"os"
	"time"

	"practicas-bdn-240545/api/db"
	"practicas-bdn-240545/api/handlers"
)

func main() {
	connection, err := db.OpenMySQL(os.Getenv("MYSQL_DSN"))
	if err != nil {
		log.Fatal("No se pudo configurar MySQL; revisa MYSQL_DSN y TLS")
	}
	if connection != nil {
		defer connection.Close()
	} else {
		log.Print("MYSQL_DSN vacío: esqueleto sin conexión a MySQL")
	}
	h := handlers.API{SQL: connection}
	mux := http.NewServeMux()
	// TODO: aquí va FULLTEXT
	// TODO: aquí va Meilisearch/Qdrant
	mux.HandleFunc("GET /api/search", h.Search)
	// TODO: consultar el producto por ID en MySQL
	mux.HandleFunc("GET /api/products/{id}", h.Product)
	// TODO: aquí va Meilisearch/Qdrant
	mux.HandleFunc("GET /api/products/{id}/similares", h.SimilarProducts)
	// TODO: aquí va Mem0
	mux.HandleFunc("POST /api/recomendaciones", h.Recommendations)
	server := &http.Server{
		Addr: ":8080", Handler: mux,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second, WriteTimeout: 15 * time.Second,
		IdleTimeout: 60 * time.Second,
	}
	log.Print("API Practicas_BDN_240545 en http://localhost:8080")
	log.Fatal(server.ListenAndServe())
}
