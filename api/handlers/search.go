package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strings"
)

type API struct{ SQL *sql.DB }

func respond(w http.ResponseWriter, status int, message string) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(map[string]string{"message": message})
}

func (a API) Search(w http.ResponseWriter, r *http.Request) {
	if strings.TrimSpace(r.URL.Query().Get("q")) == "" {
		respond(w, http.StatusBadRequest, "El parámetro q es obligatorio")
		return
	}
	// TODO: aquí va FULLTEXT
	// TODO: aquí va Meilisearch/Qdrant
	// TODO: aquí va Mem0 (solo con identidad y consentimiento)
	respond(w, http.StatusNotImplemented, "Búsqueda híbrida pendiente de implementar")
}
