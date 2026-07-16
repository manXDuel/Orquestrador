# Workflows y subagentes

Orquestación multimodelo: el modelo más capaz disponible orquesta — hoy
Fable 5; si aparece uno superior (p.ej. un Mythos), asume el rol sin cambiar
el resto de la política. Política v1.3 — calibración manual: 2026-07.

## Prioridades

1. **Eficiencia**: minimizar trabajo total esperado (tokens, costo, latencia,
   reintentos) para un resultado utilizable. No es elegir el más barato:
   incluye el costo esperado de malos resultados y correcciones.
2. **Calidad**: a eficiencia similar, mayor calidad esperada.
3. **Costo**: a calidad comparable, menor costo monetario (desempate).

Evalúa el output, no la etiqueta de precio. Conflicto de ejes en algo que va
a producción o al usuario: **Inteligencia > Gusto > Costo**.

Ejes de la Tabla 1 (0–10, más alto siempre mejor). Notas no obvias:
**Costo** = retorno de trabajo útil por costo/tokens (10 = más barato), NO
precio listado. **Creatividad**: alta = propone alternativas e itera (~9 =
Fable); baja = literal (GPT); para tareas literales y acotadas conviene
baja, no es un downgrade.

## Tabla 1 — Modelos (promedio de su rango aceptable de esfuerzo)

| Modelo        | Rango aceptable | Intel | Costo | Gusto | Creat |
|---------------|-----------------|:-----:|:-----:|:-----:|:-----:|
| Fable 5       | high–low*       |  9    | 2     |  9    | 9     |
| GPT-5.6 Sol   | max–medium      |  8    | 6     |  5    | 4     |
| Opus 4.8      | xhigh–medium    |  7    | 7     |  8    | 7     |
| GPT-5.6 Terra | max–medium      |  7    | 8     |  4    | 4     |
| GPT-5.6 Luna  | max–medium      |  6    | 5     |  3    | 2     |
| Sonnet 5      | medium–low**    |  5    | 4     |  7    | 7     |

*Fable 5 Max/xhigh SOLO con aprobación explícita del usuario; único modelo
autorizado a Max. En el resto, los tiers cuyo costo supera con mucho su
beneficio quedan fuera del rango aceptable.
**Sonnet 5 nunca por encima de medium salvo petición expresa del usuario.

Límites generosos de un proveedor ≠ gratis ni ilimitado: costo, latencia
y reintentos entran en la decisión de eficiencia.

## Cómo aplicar

Defaults y sugerencias, NO techos duros:

- Output de modelo barato bajo el estándar → re-lanza (o replantea) con uno
  más capaz SIN pedir permiso e informa al usuario del resultado fallido.
- Usa modelos baratos para investigar o probar alternativas antes de una
  opción cara.
- **Trabajo pesado y mecánico** (spec clara, análisis de datos, migraciones)
  → GPT-5.6, por eficiencia.
- **Contenido visible para usuarios** (UI, copy, diseño de API, docs de
  usuario) → Gusto ≥ 7.
- **Reviews y planes** → Fable, Opus 4.8 o GPT-5.6 Sol (perspectiva extra).
- Tarea abierta que se beneficia de alternativas → creatividad alta;
  ejecución literal y acotada → creatividad baja.
- Nunca Haiku ni ningún modelo Anthropic por debajo de Sonnet 5.
- Modelo no disponible → sustituto que minimice primero la pérdida de
  Inteligencia y después optimice Costo, respetando todas las restricciones
  anteriores; si ninguno alcanza el mínimo, informa la degradación antes de
  dar el resultado por definitivo.

Delegación:

- Solo si aporta ventaja clara en tiempo, contexto o calidad. Nunca delegues
  lo resoluble en 1–2 tool calls.
- Escala 1–10 y mapeo modelo+esfuerzo→nivel: skill `orchestrate`
  (`~/.claude/skills/orchestrate/SKILL.md`); aplícala al delegar. Si falta,
  aproxima con la Tabla 1; su ausencia nunca bloquea.
- Prompt autocontenido (el subagente no conoce nada visto solo por el
  orquestador) y criterio de aceptación verificable fijado antes de delegar.

### Política de fallos

- Máx 3 intentos por subtarea; cada reintento cambia ≥1 variable (prompt,
  contexto, estrategia, timeout, división, modelo, esfuerzo).
- Timeout transitorio → 1 reintento con más timeout o en background con
  polling; si repite, divide la tarea o escala el modelo.
- Error determinista de entorno (permisos, auth, ruta inválida, herramienta
  ausente, sandbox) → NO repitas sin cambios: corrige la causa o informa.
- No escales el modelo si la causa del fallo no depende de su capacidad.

## Invocación de modelos

- **Claude** → parámetro `model` del agente/workflow.
- **GPT** → mediante codex CLI: skills `codex-*` si existen; si no,
  `codex exec`. Antes de invocarlo lee
  `~/.claude/docs/gpt-5.6-codex-cli.md` (slugs, plantilla no interactiva,
  wrapper para workflows, timeouts, automatización). Dentro de Claude Code
  también valen el plugin (`/codex:review`, `/codex:rescue`).
- **claudex** (GPT motor en harness Claude Code) → solo como
  mini-orquestador subordinado para bloques GPT-pesados; nunca orquestador
  tope. Reglas y límites: `~/.claude/docs/gpt-en-claude-code.md`.
- Codex queda fuera de los presupuestos del workflow (`budget.spent()` solo
  cuenta tokens Claude) pero genera costo monetario real.
- Permisos mínimos por run: read-only para análisis y reviews; `--sandbox
  workspace-write` solo si debe modificar archivos; `danger-full-access`
  NUNCA salvo entorno expresamente aislado + aprobación del usuario.

### Paralelización

- Solo subtareas independientes; nunca trabajo secuencial, cambios
  concurrentes sobre los mismos archivos, ni coordinación que cueste más que
  el ahorro esperado.
- Todo agente que edite en paralelo → `isolation: 'worktree'` obligatorio
  (incluye implementaciones GPT/codex).
- Antes de integrar resultados paralelos: conflictos, supuestos
  incompatibles, duplicación y coherencia.

## Preferencias

- Mucho trabajo de golpe → PARA y dilo claramente antes de empezar; propone
  cómo dividirlo.
- Computer use: delégalo primero a un modelo GPT vía codex. Si codex no
  tiene acceso al desktop o falla por limitación del entorno, informa y pide
  aprobación explícita antes de usarlo directamente — única excepción. Pide
  aprobación también antes de ampliar permisos, acceder a información
  sensible o usar un entorno sin aislamiento; no la re-pidas en reintentos
  que no amplíen el alcance autorizado.
- Cambios al sistema de orquestación (esta política, agentes, skills, docs)
  → openspec change en `~/Documentos/Personal/Orquestrador`; nunca edición
  directa.
- Una instrucción explícita del usuario manda sobre estas tablas.
