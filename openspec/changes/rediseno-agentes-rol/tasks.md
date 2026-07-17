# Tasks: rediseno-agentes-rol

## 1. Agentes en `agents/`

- [ ] 1.1 Borrar `agents/scout.md` y `agents/explorer-lite.md`
- [ ] 1.2 Crear `agents/investigator.md` — sonnet·medium, tools solo lectura (Read, Glob, Grep, WebSearch, WebFetch, Bash), conducta: localizar/leer/sintetizar con rutas `archivo:línea`; escape >N+1
- [ ] 1.3 Crear `agents/reviewer-lite.md` — sonnet·medium, tools lectura + Bash, conducta: review de diff chico centrado en correctness; escape >N+1
- [ ] 1.4 Ajustar `agents/builder.md`, `agents/reviewer.md`, `agents/sub-orchestrator.md`: quitar rangos-tier fijos de las descriptions, referenciar nivel N por invocación y escape >N+1; sub-orchestrator lista los roles nuevos (investigator, builder, reviewer, reviewer-lite)
- [ ] 1.5 Añadir campo `effort` explícito al frontmatter de los cinco roles; verificar sintaxis `skills:` en sub-orchestrator (precarga documentada)

## 2. Despliegue

- [ ] 2.1 Symlinks `~/.claude/agents/`: eliminar los rotos (scout, explorer-lite), crear investigator y reviewer-lite — vía `install.sh` si los cubre; si no, a mano y anotar hueco de install.sh
- [ ] 2.2 Re-desplegar skill `orchestrate` a `~/.claude/skills/` (es copia, no symlink)

## 3. Skill `orchestrate` (repo `skills/orchestrate/SKILL.md`)

- [ ] 3.1 Actualizar tabla escala→agente con los cinco roles y sus defaults
- [ ] 3.2 Añadir contrato de invocación (Rol / Nivel N + porqué / Tarea contexto frío / Aceptación / Escape >N+1)
- [ ] 3.3 Nota breve: effort congelado por rol en interactivo; effort fino y fan-out dirigido → régimen SDK (change workflows-reproducibles)

## 4. Verificación

- [ ] 4.1 `openspec validate --change rediseno-agentes-rol` en verde
- [ ] 4.2 Sesión nueva ve los cinco roles en el listado de agentes disponibles (smoke test de symlinks)
- [ ] 4.3 Invocación de prueba a `investigator` y `reviewer-lite` con el contrato — responden dentro de alcance y modelo esperado
