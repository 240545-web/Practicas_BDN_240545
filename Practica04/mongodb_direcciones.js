// Base en Mongo: bd_comercio_electronico_matricula
// Se usa con: mongosh < mongodb_direcciones.js
// O dentro de mongosh: use("bd_comercio_electronico_matricula")

/* ============================================================
   PRÁCTICA 04 - DIRECCIONES DE CLIENTES EN MONGODB
   Alumno: Emigdio Aguirre - 240545
   Base existente: bd_comercio_electronico_matricula
   ------------------------------------------------------------
   SIN Mongo Compass: se ejecuta en mongosh / mongo shell.

   DIFERENCIA CON MySQL:
   - En MySQL el domicilio es un ÁRBOL JERÁRQUICO en
     tbd_address_componentes: cada nivel es una fila y
     address_sup_ID apunta al padre (País -> Estado -> ... ->
     Número Interior). Sirve para normalizar y reutilizar
     componentes, pero una consulta completa requiere recorrer
     10 niveles.
   - En MongoDB el domicilio es UN SOLO STRING desnormalizado
     dentro de direcciones_clientes, con los componentes en
     orden jerárquico separados por coma. Se escribe una vez y
     se lee completo con una consulta; el costo es que un cambio
     de componente (por ejemplo, renombrar una colonia) exige
     actualizar todos los documentos que lo contienen.

   EJEMPLO DE CONSULTA RÁPIDA:
   db.direcciones_clientes.findOne({cliente_id: 1001})
   ============================================================ */

/* ------------------------------------------------------------
   1. TRES DOCUMENTOS DE EJEMPLO (datos inventados)
   ------------------------------------------------------------ */
db.direcciones_clientes.insertMany([
    {
        _id: 1,
        cliente_id: 1001,
        direccion: "México, Jalisco, Zapopan, Zapopan, Ladera Norte, 45110, Real del Valle, Av. Patria, 120, 5B"
    },
    {
        _id: 2,
        cliente_id: 1002,
        direccion: "México, Nuevo León, Monterrey, Monterrey, Centro, 64000, Del Valle, Av. Gómez Morín, 250, 804"
    },
    {
        _id: 3,
        cliente_id: 1003,
        direccion: "México, Jalisco, Guadalajara, Guadalajara, Chapalita, 44500, Casa Papas, Av. Niño Obrero, 77, 12"
    }
]);

/* ------------------------------------------------------------
   2. CONSULTA POR CLIENTE (equivalente a JOIN de 10 niveles)
   ------------------------------------------------------------ */
db.direcciones_clientes.findOne({ cliente_id: 1001 });

/* ------------------------------------------------------------
   3. CONSULTA POR CÓDIGO POSTAL CON REGEX
   ------------------------------------------------------------ */
db.direcciones_clientes.find({
    direccion: { $regex: "45110" }
});
