# Tasks: consolidar-v0

## 1. Versionado

- [x] 1.1 `git init` en el repo y commit inicial con el estado actual (pre-cambio)

## 2. Contenido al repo

- [x] 2.1 Copiar los 5 agentes de `~/.claude/agents/` a `agents/` (scout, explorer-lite, builder, reviewer, sub-orchestrator)
- [x] 2.2 Crear `README.md` con visión, arquitectura v0 y roadmap de 3 changes

## 3. Sync por symlinks

- [x] 3.1 Crear `install.sh` idempotente: symlinks por archivo (CLAUDE.md, docs, agentes) y de directorio (skills/orchestrate); destino divergente → aborta con diff
- [x] 3.2 Ejecutar `install.sh` y verificar con `readlink` que cada ruta de `~/.claude/` apunta al repo

## 4. Verificación y cierre

- [x] 4.1 Verificar sesión nueva de Claude Code: carga política y lista los 5 agentes igual que antes
- [x] 4.2 `openspec validate consolidar-v0` pasa
- [x] 4.3 Commit final de la consolidación
