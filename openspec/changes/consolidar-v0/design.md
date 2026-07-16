# Design: consolidar-v0

## Context

El sistema v0 funciona hoy repartido entre `~/.claude/` (desplegado) y este repo (foto parcial). Verificado 2026-07-16: cero drift byte a byte entre las 4 piezas duplicadas. Los 5 agentes solo existen en `~/.claude/agents/`. No hay git ni README. La ventana para migrar a symlinks sin conflictos es ahora.

## Goals / Non-Goals

**Goals:**
- Repo = fuente de verdad única y reconstruible: clonar + `install.sh` = sistema operativo completo.
- Drift estructuralmente imposible entre repo y `~/.claude/`.
- Capacidades v0 capturadas como specs (base para gobernanza futura vía openspec).

**Non-Goals:**
- Workflows ejecutables, telemetría, presupuestos (changes futuros).
- Desplegar el sistema a otros harnesses (codex/opencode) — solo Claude Code.
- Cambiar contenido de política, skill o agentes: consolidación pura, cero cambios de comportamiento.

## Decisions

**D1 — Symlinks, no script de sync.** `~/.claude/X` → symlink al archivo del repo. Alternativas: script de copia bidireccional (drift entre corridas, resolución de conflictos) y GNU stow (dependencia extra para 4 symlinks). Symlink directo: cero dependencias, drift imposible, `readlink` como verificación. Riesgo conocido: editar "el archivo de ~/.claude" edita el repo — es exactamente el comportamiento deseado.

**D2 — Granularidad de symlinks.** Symlink por archivo para `CLAUDE.md` y docs; symlink de directorio para `skills/orchestrate` y NO para `agents/` ni `docs/` completos — `~/.claude/agents/` y `~/.claude/docs/` pueden contener material ajeno al sistema en el futuro. Symlinks por archivo (`~/.claude/agents/scout.md` → `repo/agents/scout.md`) conviven con archivos no gestionados.

**D3 — `install.sh` idempotente y mínimo.** Crea los symlinks; si el destino existe y no es symlink al repo, compara: idéntico → reemplaza; distinto → aborta con diff y no toca nada. Sin flags, sin config. Bash puro.

**D4 — Specs = descripción del sistema actual.** Las 5 specs capturan v0 tal cual es (política v1.3, escala, roster, invocación, sync). No introducen requisitos nuevos salvo `system-sync`, la única capability con comportamiento nuevo real.

**D5 — git init al inicio de la implementación.** Primer commit = estado pre-cambio (trazabilidad), segundo commit = consolidación completa.

## Risks / Trade-offs

- [Symlink roto si el repo se mueve/renombra] → `install.sh` re-ejecutable; verificación con `readlink` documentada en README.
- [Herramienta que no siga symlinks al leer `~/.claude/`] → improbable (Claude Code los sigue); mitigación: probar sesión nueva tras migrar, rollback = copiar archivos de vuelta.
- [Backup/sync de HOME que no preserve symlinks] → contenido siempre recuperable desde el repo git; el repo es la fuente, no `~/.claude`.

## Migration Plan

1. git init + commit del estado actual del repo.
2. Copiar agentes al repo, crear README + install.sh + specs.
3. Ejecutar `install.sh` (reemplaza archivos reales por symlinks — contenido idéntico verificado).
4. Verificar: `readlink`, sesión nueva de Claude Code carga política y agentes.
5. Rollback: `cp -L` de los symlinks a archivos reales (o `git checkout` en el repo).

## Open Questions

(ninguna)
