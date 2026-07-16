# system-sync

## Requirements


### Requirement: Repo como fuente de verdad única
Toda pieza del sistema (política `core/CLAUDE.md`, skill `skills/orchestrate`, agentes `agents/*.md`, docs `docs/*.md`) SHALL vivir en el repo bajo git; las rutas desplegadas en `~/.claude/` son symlinks a los archivos del repo.

#### Scenario: Lectura de la política por el harness
- **WHEN** Claude Code lee `~/.claude/CLAUDE.md`
- **THEN** obtiene, vía symlink, el contenido de `core/CLAUDE.md` del repo sin copia intermedia

### Requirement: Instalación reconstruible
Un `install.sh` en la raíz del repo SHALL crear todos los symlinks necesarios en `~/.claude/` de forma idempotente: re-ejecutarlo sobre un sistema ya instalado no cambia nada.

#### Scenario: Máquina nueva
- **WHEN** se clona el repo en una máquina limpia y se ejecuta `install.sh`
- **THEN** el sistema queda operativo: política, skill orchestrate, 5 agentes y docs accesibles desde `~/.claude/`

#### Scenario: Re-ejecución sobre sistema instalado
- **WHEN** `install.sh` se ejecuta y los symlinks ya apuntan al repo
- **THEN** termina sin errores y sin modificar nada

### Requirement: Protección contra sobrescritura destructiva
Si un destino en `~/.claude/` existe como archivo real, `install.sh` SHALL compararlo con el archivo del repo: idéntico → lo reemplaza por symlink; distinto → aborta mostrando el diff sin tocar nada.

#### Scenario: Archivo local divergente
- **WHEN** `install.sh` encuentra en `~/.claude/` un archivo real cuyo contenido difiere del repo
- **THEN** aborta mostrando la diferencia y no modifica ningún archivo

### Requirement: Convivencia con material ajeno
Los symlinks SHALL crearse por archivo dentro de `~/.claude/agents/` y `~/.claude/docs/` (no symlink de directorio), de modo que archivos no gestionados por el sistema convivan sin conflicto.

#### Scenario: Agente personal ajeno al sistema
- **WHEN** el usuario tiene en `~/.claude/agents/` un agente propio no gestionado por el repo
- **THEN** `install.sh` no lo toca y los agentes del sistema se instalan a su lado
