package handlers

import (
	"net/http"
	"strconv"
)

func validProductID(w http.ResponseWriter, r *http.Request) bool {
	id, err := strconv.ParseUint(r.PathValue("id"), 10, 32)
	if err != nil || id == 0 {
		respond(w, http.StatusBadRequest, "El ID debe ser un entero positivo de 32 bits")
		return false
	}
	return true
}

func (a API) Product(w http.ResponseWriter, r *http.Request) {
	if !validProductID(w, r) {
		return
	}
	// TODO: SELECT parametrizado de tb_products WHERE ID = ?; precio/stock desde SQL.
	respond(w, http.StatusNotImplemented, "Detalle de producto pendiente de implementar")
}

func (a API) SimilarProducts(w http.ResponseWriter, r *http.Request) {
	if !validProductID(w, r) {
		return
	}
	// TODO: aquí va Meilisearch/Qdrant
	respond(w, http.StatusNotImplemented, "Productos similares pendientes de implementar")
}
