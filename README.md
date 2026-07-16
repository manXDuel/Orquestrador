# Orquestrador

Sistema multiagente y multimodelo para orquestar trabajo de desarrollo,
basado en el harness de **Claude Code**. Este repo es la **fuente de verdad**:
lo desplegado en `~/.claude/` son symlinks a estos archivos, así que el
sistema completo se reconstruye clonando el repo y ejecutando `./install.sh`.

Doble propósito: herramienta diaria (orquestar features, reviews,
investigación entre suscripciones Claude y ChatGPT) y laboratorio de
orquestación (experimentar patrones multiagente con historial git).

## Arquitectura v0

```
Política (core/CLAUDE.md, v1.3)
    │  prioridades: eficiencia > calidad > costo
    ▼
Orquestador (modelo más capaz disponible — hoy Fable 5)
    │  skill orchestrate: puntúa cada tarea 1-10,
    │  elige la combinación modelo+esfuerzo más barata que la cubra
    ├─▶ Agentes Claude (agents/)
    │     scout 1-2 · explorer-lite 3-4 · builder 5-6
    │     reviewer 6-8 · sub-orchestrator 7+ (recursivo)
    └─▶ Modelos GPT-5.6 vía codex CLI / plugin
          docs/gpt-5.6-codex-cli.md · docs/gpt-en-claude-code.md
```

## Estructura

| Ruta | Qué es | Desplegado en |
|---|---|---|
| `core/CLAUDE.md` | Política de orquestación multimodelo | `~/.claude/CLAUDE.md` |
| `skills/orchestrate/` | Escala 1-10 y mapeo modelo+esfuerzo | `~/.claude/skills/orchestrate` |
| `agents/*.md` | Los 5 agentes del sistema | `~/.claude/agents/*.md` |
| `docs/*.md` | Guías de invocación GPT (codex CLI, claudex) | `~/.claude/docs/*.md` |
| `openspec/` | Specs del sistema y changes en curso | — |

## Instalación

```bash
git clone <repo> && cd Orquestrador
./install.sh
```

Idempotente. Crea symlinks por archivo (conviven con material ajeno en
`~/.claude/agents/` y `~/.claude/docs/`). Si un destino existe con contenido
distinto, aborta mostrando el diff sin tocar nada.

Verificación: `readlink ~/.claude/CLAUDE.md` debe apuntar a `core/CLAUDE.md`
de este repo.

## Evolución

El sistema se gobierna a sí mismo vía [OpenSpec](openspec/): cambios a la
política, agentes o skills entran como change (proposal → design → specs →
tasks → apply → archive). Specs vigentes en `openspec/specs/`.

Roadmap:

1. **consolidar-v0** — este repo como fuente de verdad reconstruible. ✅
2. **evolución-vía-openspec** — convención de gobernanza: todo cambio al
   sistema pasa por change; contexto real en `openspec/config.yaml`.
3. **workflows-reproducibles** — recetas ejecutables para patrones
   repetidos de orquestación (feature completa, review cruzado GPT/Claude,
   investigación paralela). Primero como skills; Agent SDK cuando las
   skills se queden cortas. Incluye rediseño de agentes: de roster por
   tier (scout/explorer-lite/...) a roles con nivel parametrizado en el
   prompt y modelo por override de invocación (effort queda fijo por rol —
   límite del harness: el Agent tool solo permite override de `model`).

Futuro (nice to have): desplegar el sistema a otros harnesses (codex CLI,
opencode) o un harness propio. La estructura por-directorios (`.codex/`,
`.opencode/`) ya deja la puerta abierta.
