# delegation-scale

## MODIFIED Requirements

### Requirement: Puntuación previa a toda delegación
Antes de lanzar cualquier subagente, el orquestador SHALL puntuar la tarea en la escala 1-10, elegir el rol por conducta según el mapeo nivel→rol (1-4 `investigator`, 5-6 `builder` o `reviewer-lite` según sea implementación o review, 6-8 `reviewer`, 7+ divisible `sub-orchestrator`) y la combinación modelo+esfuerzo más barata que cubra el nivel, aplicando override de modelo sobre el default del rol cuando proceda. Nunca se delega a un modelo con capacidad muy superior a la necesaria.

#### Scenario: Duda entre dos combinaciones que cubren la tarea
- **WHEN** dos combinaciones modelo+esfuerzo cubren el nivel de la tarea
- **THEN** se elige la más barata; si el resultado vuelve flojo, se re-lanza un nivel arriba

#### Scenario: Nivel cubierto por rol con modelo superior al necesario
- **WHEN** el nivel de la tarea lo cubre el rol con un modelo más barato que su default
- **THEN** se invoca el rol con override de modelo hacia abajo, respetando el rango aceptable de la política (el effort del rol queda fijo)
