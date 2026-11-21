# Práctica 04 · Domicilio en MySQL (jerárquico) y MongoDB (desnormalizado)

Alumno: Emigdio Aguirre · Matrícula: 240545
Base existente: `db_test` / `bd_comercio_electronico_matricula` (no se crea ninguna base nueva).

## Diccionario publicado

[Abrir el diccionario de Práctica 04 en GitHub Pages](https://240545-web.github.io/Practicas_BDN_240545/Practica04/diccionario_datos.html).

Archivo local: [`diccionario_datos.html`](diccionario_datos.html). Modelo base: 19 tablas, 144 columnas y 23 FKs; Atlas: 26 + 3 de auditoría = 29. Contiene 15,000 productos en seeds y 0 campos inventados. Pages publica desde la rama `Practica04`.

## Archivos

| Archivo | Contenido |
|---|---|
| `escalamiento.sql` | Tabla `tbd_address_componentes`, `sp_crear_domicilio_escalado` (10 niveles) y `sp_crear_usuario` (tb_users + tb_people). |
| `casos_compra.sql` | 5 casos de compra con transacciones, validación de inventario, `SET ROLE` y verificación final. |
| `mongodb_direcciones.js` | Colección `direcciones_clientes`, 3 inserts, `findOne` por cliente y `find` por código postal con regex. |
| `README.md` | Este archivo. |

## MySQL vs MongoDB para el domicilio

| Aspecto | MySQL | MongoDB |
|---|---|---|
| Estructura | Árbol de 10 niveles en `tbd_address_componentes` | Un solo campo `direccion` (string) por documento |
| Padre | `address_sup_ID` (0 = raíz) | implícito: el orden de los componentes separados por coma |
| Consulta completa | Recorrer 10 niveles | `db.direcciones_clientes.findOne({cliente_id: 1001})` |
| Ventaja | Normaliza y reutiliza componentes | Lectura rápida, una sola colección |
| Costo | Más filas y joins/recorrido | Renombrar un componente exige actualizar muchos documentos |

Ejemplo del string en MongoDB:

```text
México, Jalisco, Zapopan, Zapopan, Ladera Norte, 45110, Real del Valle, Av. Patria, 120, 5B
```

## Requisitos

- Docker y Docker Compose.
- MySQL 8.0 (la base ya existe; los scripts usan `USE db_test;`).
- MongoDB y Mongo Express (NO Mongo Compass).
- MySQL Workbench para revisar las tablas.

## Mac

1. Abre Docker Desktop y espera a que esté activo.
2. En la raíz del proyecto levanta el stack:

   ```bash
   docker compose up -d
   ```

3. Mongo Express (interfaz web, sin Compass): <http://localhost:8081>
4. MySQL Workbench: conexión `127.0.0.1`, puerto `40545`, base `db_test`.
5. Ejecuta los scripts en orden:

   ```bash
   mysql -h 127.0.0.1 -P 40545 -u TU_USUARIO -p db_test < Practica04/escalamiento.sql
   mysql -h 127.0.0.1 -P 40545 -u TU_USUARIO -p db_test < Practica04/casos_compra.sql
   ```

   También puedes abrirlos desde MySQL Workbench.

## Fedora

1. Instala Docker y el plugin de Compose:

   ```bash
   sudo dnf install -y docker-ce docker-compose-plugin
   sudo systemctl enable --now docker
   sudo usermod -aG docker $USER
   ```

   Cierra sesión y vuelve a entrar para aplicar el grupo `docker`.

2. Levanta el stack:

   ```bash
   docker compose up -d
   ```

3. Mongo Express: <http://localhost:8081> (sin Compass).
4. MySQL Workbench: `127.0.0.1:40545`, base `db_test`.
5. Si el firewall bloquea puertos:

   ```bash
   sudo firewall-cmd --add-port=8081/tcp --permanent
   sudo firewall-cmd --add-port=40545/tcp --permanent
   sudo firewall-cmd --reload
   ```

## MongoDB sin Compass

Ejecuta el script con `mongosh` dentro del contenedor o desde el host:

```bash
docker exec -i TU_CONTENEDOR_MONGO mongosh bd_comercio_electronico_matricula < Practica04/mongodb_direcciones.js
```

Consultas rápidas:

```javascript
db.direcciones_clientes.findOne({ cliente_id: 1001 });
db.direcciones_clientes.find({ direccion: { $regex: "45110" } });
```

La interfaz web en <http://localhost:8081> (mongo-express) permite revisar la colección sin instalar Compass.

## Sincronizar Mac ↔ Fedora con Git

Trabaja en la rama `Practica04`:

```bash
git checkout Practica04
git add Practica04/
git commit -m "Practica 04: escalamiento, casos de compra y direcciones MongoDB"
git push
```

En la otra máquina:

```bash
git checkout Practica04
git pull
```

Así los cuatro archivos se mueven entre Mac y Fedora sin copiar/pegar manualmente.
