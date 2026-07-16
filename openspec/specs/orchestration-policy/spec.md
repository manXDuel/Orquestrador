# orchestration-policy

## Requirements


### Requirement: Orquestador más capaz disponible
El modelo más capaz disponible SHALL actuar como orquestador (hoy Fable 5); si aparece uno superior, asume el rol sin cambiar el resto de la política.

#### Scenario: Modelo superior disponible
- **WHEN** un modelo más capaz que el orquestador actual está disponible en el harness
- **THEN** ese modelo asume el rol de orquestador y el resto de la política aplica sin cambios

### Requirement: Prioridades de decisión
Toda decisión de delegación SHALL ordenar: (1) eficiencia — trabajo total esperado incluyendo costo de malos resultados, (2) calidad a eficiencia similar, (3) costo monetario como desempate. En conflicto de ejes sobre output que va a producción o al usuario: Inteligencia > Gusto > Costo.

#### Scenario: Dos opciones con eficiencia similar
- **WHEN** dos combinaciones modelo+esfuerzo cubren la tarea con eficiencia esperada similar
- **THEN** se elige la de mayor calidad esperada; a calidad comparable, la más barata

### Requirement: Restricciones duras de modelos
El sistema SHALL respetar: Fable 5 Max/xhigh solo con aprobación explícita del usuario; Sonnet 5 nunca por encima de medium salvo petición expresa; nunca Haiku ni modelos Anthropic por debajo de Sonnet 5; contenido visible para usuarios exige Gusto ≥ 7.

#### Scenario: Tarea user-facing con modelo de gusto bajo
- **WHEN** se va a delegar contenido visible para usuarios (UI, copy, API, docs) a un modelo con Gusto < 7
- **THEN** se sustituye por un modelo con Gusto ≥ 7 antes de delegar

### Requirement: Política de fallos
Cada subtarea SHALL tener máximo 3 intentos; cada reintento cambia al menos 1 variable. Errores deterministas de entorno NO se reintentan sin corregir la causa. No se escala el modelo si la causa del fallo no depende de su capacidad.

#### Scenario: Error determinista de entorno
- **WHEN** una delegación falla por permisos, auth, ruta inválida o herramienta ausente
- **THEN** se corrige la causa o se informa, sin repetir el intento sin cambios

### Requirement: Fallback por indisponibilidad
Si el modelo elegido no está disponible, el sustituto SHALL minimizar primero la pérdida de Inteligencia y después optimizar Costo, respetando todas las restricciones; si ninguno alcanza el mínimo, se informa la degradación antes de dar el resultado por definitivo.

#### Scenario: Ningún sustituto alcanza el mínimo
- **WHEN** el modelo requerido no está disponible y ningún sustituto cubre el nivel de la tarea
- **THEN** se informa la degradación al usuario antes de entregar el resultado como definitivo
