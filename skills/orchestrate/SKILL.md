---
name: orchestrate
description: Orquestar y delegar trabajo a subagentes eligiendo el modelo y esfuerzo justo para cada tarea ("the right tool for the job"). Usar al delegar, dividir tareas, lanzar subagentes, paralelizar trabajo, o cuando el usuario pida orquestar, ahorrar tokens, o dividir una feature en partes.
---

# Orchestrate — the right tool for the job

Tú eres el orquestador (el modelo más capaz disponible — hoy Fable 5; si
otro superior asume ese rol, estas reglas aplican igual). Antes de lanzar
CUALQUIER subagente, puntúa la tarea en la escala 1–10 y elige la
combinación **más barata que la cubra**. Nunca delegues a un modelo con
capacidad muy superior a la necesaria.

## Escala de capacidad

| Nivel | Ejemplos | Rol (agente) / modelo+esfuerzo |
|---|---|---|
| 1–4 | búsqueda web puntual, leer/localizar dónde vive algo, resumen multi-archivo, exploración de código acotada, fix trivial | `investigator` (sonnet, medium) o GPT-5.6 Luna low / Composer 2.5 / Terra medium vía codex |
| 5–6 (implementación) | feature pequeña, bug con repro claro | `builder` (sonnet, medium) o GPT-5.6 Sol medium / Opus 4.8 |
| 5–6 (review) | review de diff chico | `reviewer-lite` (sonnet, medium) o GPT-5.6 Sol medium / Opus 4.8 |
| 6–8 (review) | review profundo: arquitectura, bug sutil sin repro, lado Claude del review cruzado multi-modelo | `reviewer` (opus, high, **review-only**) o Sol high–max |
| 7+ divisible | implementación grande: feature multi-archivo, refactor con riesgo | `sub-orchestrator` (opus, high) por bloque, o descomponer |
| 9–10 | diseño de sistema, decisiones ambiguas, coordinar sub-orquestadores | tú mismo (inline o fork) |

`reviewer` es **review-only** (lectura + Bash, no implementa): la
implementación grande no vive en su fila sino en `7+ divisible` →
`sub-orchestrator`.

## Mapeo modelo+esfuerzo → nivel

**Negrita** = peldaño por defecto (mejor calidad/costo de su familia).
Empieza ahí; sube o baja de tier según el nivel de la tarea.

| Modelo | Nivel por esfuerzo |
|---|---|
| Orquestador (Fable 5) | low 7 · medium 8 · **high 9** · xhigh 10 · Max 10 (ambos solo con aprobación) |
| GPT-5.6 Sol | **medium 6** · high 7 · max 7–8 |
| Opus 4.8 | **high 6–7** |
| GPT-5.6 Terra | **medium 2–4** · max 6–7 |
| GPT-5.6 Luna | low 1–2 · **medium 2–3** · max 5–6 |
| Sonnet 5 | low 3 · **medium 4–5** |
| Composer 2.5 | **3–5** (único, sin tiers) |

Las 4 cualidades, restricciones (Gusto ≥ 7 user-facing, nunca Haiku,
Fable Max/xhigh solo con aprobación) y las políticas de fallos y fallback
viven en `~/.claude/CLAUDE.md` — esa política manda si hay conflicto.

Ajustes sobre el nivel:
- Tarea que exige **gusto** (escritura, API, UX, naming, docs) → sube el
  MODELO uno o dos peldaños aunque el nivel sea bajo.
- Cada nivel es un **rango**, no un mapeo fijo: un nivel 4 admite sonnet
  ≤medium **o** un modelo mayor con esfuerzo recortado. En caso de duda
  entre dos combinaciones que cubren la tarea, elige la más barata. Si el
  resultado vuelve flojo, re-lanza un nivel arriba — un retry barato + un
  acierto caro sigue siendo más barato que empezar siempre con el cañón.
- Nivel 9–10 → orquestador inline (o fork, que hereda modelo y contexto).

## Contrato de invocación

Todo prompt de delegación a un rol sigue este contrato, para que el agente
conozca su umbral sin heurísticas propias:

- **Rol**: el rol elegido de la tabla.
- **Nivel N**: el nivel estimado y su porqué.
- **Tarea**: contexto frío completo — rutas, decisiones ya tomadas,
  hallazgos previos (el agente arranca sin memoria; todo va en el prompt).
- **Aceptación**: criterio verificable de éxito.
- **Escape**: si la tarea excede **N+1**, el agente para y reporta lo hecho
  hasta ahí — no la fuerza.

El `effort` va **congelado por rol** en modo interactivo: lo fija la
definición del agente, y la invocación solo permite override del **modelo**,
no del effort. Para effort fino por subtarea y fan-out dirigido, ese régimen
vive en el SDK — ver change `workflows-reproducibles`.

## Descomposición (recursión)

- Tarea ≥7 y divisible → divídela en subtareas de menor nivel. Bloques grandes
  e independientes → un `sub-orchestrator` por bloque, que aplica esta misma
  skill hacia abajo.
- Deja de dividir cuando el overhead de contexto frío supere el ahorro:
  subtareas <~nivel 3 se hacen inline o se agrupan en un solo agente.
- No delegues lo que tú resuelves en 1–2 tool calls: delegar eso cuesta más de
  lo que ahorra.

## Reglas prácticas

- **Paraleliza**: subagentes independientes se lanzan en un solo mensaje.
- **Contexto frío**: cada agente nuevo arranca sin memoria — pon en el prompt
  rutas, decisiones ya tomadas y el criterio de éxito. No le hagas redescubrir
  lo que tú ya sabes.
- **fork** cuando el subagente necesita toda la conversación (hereda tu
  contexto y modelo); agente fresco para tareas autocontenidas.
- **SendMessage** para continuar un agente vivo con su contexto intacto antes
  que lanzar uno nuevo sobre el mismo tema.
- El resultado del agente te llega a ti, no al usuario: retransmite lo que
  importa.
