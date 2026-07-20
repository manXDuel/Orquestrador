# Proposal: rediseno-agentes-rol

## Why

El roster actual (scout, explorer-lite, builder, reviewer, sub-orchestrator) nació como boceto con nombres-tier: scout y explorer-lite solo se distinguen por effort, duplicando la escala de delegación en los nombres. Además, la exploración del harness (2026-07-17, docs oficiales de Claude Code) demostró que el supuesto de diseño era incompleto:

- El frontmatter de agentes soporta `effort`, `skills` (precarga), `maxTurns`, `memory`, `disallowedTools`, `isolation` — no solo model y tools.
- Por invocación solo varía `model`, `maxTurns`, `run_in_background` (+ `isolation` en el Agent tool). El effort queda congelado en la definición.
- La vía programática (Agent SDK / `claude -p --agents`) sí ofrece effort por run, fan-out determinista, output JSON con schema y presupuesto duro — pero es headless y queda para el change futuro `workflows-reproducibles`.

El roster debe derivar de las necesidades reales del sistema — review cruzado multi-modelo, features orquestadas, investigación paralela barata — no de tiers de la escala.

## What Changes

Roster de 5 roles para el régimen interactivo:

| Rol | Modelo default | Effort | Tools | Necesidad que sirve |
|---|---|---|---|---|
| `investigator` | sonnet | medium | solo lectura | investigación paralela barata; niveles 1-4 (fusión scout+explorer-lite) |
| `builder` | sonnet | medium | todos | implementación acotada 5-6 |
| `reviewer` | opus | high | lectura + Bash | review profundo 7-8; lado Claude del review cruzado |
| `reviewer-lite` | sonnet | medium | lectura + Bash | review barato de diff chico (5-6) |
| `sub-orchestrator` | opus | high | todos + `skills: orchestrate` | bloques ≥7 divisibles |

- La invocación aporta: `model` override + nivel N en el prompt (calibra alcance y escape ">N+1 → para y reporta") + `maxTurns` para acotar fan-outs.
- Contrato de invocación estandarizado (Rol / Nivel N + porqué / Tarea con contexto frío / Aceptación / Escape) como requirement.
- Specs afectadas: `agent-roster` (roster, escalado, contrato), `delegation-scale` (mapeo nivel→rol).
- Archivos afectados en implementación: `agents/*.md`, symlinks `~/.claude/agents/`, skill `orchestrate` (repo + copia desplegada).

## What Stays Out

- Régimen SDK/headless, recetas reproducibles, spec `workflows` → change siguiente (`workflows-reproducibles`).
- `memory: project` para investigator: pregunta abierta en design.md, no se adopta aquí.
- `~/.claude/CLAUDE.md`: no nombra agentes, sin edición.

## Principio de diseño

Roles markdown congelan conducta + effort + modelo default para la sesión interactiva; effort fino, fan-out dirigido y presupuestos duros se delegan al futuro régimen SDK — no se fuerzan en el roster.
