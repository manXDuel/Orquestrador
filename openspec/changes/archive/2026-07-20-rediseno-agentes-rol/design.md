# Design: rediseno-agentes-rol

## Hallazgos del harness (verificados 2026-07-17, docs post-v2.1.211)

### Qué congela la definición vs qué aporta la invocación

| Dimensión | Definición (frontmatter) | Invocación (Agent tool) |
|---|---|---|
| Conducta (system prompt) | ✅ | ❌ |
| `model` | default | ✅ override |
| `effort` (low–max) | ✅ | ❌ congelado |
| `tools` / `disallowedTools` | ✅ | ❌ |
| `skills` (precarga contenido completo) | ✅ | ❌ |
| `maxTurns` | ✅ | ✅ override |
| `run_in_background` | `background` | ✅ |
| `isolation: worktree` | ✅ | ✅ |
| `permissionMode`, `memory`, `hooks`, `mcpServers` | ✅ | ❌ |

### Régimen programático (contexto para `workflows-reproducibles`)

Agent SDK (`query()` con `agents`) y CLI `claude -p --agents '{json}'` (solo headless):

- `AgentDefinition` completo por run: model, **effort**, tools, skills → flexibilidad total que el interactivo no da.
- Fan-out determinista: N llamadas `query()` en paralelo (asyncio.gather) — orquestación en script, no en el modelo. Dentro de un solo `query()` el modelo decide qué agente invoca.
- Output estructurado garantizado (`output_format` con JSON Schema), presupuesto duro (`max_budget_usd`, `max_turns`), callbacks por tool call, resume por `session_id`.
- Anthropic-only: GPT sigue vía `codex exec` por Bash (igual que hoy).
- Pendiente de verificar: facturación (¿API key o hereda login del CLI?).

Frontera skill→SDK confirmada: las cuatro garantías que la skill no puede dar (presupuesto duro, gate sin discreción del modelo, fan-out con recolección, headless) existen todas en el SDK. Disparador de migración sigue siendo empírico: una receta migra cuando falle repetidamente en una de esas garantías.

## Decisiones

### D1 — `reviewer-lite` como rol separado, no override

Con effort congelado en la definición, `reviewer` (opus·high) + override a sonnet daría **sonnet·high** — fuera del rango aceptable de la política (Sonnet nunca por encima de medium). Un rol separado sonnet·medium es la única vía limpia en interactivo. Cubre la necesidad concreta: review barato de diff chico, hoy imposible (reviewer arranca en opus).

### D2 — Fusión scout+explorer-lite → `investigator` (sonnet·medium)

Únicos nombres-tier; solo diferían en effort. El effort low perdido se acepta: nivel 1-2 ultra-barato va inline del orquestador o a GPT Luna low vía codex (effort por run en esa rama).

### D3 — Nivel N vive en el prompt, no en el rol

Capacidad real = modelo×esfuerzo (harness). El nivel N del contrato de invocación solo calibra alcance y umbral de escape (">N+1 → para y reporta"). Los roles dejan de llevar rangos fijos en el nombre; el escalado deja de depender de heurísticas por agente.

### D4 — Contrato de invocación estandarizado

```
Rol: <investigator|builder|reviewer|reviewer-lite|sub-orchestrator>
Nivel estimado: N + porqué
Tarea: contexto frío completo (rutas, decisiones, hallazgos previos)
Aceptación: criterio verificable
Escape: si la tarea excede N+1, para y reporta lo encontrado
```

### D5 — Se conserva el nombre `builder`

Renombrar a implementer = churn sin ganancia.

## Preguntas abiertas (no bloquean)

- `memory: project` en investigator (aprendizaje cross-session del código): evaluar tras usar el roster nuevo; riesgo de memoria desactualizada vs ahorro de re-exploración.
- Sintaxis exacta de `skills:` en frontmatter de sub-orchestrator: verificar en implementación que la precarga funciona como documentado.
