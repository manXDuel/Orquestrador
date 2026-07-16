# agent-roster

## ADDED Requirements

### Requirement: Roster de cinco agentes por nivel
El sistema SHALL definir cinco agentes mapeados a la escala de delegación: `scout` (1-2, sonnet low, solo lectura/búsqueda), `explorer-lite` (3-4, sonnet medium, exploración), `builder` (5-6, sonnet medium, implementación acotada), `reviewer` (6-8, opus high, review profundo), `sub-orchestrator` (7+ divisible, opus high + skill orchestrate).

#### Scenario: Tarea nivel 5 con repro claro
- **WHEN** el orquestador puntúa una tarea como nivel 5-6 (feature pequeña, bug con repro)
- **THEN** la delega a `builder` o equivalente GPT según la política de modelos

### Requirement: Escalado hacia arriba, nunca silencioso
Cada agente SHALL parar y reportar cuando la tarea excede su nivel (scout >~5 tool calls; explorer-lite ante diseño multi-archivo; builder ante refactor amplio o arquitectura), en vez de intentarla.

#### Scenario: Scout encuentra tarea compleja
- **WHEN** un scout detecta que la consulta requiere editar código o más de ~5 tool calls
- **THEN** reporta que excede su nivel junto con lo encontrado hasta ahí, sin intentar resolverla

### Requirement: Definiciones de agentes versionadas en el repo
Las definiciones de los cinco agentes SHALL vivir en `agents/*.md` del repo como fuente de verdad, desplegadas a `~/.claude/agents/` vía symlink.

#### Scenario: Edición de un agente
- **WHEN** se modifica la definición de un agente del sistema
- **THEN** el cambio se hace en el repo (directamente o a través del symlink) y queda en el historial git
