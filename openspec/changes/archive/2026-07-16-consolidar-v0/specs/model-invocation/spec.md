# model-invocation

## ADDED Requirements

### Requirement: Vía de invocación por proveedor
Modelos Claude SHALL invocarse vía parámetro `model` del agente/workflow. Modelos GPT SHALL invocarse vía codex CLI (skills `codex-*` o `codex exec`, plugin `/codex:review` y `/codex:rescue` dentro de Claude Code), consultando `docs/gpt-5.6-codex-cli.md` antes de la primera invocación.

#### Scenario: Delegar trabajo mecánico a GPT
- **WHEN** la política asigna una subtarea a un modelo GPT-5.6
- **THEN** se invoca vía codex CLI siguiendo la plantilla no interactiva documentada, nunca vía parámetro `model` de Claude

### Requirement: claudex subordinado
`claudex` (GPT como motor en harness Claude Code) SHALL usarse solo como mini-orquestador subordinado para bloques GPT-pesados, nunca como orquestador tope.

#### Scenario: Bloque grande GPT-pesado
- **WHEN** un bloque de trabajo se compone mayormente de subtareas GPT
- **THEN** puede delegarse a claudex como sub-orquestador, manteniendo el orquestador tope en Claude

### Requirement: Permisos mínimos por run de codex
Cada run de codex SHALL usar el permiso mínimo: read-only para análisis y reviews; `--sandbox workspace-write` solo si debe modificar archivos; `danger-full-access` nunca salvo entorno expresamente aislado más aprobación del usuario.

#### Scenario: Review de código vía codex
- **WHEN** se delega un análisis o review que no modifica archivos
- **THEN** el run de codex se lanza read-only

### Requirement: Costo codex visible
El costo de codex SHALL tratarse como costo monetario real en las decisiones de eficiencia aunque quede fuera de los presupuestos de tokens Claude del workflow.

#### Scenario: Elección entre agente Claude y codex para tarea equivalente
- **WHEN** una subtarea puede resolverla un agente Claude o un run de codex con calidad comparable
- **THEN** la decisión pondera el costo real de ambos, no solo los tokens Claude presupuestados
