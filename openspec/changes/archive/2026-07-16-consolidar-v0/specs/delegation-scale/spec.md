# delegation-scale

## ADDED Requirements

### Requirement: Puntuación previa a toda delegación
Antes de lanzar cualquier subagente, el orquestador SHALL puntuar la tarea en la escala 1-10 y elegir la combinación modelo+esfuerzo más barata que la cubra. Nunca se delega a un modelo con capacidad muy superior a la necesaria.

#### Scenario: Duda entre dos combinaciones que cubren la tarea
- **WHEN** dos combinaciones modelo+esfuerzo cubren el nivel de la tarea
- **THEN** se elige la más barata; si el resultado vuelve flojo, se re-lanza un nivel arriba

### Requirement: Umbral mínimo de delegación
El orquestador SHALL resolver inline lo resoluble en 1-2 tool calls; delegar eso cuesta más de lo que ahorra. Subtareas por debajo de ~nivel 3 se hacen inline o se agrupan en un solo agente.

#### Scenario: Tarea trivial candidata a delegación
- **WHEN** una tarea es resoluble por el orquestador en 1-2 tool calls
- **THEN** se resuelve inline sin delegar

### Requirement: Descomposición recursiva
Tareas de nivel ≥7 divisibles SHALL descomponerse en subtareas de menor nivel; bloques grandes e independientes van a un `sub-orchestrator` por bloque. La división se detiene cuando el overhead de contexto frío supera el ahorro.

#### Scenario: Bloque grande independiente dentro de tarea nivel 8
- **WHEN** una tarea nivel ≥7 contiene bloques grandes e independientes
- **THEN** cada bloque se delega a un sub-orchestrator que aplica la misma escala hacia abajo

### Requirement: Prompt autocontenido
Todo prompt de delegación SHALL incluir rutas, decisiones ya tomadas y criterio de aceptación verificable — el subagente arranca sin memoria del contexto del orquestador.

#### Scenario: Delegación de subtarea con contexto previo
- **WHEN** el orquestador delega una subtarea que depende de hallazgos de la sesión
- **THEN** el prompt incluye esos hallazgos, las rutas concretas y el criterio de éxito verificable

### Requirement: Paralelización segura
Solo subtareas independientes SHALL paralelizarse; todo agente que edite en paralelo usa `isolation: worktree`. Antes de integrar resultados paralelos se revisan conflictos, supuestos incompatibles y duplicación.

#### Scenario: Dos agentes editan en paralelo
- **WHEN** se lanzan dos o más agentes que editan archivos concurrentemente
- **THEN** cada uno corre con isolation worktree y la integración revisa conflictos antes de fusionar

### Requirement: Ajuste por gusto
Tareas que exigen gusto (escritura, API, UX, naming, docs) SHALL subir el MODELO uno o dos peldaños aunque el nivel de la tarea sea bajo.

#### Scenario: Redacción de docs nivel 3
- **WHEN** una tarea nivel 3 consiste en escribir documentación visible para usuarios
- **THEN** se delega a un modelo con Gusto ≥ 7 aunque la escala sugiera uno menor
