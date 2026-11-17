# AGENTS.md

## Convenciones del repositorio

- La práctica 04 canónica es `Practica04/`. No crear ni mantener un directorio `practica_04/`.
- El diagrama publicado de la práctica 04 es `docs/modelo-relacional.html`.
- En `docs/`, el único artefacto de Archify que se conserva es `modelo-relacional.html`. No dejar `review-*`, `delivery.json`, receipts ni capturas.

## Reglas de Archify

- Usar el skill `archify` para diagramas y explicaciones visuales. No entregar Mermaid ni SVG dibujado a mano como artefacto final.
- CLI instalada globalmente: `/Users/yait/.agents/skills/archify/bin/archify.mjs`. Ejecutar todos los comandos desde la raíz del repositorio.
- Cada artefacto nuevo vive en `.archify/<type>-<slug>-<YYYYMMDD-HHMMSS>/` con su `candidate.json`. Las reparaciones reutilizan esa misma carpeta; una solicitud nueva usa otra carpeta. `meta.output` es relativo a la raíz del repo.
- Escribir el candidate completo y ejecutar una sola vez:
  - `node /Users/yait/.agents/skills/archify/bin/archify.mjs finalize <type> <candidate> <output> --repo-root . --quality showcase --json`
  - No hacer validaciones preliminares por separado. Un exit distinto de cero nunca es éxito.
- Para diagramas basados en código, incluir `sources` reales con ruta y líneas. No inventar DDL de procedimientos almacenados sin evidencia; si falta, declararlo como contexto o requisito, no como código verificado.
- Si `finalize` falla, leer el receipt, ajustar solo el vecindario afectado y repetir el comando completo. Preservar semántica, nombres completos y evidencia pedida por el usuario.
- Cuando el output ya tiene evidencia de `browser-check`, cada rerun debe usar `--out-dir <folder>/review-<n>`. Esos directorios son temporales: borrarlos antes de commit.
- Si el usuario entrega Mermaid, usarla solo para topología y sentido; reescribirla como JSON nativo de Archify, sin copiar estilos Mermaid.
- Distinguir en la respuesta entre checks automáticos, evidencia de navegador y revisión visual real. No afirmar que algo fue revisado visualmente si no se hizo.
- Responder en el idioma del usuario con un link clicable al HTML absoluto, y aclarar abstracción, omisiones deliberadas y evidencia faltante.
