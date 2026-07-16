# Proposal: evolucion-via-openspec

## Why

Consolidar-v0 eliminó el drift de contenido (symlinks: una sola copia por construcción), pero el sistema aún puede editarse ad-hoc: git registra el qué, nadie registra el porqué, y las specs quedan describiendo un sistema que ya no existe — drift de gobernanza. Las specs solo valen si son verdad.

## What Changes

- Convención de gobernanza: todo cambio semántico al sistema (política, agentes, skills, docs, specs) pasa por openspec change; lo cosmético (typos, formato) va directo a commit.
- Una línea puntero en `core/CLAUDE.md` (~25 tokens): cambios al sistema → openspec change en este repo, nunca edición directa. Vía symlink llega a toda sesión de Claude en cualquier proyecto — auto-redirección.
- Contexto real del proyecto en `openspec/config.yaml` (hoy plantilla comentada): qué es el sistema, convención completa, umbral semántico-vs-cosmético. Solo se carga en flujos openspec — coste cero en el prompt diario.

Non-goals:

- Sin mecanismo de enforcement (hooks, pre-commit) **por ahora** — convención escrita primero; mecanismo diferido a cuando la convención falle en la práctica.
- Sin `rules` por artefacto en config.yaml — YAGNI.
- Compactar `core/CLAUDE.md` (121 líneas) queda fuera — problema de optimización, no de gobernanza; change propio si se aborda.

## Capabilities

### New Capabilities

- `governance`: convención de evolución del sistema — qué cambios exigen openspec change, dónde vive la convención (línea puntero global + contexto en config.yaml), umbral semántico-vs-cosmético.

### Modified Capabilities

(ninguna — `system-sync` cubre symlinks/install, concern distinto; sus requirements no cambian)

## Impact

- `core/CLAUDE.md` — +1 línea (llega a `~/.claude/CLAUDE.md` vía symlink existente).
- `openspec/config.yaml` — sección `context` rellenada.
- `openspec/specs/governance/spec.md` — nueva al archivar.
- Sin cambios de comportamiento runtime del sistema de orquestación.
