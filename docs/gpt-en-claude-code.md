# GPT-5.6 dentro de Claude Code (suscripción ChatGPT)

Complementa `gpt-5.6-codex-cli.md` (codex CLI directo). Este archivo cubre
las dos vías para usar tu suscripción ChatGPT *dentro* de Claude Code.
Investigación de fondo: `~/investigacion-otros-modelos-claude-code.md` §6b.

Formato dual: **Parte 1** referencia compacta (consulta diaria);
**Parte 2** tutorial paso a paso por fases (aprendizaje).

---

# Parte 1 — Referencia

## Chuleta de decisión

| Situación | Vía |
|---|---|
| Segunda opinión / review puntual sin cambiar de sesión | Método 1: `/codex:review` |
| Delegar tarea acotada a GPT desde sesión Claude | Método 1: `/codex:rescue` |
| Trabajo pesado mecánico con spec clara (política CLAUDE.md) | codex CLI directo (`codex exec`, ver doc hermano) |
| Sesión entera con GPT-5.6 como motor, harness Claude Code | Método 2: `claudex` |
| Todo lo demás | `claude` normal (suscripción claude.ai) |

Regla mental: Método 1 = GPT como **ayudante** (Claude sigue siendo el
motor). Método 2 = GPT como **motor** (Claude Code es solo la interfaz).
No existe vía sin proxy para el método 2: `CLAUDE_CODE_SUBAGENT_MODEL` por
sí solo no enruta nada fuera del endpoint configurado.

## Estado verificado del entorno (2026-07-15)

| Componente | Estado |
|---|---|
| Plugin `openai-codex` | 1.0.6 instalado |
| Codex CLI | 0.144.4, advanced runtime |
| Auth | ChatGPT login activo (manxduelyt@gmail.com) |
| Review gate | Apagado (correcto: encendido consume cuota en cada stop) |
| Perfiles codex | `~/.codex/sol.config.toml` creado; terra/luna pendientes (ejercicio F1d) |
| Proxy claudex | NO instalado (Fase 2 pendiente) |

Perfiles: desde codex-cli 0.144.x son archivos separados
`~/.codex/<nombre>.config.toml`, NO bloques `[profiles.*]` — detalle en
`gpt-5.6-codex-cli.md`.

## Método 1 — Plugin oficial de OpenAI (soportado)

Comandos:

- `/codex:review` — review del diff actual. `/codex:adversarial-review`
  para caza agresiva de bugs y cuestionamiento de diseño (acepta texto de
  foco extra).
- `/codex:rescue <tarea>` — delega implementación/diagnóstico a Codex.
- `/codex:transfer` — pasa el contexto de la sesión a Codex.
- `/codex:status`, `/codex:result`, `/codex:cancel` — gestión.
- `/codex:setup` — diagnóstico; `--enable/--disable-review-gate`.

Flags en review/rescue: `--model gpt-5.6-sol|terra|luna`,
`--effort low|medium|high`, `--background`, `--base main`.

Requisito: **cwd debe ser repo git con cambios** — el review opera sobre
working tree diff. Facturación contra cuota ChatGPT; sol a effort alto
quema un plan Pro rápido — default terra/medium.

## Método 2 — claudex: GPT-5.6 como motor (gris tolerado)

Flujo: `claude` (harness) → proxy local [raine/claude-code-proxy](https://github.com/raine/claude-code-proxy)
→ `chatgpt.com/backend-api/codex` con tu OAuth de ChatGPT. Avalado
públicamente por el jefe de producto de OpenAI; no sancionado formalmente
por Anthropic. Hallazgo de Theo: el mismo modelo rinde mejor en el harness
de Claude Code que en Codex. Setup completo: Fase 2 del tutorial.

### Elección de proxy

| | raine/claude-code-proxy (default de esta guía) | CLIProxyAPI (router-for-me) |
|---|---|---|
| Backends | Solo ChatGPT (+ Kimi/Grok/Cursor) | Claude + Codex simultáneos |
| Cambio de motor | Cambiar de sesión (`claude` ↔ `claudex`) | Mid-session con `/model` (fable/opus ↔ gpt-5.6-*) |
| Picker | — | `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` (CC ≥ 2.1.129) |
| Riesgo | Solo OAuth ChatGPT en el proxy | Doble credencial (OAuth claude.ai también) + zona gris ToS con Anthropic + facturación mixta por sesión |
| Puerto | 18765 | 8317 |

Con CLIProxyAPI la mini-orquestación puede usar tiers reales de la Tabla 1
(subagentes Claude Y GPT). Empezar con raine (menor riesgo); migrar a
CLIProxyAPI solo si el cambio mid-session justifica exponer la segunda
credencial (experimento F2f).

### claudex y la política de orquestación (anexo a CLAUDE.md v1.3)

- claudex actúa SOLO como **mini-orquestador subordinado** para bloques
  GPT-pesados (mecánica, spec clara, creatividad baja). La sesión Fable
  normal sigue siendo orquestador tope — regla v1.3: el más capaz orquesta
  (Sol Intel 8 < Fable 9).
- Dentro de claudex: subagentes vía Agent tool van al mismo proxy (GPT);
  el plugin/CLI de codex sigue disponible (misma cuota). Contenido visible
  a usuarios (Gusto ≥ 7) se delega fuera o se marca para revisión en
  sesión Claude.
- Cuota: en claudex TODO factura contra ChatGPT, subagentes incluidos;
  `budget.spent()` de workflows no lo refleja.
- Vía de vuelta a Claude desde claudex (NO verificado — experimento F2e):
  ```bash
  env -u ANTHROPIC_BASE_URL -u ANTHROPIC_AUTH_TOKEN -u ANTHROPIC_MODEL \
      -u ANTHROPIC_SMALL_FAST_MODEL -u CLAUDE_CODE_SUBAGENT_MODEL \
      claude -p "..."
  ```
- Diferenciación de tiers de subagentes bajo el proxy: NO verificada
  (experimento F2d decide si hay tiers o modelo único).

## Riesgos y límites

- **ToS gris** (método 2): usa auth de suscripción de chat fuera de su app
  oficial. Difundido por OpenAI, pero sin garantía formal.
- **Degradación agéntica**: harness afinado para Claude; con GPT pueden
  fallar tool-calls multi-paso complejos. Errores 400 por campos
  experimentales → `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`.
- **Cuota**: todo factura contra el plan ChatGPT. Sol effort alto = quema
  rápida (comprobado en F1a).
- **Features perdidas** con base URL custom: Remote Control, dictado por voz.
- **Supply chain**: proxy maneja tu OAuth. Solo binarios de release con
  versión fijada y checksum verificado; nunca `curl | bash` (en marzo 2026
  un proxy popular fue comprometido con malware roba-credenciales).

## Ejercicios (estado)

- [x] F1a: `/codex:review` + `/codex:adversarial-review` — completado
      2026-07-15 (3 findings válidos aplicados a estos docs).
- [ ] F1b: `/codex:rescue` con `--model gpt-5.6-terra --effort medium`.
- [ ] F1c: rescue con `--background` + `/codex:result`.
- [ ] F1d: crear `~/.codex/terra.config.toml` y `luna.config.toml`.
- [ ] F2a: instalar proxy (versión fijada + checksum), auth, serve.
- [ ] F2b: crear `claudex.fish`, verificar `/status` en ambos modos.
- [ ] F2c: misma tarea pequeña en `claude` y `claudex`, comparar.
- [ ] F2d: subagente con `model: sonnet` dentro de claudex — ¿el proxy
      traduce, ignora o falla?
- [ ] F2e: `claude -p` anidado con env limpiado desde claudex — ¿responde
      Claude y factura a claude.ai?
- [ ] F2f (opcional): CLIProxyAPI con doble auth — `/model` mid-session
      entre familias.
- [ ] F3: integrar chuleta y anexo claudex en política de CLAUDE.md.

---

# Parte 2 — Tutorial paso a paso

## Fase 0 — Fundamentos (~15 min)

Claude Code habla el formato Anthropic Messages API. Dos variables lo
redirigen:

```bash
ANTHROPIC_BASE_URL=...    # a dónde van las requests
ANTHROPIC_AUTH_TOKEN=...  # credencial para ese endpoint
```

Mientras estén activas, tu suscripción claude.ai NO se usa. Sin ellas,
`claude` usa tu login OAuth normal. De ahí las dos vías:

1. **Plugin** (ayudante): tu sesión sigue en Claude; comandos `/codex:*`
   invocan GPT puntualmente vía Codex CLI.
2. **claudex** (motor): base URL apunta a un proxy local que traduce al
   backend de ChatGPT; toda la sesión piensa con GPT-5.6.

**Checkpoint F0**: explica con tus palabras cuándo usarías plugin vs
claudex vs `codex exec` directo. (Respuesta esperada: chuleta de Parte 1.)

## Fase 1 — Plugin Codex

### F1a — Review ✅ (completado 2026-07-15)

Pasos que se siguieron, reproducibles:

1. Estar en repo git con cambios sin commitear (working tree diff).
   - Lección aprendida: en `~` (no-repo) falla con
     `fatal: no es un repositorio git`. Para revisar archivos sueltos:
     repo scratch temporal, copia los archivos, review ahí.
2. `/codex:review` — review estándar del diff. O
   `/codex:adversarial-review --model gpt-5.6-sol --effort high <foco>`
   para cuestionar diseño/supuestos.
3. Elegir background si es más que 1-2 archivos; consultar progreso con
   `/codex:status`, resultado con `/codex:result`.
4. Output esperado: `Verdict: needs-attention|approved` + findings con
   severidad, archivo:línea y recomendación.
5. Reevalúa cada finding antes de aplicarlo — en F1a fueron 3/3 válidos,
   pero uno requirió verificación empírica contra el CLI local.

Troubleshooting:
- `no es un repositorio git` → paso 1.
- Review eterno → `/codex:status`; cancela con `/codex:cancel`.
- Cuota agotada rápido → baja a terra/medium; adversarial sol/high solo
  cuando el resultado lo justifique.

### F1b — Rescue (pendiente)

1. En un repo real, elige tarea acotada con criterio de éxito claro
   (bug con reproducción, función pequeña, refactor puntual).
2. Corre:
   ```
   /codex:rescue --model gpt-5.6-terra --effort medium <descripción de la tarea>
   ```
3. Output esperado: Codex trabaja en el repo y reporta diff/resultado.
4. Revisa el diff antes de aceptar (mismo estándar que con cualquier
   subagente).

**Checkpoint F1b**: tarea completada por Codex, diff revisado por ti.

### F1c — Background (pendiente)

1. Igual que F1b pero añade `--background`.
2. Sigue trabajando en tu sesión; `/codex:status` para progreso,
   `/codex:result` cuando termine.

**Checkpoint F1c**: recuperaste un resultado con `/codex:result` sin haber
bloqueado la sesión.

### F1d — Perfiles (pendiente, ejercicio tuyo)

Crea `~/.codex/terra.config.toml` y `~/.codex/luna.config.toml` siguiendo
la plantilla de `sol.config.toml` (ya existe):

```toml
# ~/.codex/terra.config.toml
model = "gpt-5.6-terra"
model_reasoning_effort = "medium"
```

Verifica: `codex --profile terra debug prompt-input` corre sin error.
Detalle de perfiles v2: `gpt-5.6-codex-cli.md`.

## Fase 2 — claudex (pendiente)

### F2a — Instalar proxy, auth, serve

Solo binario de release con versión fijada y checksum verificado — el
proxy maneja tu OAuth de ChatGPT; nunca instalador remoto mutable
(`curl | bash`):

```bash
# 1. Descarga tarball + checksum de la release fijada (v0.1.21, jul 2026)
#    https://github.com/raine/claude-code-proxy/releases/tag/v0.1.21
# 2. Verifica ANTES de extraer:
sha256sum -c claude-code-proxy-*.sha256
# 3. Extrae el binario a ~/.local/bin/
```

Luego:

```bash
claude-code-proxy codex auth login   # OAuth navegador con cuenta ChatGPT
claude-code-proxy serve              # escucha en 127.0.0.1:18765
```

El proxy debe estar corriendo mientras uses `claudex` (terminal aparte, o
servicio de usuario systemd si se vuelve costumbre).

**Checkpoint F2a**: `curl -s http://localhost:18765` responde (proxy vivo).

### F2b — Función fish

`~/.config/fish/functions/claudex.fish` — deja `claude` normal intacto;
las variables solo viven dentro de la invocación:

```fish
function claudex --description "Claude Code con GPT-5.6 como motor (claude-code-proxy)"
    env ANTHROPIC_BASE_URL=http://localhost:18765 \
        ANTHROPIC_AUTH_TOKEN=unused \
        ANTHROPIC_MODEL='gpt-5.6-sol[1m]' \
        ANTHROPIC_SMALL_FAST_MODEL='gpt-5.6-luna[1m]' \
        CLAUDE_CODE_SUBAGENT_MODEL=gpt-5.6-sol \
        CLAUDE_CODE_AUTO_COMPACT_WINDOW=372000 \
        CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1 \
        CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=3 \
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
        CLAUDE_CODE_DISABLE_NONSTREAMING_FALLBACK=1 \
        ENABLE_TOOL_SEARCH=false \
        claude --model gpt-5.6-sol $argv
end
```

Nota: `CLAUDE_CODE_SUBAGENT_MODEL` aquí SÍ funciona porque la base URL ya
apunta al proxy. Suelto, sin base URL, no enruta nada (finding del review
2026-07-15).

Verificación:

1. `claudex` en un repo → `/status` debe mostrar
   `Anthropic base URL: http://localhost:18765`.
2. Tarea de prueba real (leer + editar un archivo).
3. En otra terminal, `claude` normal → `/status` SIN base URL custom
   (sigue en suscripción claude.ai).

**Checkpoint F2b**: ambos `/status` correctos.

Troubleshooting:
- Errores 400 → `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` dentro de la
  función.
- `connection refused` → proxy no está corriendo (F2a).
- Puerto ocupado → `PORT=11435 claude-code-proxy serve` y ajusta la
  función.

### F2c — Comparar

Misma tarea pequeña en `claude` y `claudex`; compara calidad, latencia y
manejo de tools. **Checkpoint F2c**: conclusión propia de cuándo te
compensa claudex.

### F2d — ¿Tiers de subagentes bajo el proxy? (experimento)

1. Dentro de `claudex`, pide una tarea trivial delegada a un subagente con
   `model: sonnet` (p.ej. agente `explorer-lite`).
2. Observa: ¿el proxy traduce el slug Claude a un modelo GPT, lo ignora
   (usa `CLAUDE_CODE_SUBAGENT_MODEL`) o devuelve error?
3. Anota el resultado en esta guía.

**Checkpoint F2d**: sabes si la escala orchestrate aplica con tiers
diferenciados o con modelo único dentro de claudex.

### F2e — Volver a Claude desde claudex (experimento)

1. Dentro de `claudex`, corre:
   ```bash
   env -u ANTHROPIC_BASE_URL -u ANTHROPIC_AUTH_TOKEN -u ANTHROPIC_MODEL \
       -u ANTHROPIC_SMALL_FAST_MODEL -u CLAUDE_CODE_SUBAGENT_MODEL \
       claude -p "¿Qué modelo eres?"
   ```
2. Esperado: responde un modelo Claude (OAuth claude.ai), no GPT.

**Checkpoint F2e**: confirmado que claudex puede delegar a Claude por
subproceso — espejo del patrón `codex exec`.

### F2f — CLIProxyAPI: cambio de modelo mid-session (opcional)

Solo si el cambio `/model` entre familias en una misma sesión te compensa
exponer también el OAuth de claude.ai al proxy.

1. Instala [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI)
   (release fijada + checksum, mismo estándar que F2a). Puerto 8317.
2. Autentica ambos: cuenta ChatGPT y cuenta Claude.
3. Variante de la función fish apuntando a `http://localhost:8317` +
   `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`.
4. En sesión: `/model` debe listar ambas familias; alterna fable ↔
   gpt-5.6-sol y verifica en `/status` qué cuota factura cada turno.

**Checkpoint F2f**: cambio mid-session funcionando y facturación de cada
familia identificada.

### Volver a Claude normal

Nada que deshacer: usa `claude`. Las variables solo existen dentro de
`claudex`. Para retirar el método: borra la función y el binario del proxy.

## Fase 3 — Integración con política CLAUDE.md (pendiente)

1. Texto propuesto para la sección "Invocación de modelos" de
   `~/.claude/CLAUDE.md` (pendiente de tu aprobación explícita del texto —
   edición bloqueada por permisos 2026-07-15):

   ```
   - **GPT dentro de Claude Code** → review/tarea puntual: plugin
     (`/codex:review`, `/codex:rescue`). **claudex** (GPT motor en
     harness Claude Code) → solo como mini-orquestador subordinado para
     bloques GPT-pesados; nunca orquestador tope. Reglas y límites:
     ~/.claude/docs/gpt-en-claude-code.md.
   ```

2. Actualizar memoria persistente con el estado final.

**Checkpoint F3**: chuleta integrada; cualquier sesión futura sabe elegir
vía sin releer la investigación.
