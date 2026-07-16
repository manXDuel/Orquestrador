# Cómo funcionan los modelos GPT-5.6 en Codex CLI

Referencia completa de la familia GPT-5.6. La política de uso (cuándo GPT,
permisos por run) vive en `~/.claude/CLAUDE.md`; este archivo cubre todo lo
operacional: variantes, invocación, plantilla `codex exec`, wrapper para
workflows, config, reasoning y notas prácticas.

La familia **GPT-5.6** introduce un esquema de nombres distinto y está
totalmente integrada en Codex CLI. En lugar de un solo modelo "5.6", hay
tres variantes especializadas + un alias.

## Variantes de GPT-5.6

| Modelo / Alias      | Rol principal                              | Cuándo usarlo |
|---------------------|--------------------------------------------|---------------|
| `gpt-5.6` (alias)   | Apunta automáticamente a `gpt-5.6-sol`     | Uso general / default recomendado |
| `gpt-5.6-sol`       | Flagship. Máxima capacidad y detalle       | Tareas complejas, open-ended, cambios de código difíciles, investigación profunda, documentos finos |
| `gpt-5.6-terra`     | Balance inteligencia / precio (workhorse)  | Trabajo diario, strong reasoning + tools (reemplazo natural de lo que antes hacía 5.5) |
| `gpt-5.6-luna`      | Rápido y eficiente (alto volumen)          | Tareas claras y repetibles: extracción, clasificación, transformaciones, resúmenes estructurados, subagentes |

**Default actual en Codex**: el "Power setting", que usa `gpt-5.6-sol` con
reasoning `medium`.

## Cómo invocarlos en Codex CLI

Exactamente igual que con las versiones anteriores (la mecánica no cambia):

**1. Desde la terminal al lanzar:**
```bash
codex --model gpt-5.6 "Refactor the auth module"
codex -m gpt-5.6-sol "Deep analysis of this architecture"
codex -m gpt-5.6-terra "Implement the feature from the ticket"
codex -m gpt-5.6-luna "Extract all TODOs and generate a report"

# Con config inline
codex -c model="gpt-5.6-luna" "Quick scan of the repo"
```

**2. Dentro de la sesión interactiva (TUI):**
- Escribe `/model` → pestaña/selector de modelos.
- Elige `gpt-5.6`, `gpt-5.6-sol`, `gpt-5.6-terra` o `gpt-5.6-luna`.
- El cambio aplica a los siguientes turnos **sin perder el historial**.

**3. Configuración permanente (`~/.codex/config.toml` o `.codex/config.toml` del proyecto):**
```toml
model = "gpt-5.6"                   # o "gpt-5.6-sol", "gpt-5.6-terra", "gpt-5.6-luna"
model_reasoning_effort = "medium"   # none | low | medium | high | xhigh | max
```

Con profiles (recomendado). Desde codex-cli 0.144.x (`CONFIG_PROFILE_V2`)
cada perfil es un **archivo separado** `$CODEX_HOME/<nombre>.config.toml`
que se superpone a la config base; la sintaxis vieja `[profiles.*]` dentro
de `config.toml` ya NO se carga:

```toml
# ~/.codex/sol.config.toml
model = "gpt-5.6-sol"
model_reasoning_effort = "high"
```
```toml
# ~/.codex/terra.config.toml
model = "gpt-5.6-terra"
model_reasoning_effort = "medium"
```
```toml
# ~/.codex/luna.config.toml
model = "gpt-5.6-luna"
model_reasoning_effort = "low"
```

Luego:
```bash
codex --profile sol "Hard task..."
codex --profile luna "Batch transform..."
```

## Plantilla no interactiva (desde Claude Code)

```bash
codex exec -m <slug> -c model_reasoning_effort="<none|low|medium|high|xhigh|max>" "..."
```

Default: sol + medium. Así se materializan los tiers de esfuerzo de la
escala de `orchestrate`. El prompt debe ser autocontenido.

## Wrapper GPT en workflows/subagentes

El parámetro `model` de los agentes solo acepta modelos Claude. Para usar
GPT dentro de un workflow: agente fino `model: 'sonnet', effort: 'low'` cuyo
prompt le instruye a redactar un prompt autocontenido para codex, correr
`codex exec` vía Bash y devolver el reporte. Label SIEMPRE con prefijo
`gpt-5.6:` (p.ej. `{label: 'gpt-5.6:review-auth'}`) — la UI muestra el
modelo Claude del wrapper; el label es la única señal del worker real. Usa
`schema`/salida estructurada cuando otro agente consuma el resultado.

## Timeouts y automatización

- Runs largos pueden exceder el timeout de 10 min de Bash: pasa un timeout
  explícito o córrelo en background con polling del reporte.
- Para automatización prefiere `--output-schema` y captura el resultado con
  `--output-last-message`; usa `--json` para observar eventos o diagnosticar
  fallos.

## Novedades importantes de reasoning en 5.6

GPT-5.6 soporta más niveles de **reasoning effort**:
`none` · `low` · `medium` · `high` · `xhigh` · **`max`**

Recomendaciones de migración (desde 5.4 / 5.5):
1. Empieza con el mismo effort que usabas.
2. Prueba **un nivel más bajo** (suelen dar resultados parecidos con menos
   tokens/latencia).
3. Usa `medium` como baseline equilibrado.
4. Reserva `high` / `xhigh` / `max` solo para los problemas más duros.

También hay:
- **Pro mode**: no cambia el slug del modelo; se activa con
  `reasoning.mode = "pro"` (en la Responses API). En CLI normalmente se
  controla desde el selector o config avanzada.
- **Ultra / Max**: para problemas muy difíciles (Max = más tiempo de
  reasoning en un solo agente; Ultra = subagentes en paralelo).

## Precedencia (igual que antes)

1. Comando mid-session (`/model`)
2. Flags CLI (`-m`, `-c model=...`)
3. Config del proyecto
4. Config de usuario (`~/.codex/config.toml`)
5. Defaults de OpenAI (actualmente `gpt-5.6-sol` medium)

## Notas prácticas

- **Actualiza Codex CLI** a la última versión para ver bien los nuevos slugs
  en el picker y evitar errores de metadata.
- Auth con **ChatGPT login** suele dar acceso más rápido a los modelos más
  nuevos que solo API key.
- Modelos antiguos como `gpt-5.2` / `gpt-5.3-codex` están **deprecated** en
  sesiones con ChatGPT sign-in; cámbialos a la familia 5.6.
- Si usas Azure / Bedrock / providers custom, a veces hace falta un catalog
  override (hay issues abiertos de "responses lite" y namespace
  `collaboration` con Sol/Terra). Con el provider oficial de OpenAI suele
  funcionar out-of-the-box.
- Puedes migrar un proyecto entero con el skill de docs:
  ```text
  $openai-docs migrate this project to the GPT-5.6 model family
  ```

## Resumen rápido de recomendación de uso

| Tipo de trabajo                        | Modelo recomendado   | Effort típico |
|----------------------------------------|----------------------|---------------|
| Default / trabajo diario fuerte        | `gpt-5.6` o `-sol`   | medium        |
| Coding complejo / arquitectura         | `gpt-5.6-sol`        | high / xhigh  |
| Tareas cotidianas con buen balance     | `gpt-5.6-terra`      | medium / low  |
| Subagentes, batch, tareas repetibles   | `gpt-5.6-luna`       | low / none    |
| Problemas "casi imposibles"            | `gpt-5.6-sol` + max  | max           |
