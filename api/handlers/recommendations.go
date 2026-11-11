package handlers

import "net/http"

func (a API) Recommendations(w http.ResponseWriter, r *http.Request) {
	// TODO: autenticar; limitar y validar el JSON antes de procesarlo.
	// TODO: aquí va Mem0
	// TODO: aquí va Meilisearch/Qdrant
	// TODO: confirmar disponibilidad y precios en MySQL.
	respond(w, http.StatusNotImplemented, "Recomendaciones pendientes de implementar")
}
