# governance

## Purpose

Regir cómo evoluciona el sistema: qué cambios exigen openspec change y dónde vive la convención.

## Requirements


### Requirement: Cambio semántico exige openspec change
Todo cambio semántico al sistema (política `core/CLAUDE.md`, agentes `agents/*.md`, skills, docs `docs/*.md`, specs) SHALL pasar por un openspec change en este repo: proposal captura el porqué, delta-spec actualiza la spec afectada, archive deja historia. Cambios cosméticos (typos, formato, reordenar sin cambiar significado) MAY ir directo a commit.

#### Scenario: Cambio de política
- **WHEN** se quiere modificar una regla de la política de orquestación (p.ej. restringir un modelo)
- **THEN** se crea un openspec change con proposal y delta-spec antes de editar `core/CLAUDE.md`

#### Scenario: Corrección de typo
- **WHEN** se corrige un typo en `core/CLAUDE.md` sin alterar significado
- **THEN** se commitea directo, sin change

### Requirement: Puntero global a la convención
`core/CLAUDE.md` SHALL contener una línea que indique que los cambios al sistema de orquestación pasan por openspec change en este repo y nunca por edición directa, de modo que toda sesión de Claude (en cualquier proyecto, vía symlink `~/.claude/CLAUDE.md`) conozca la regla y se auto-redirija.

#### Scenario: Sesión en otro proyecto intenta editar la política
- **WHEN** una sesión de Claude en un proyecto cualquiera recibe la instrucción de cambiar la política de orquestación
- **THEN** la sesión conoce la convención por la línea en `~/.claude/CLAUDE.md` y redirige el cambio a un openspec change en este repo

### Requirement: Contexto real en config.yaml
`openspec/config.yaml` SHALL contener contexto real del proyecto (qué es el sistema, piezas que lo componen, convención de gobernanza con su umbral semántico-vs-cosmético) en lugar de la plantilla comentada, de modo que los flujos openspec generen artefactos informados sin coste en el prompt diario.

#### Scenario: Creación de artefacto con contexto
- **WHEN** un flujo openspec genera un artefacto (proposal, specs, tasks)
- **THEN** recibe el contexto del sistema desde `openspec/config.yaml`

#### Scenario: Sesión normal fuera de flujos openspec
- **WHEN** una sesión de Claude trabaja en cualquier proyecto sin usar flujos openspec
- **THEN** el contexto de `openspec/config.yaml` no se carga y no añade tokens al prompt
