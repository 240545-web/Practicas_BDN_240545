package db

// UserMemory es el contrato propuesto de users_memory; no persiste datos todavía.
// UserID deberá proceder de la identidad autenticada, no del cuerpo del cliente.
type UserMemory struct {
	UserID            string    `json:"user_ID"`
	Searches          []string  `json:"busquedas"`
	ViewedProducts    []uint64  `json:"productos_vistos"`
	PurchasedProducts []uint64  `json:"productos_comprados"`
	Embedding         []float32 `json:"embedding"`
	Preferences       []string  `json:"gustos"`
}

// TODO: aquí va Mem0, mediante HTTP interno, con Qdrant como almacenamiento.
// TODO: generar embeddings con Gemini API u Ollama desde Go.
