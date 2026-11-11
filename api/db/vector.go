package db

// VectorConfig reserva la configuración para adaptadores futuros.
// TODO: usar product_ID = tb_products.ID para sincronizar documentos/vectores.
// TODO: aquí va Meilisearch/Qdrant; no se crean índices ni clientes todavía.
type VectorConfig struct {
	MeilisearchURL string
	QdrantURL      string
}
