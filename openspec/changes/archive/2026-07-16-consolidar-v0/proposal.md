# Proposal: consolidar-v0

## Why

El sistema v0 de orquestación multiagente/multimodelo ya funciona, pero vive disperso en `~/.claude/` (política, 5 agentes, skill orchestrate, docs) y este repo es una foto parcial sin git, sin visión escrita y sin los agentes. El sistema no puede reconstruirse desde el repo en una máquina limpia, y cada edición ad-hoc en `~/.claude/` arriesga drift silencioso.

## What Changes

- `git init` + commit inicial del estado actual del repo.
- `README.md` con la visión: qué es el sistema, arquitectura v0 (política → orquestador Fable 5 → escala 1-10 → agentes Claude + codex/GPT), roadmap de 3 changes (consolidar-v0, evolución-vía-openspec, workflows-reproducibles).
- Copiar los 5 agentes (`scout`, `explorer-lite`, `builder`, `reviewer`, `sub-orchestrator`) de `~/.claude/agents/` a `agents/` en el repo.
- Sync por symlinks: los archivos desplegados en `~/.claude/` pasan a ser symlinks al repo (drift imposible por construcción). `install.sh` mínimo los crea en máquina nueva.
- Specs iniciales capturando las capacidades v0 del sistema.

## Capabilities

### New Capabilities

- `orchestration-policy`: política de orquestación multimodelo — prioridades (eficiencia > calidad > costo), Tabla 1 de modelos, restricciones de esfuerzo, política de fallos y fallback.
- `delegation-scale`: escala de capacidad 1-10, mapeo modelo+esfuerzo→nivel, reglas de descomposición y paralelización (skill `orchestrate`).
- `agent-roster`: los 5 agentes del sistema con su nivel, modelo, esfuerzo y límites de escalado.
- `model-invocation`: vías de invocación por proveedor — Claude vía parámetro `model`, GPT vía codex CLI/plugin, claudex subordinado; permisos mínimos por run.
- `system-sync`: el repo como fuente de verdad reconstruible — symlinks a `~/.claude/`, install en máquina nueva, cero drift.

### Modified Capabilities

(ninguna — no existen specs previas)

## Impact

- Repo: nuevos `README.md`, `install.sh`, `agents/*.md` (5), `openspec/specs/*`.
- Fuera del repo: archivos reales de `~/.claude/` (CLAUDE.md, skills/orchestrate, docs/gpt-*.md, agents/*.md) reemplazados por symlinks al repo. Reversible; contenido hoy idéntico byte a byte (verificado).
- Sin cambios de comportamiento del sistema en runtime: Claude Code lee los mismos contenidos vía symlink.
