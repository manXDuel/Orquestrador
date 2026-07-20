# agent-roster

## RENAMED Requirements

- FROM: `### Requirement: Roster de cinco agentes por nivel`
- TO: `### Requirement: Roster de cinco roles`

## MODIFIED Requirements

### Requirement: Roster de cinco roles
El sistema SHALL definir cinco roles de agente derivados de las necesidades del sistema (review cruzado multi-modelo, features orquestadas, investigación paralela barata): `investigator` (sonnet medium, solo lectura — exploración y búsqueda), `builder` (sonnet medium — implementación acotada), `reviewer` (opus high, lectura+Bash — review profundo, lado Claude del review cruzado), `reviewer-lite` (sonnet medium, lectura+Bash — review barato de diff chico), `sub-orchestrator` (opus high + skill orchestrate precargada — bloques divisibles). Cada rol congela conducta, effort y modelo default; la invocación aporta override de modelo, nivel N en el prompt y `maxTurns` opcional.

#### Scenario: Tarea nivel 5 con repro claro
- **WHEN** el orquestador puntúa una tarea como nivel 5-6 (feature pequeña, bug con repro)
- **THEN** la delega a `builder` o equivalente GPT según la política de modelos

#### Scenario: Review barato de diff chico
- **WHEN** el orquestador necesita review de un diff pequeño sin justificar opus·high
- **THEN** delega a `reviewer-lite` (sonnet·medium) en vez de `reviewer` con override de modelo, porque el effort congelado en high haría sonnet·high — fuera del rango aceptable de la política

#### Scenario: Exploración de código nivel 3
- **WHEN** el orquestador puntúa una tarea de exploración como nivel 3-4
- **THEN** la delega a `investigator` con el nivel N declarado en el prompt

## ADDED Requirements

### Requirement: Escalado hacia arriba por nivel N declarado
Cada agente SHALL parar y reportar cuando la tarea excede el nivel N declarado en su prompt de invocación (umbral: >N+1), en vez de intentarla. El umbral de escape viaja en el contrato de invocación, no en heurísticas fijas por agente.

#### Scenario: Investigator recibe tarea que excede su nivel
- **WHEN** un `investigator` invocado con nivel N=3 detecta que la tarea exige diseño multi-archivo (nivel ≥5)
- **THEN** para y reporta que excede N+1 junto con lo encontrado hasta ahí, sin intentar resolverla

### Requirement: Contrato de invocación
Todo prompt de delegación a un rol SHALL seguir el contrato: Rol elegido, Nivel estimado N con su porqué, Tarea con contexto frío completo (rutas, decisiones, hallazgos previos), criterio de Aceptación verificable, y cláusula de Escape (si excede N+1, parar y reportar).

#### Scenario: Delegación sin nivel declarado
- **WHEN** el orquestador redacta un prompt de delegación
- **THEN** incluye el nivel N estimado y la cláusula de escape, de modo que el agente conoce su umbral sin heurísticas propias

## REMOVED Requirements

### Requirement: Escalado hacia arriba, nunca silencioso
El escalado heurístico por agente se reemplaza por el umbral `>N+1` declarado en el contrato de invocación (ver `Escalado hacia arriba por nivel N declarado`). Los agentes viejos que nombraba (scout, explorer-lite) ya no existen.

#### Scenario: Scout encuentra tarea compleja
- **WHEN** un scout detecta que la consulta requiere editar código o más de ~5 tool calls
- **THEN** reporta que excede su nivel junto con lo encontrado hasta ahí, sin intentar resolverla
