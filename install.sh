#!/usr/bin/env bash
# Instala el sistema Orquestrador: symlinks desde ~/.claude/ hacia este repo.
# Idempotente. Destino con contenido distinto => aborta con diff, no toca nada.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE="$HOME/.claude"

# pares "origen_relativo_al_repo:destino_relativo_a_~/.claude"
LINKS=(
  "core/CLAUDE.md:CLAUDE.md"
  "skills/orchestrate:skills/orchestrate"
  "docs/gpt-5.6-codex-cli.md:docs/gpt-5.6-codex-cli.md"
  "docs/gpt-en-claude-code.md:docs/gpt-en-claude-code.md"
  "agents/scout.md:agents/scout.md"
  "agents/explorer-lite.md:agents/explorer-lite.md"
  "agents/builder.md:agents/builder.md"
  "agents/reviewer.md:agents/reviewer.md"
  "agents/sub-orchestrator.md:agents/sub-orchestrator.md"
)

# Fase 1: validar todo antes de tocar nada
for pair in "${LINKS[@]}"; do
  src="$REPO/${pair%%:*}"
  dst="$CLAUDE/${pair##*:}"
  [ -e "$src" ] || { echo "ERROR: falta en el repo: $src" >&2; exit 1; }
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    if ! diff -rq "$dst" "$src" >/dev/null; then
      echo "ERROR: $dst difiere del repo. No se tocó nada. Diff:" >&2
      diff -ru "$dst" "$src" >&2 || true
      exit 1
    fi
  elif [ -L "$dst" ] && [ "$(readlink -f "$dst")" != "$(readlink -f "$src")" ]; then
    echo "ERROR: $dst es symlink a otro destino: $(readlink "$dst"). No se tocó nada." >&2
    exit 1
  fi
done

# Fase 2: crear symlinks
for pair in "${LINKS[@]}"; do
  src="$REPO/${pair%%:*}"
  dst="$CLAUDE/${pair##*:}"
  mkdir -p "$(dirname "$dst")"
  [ -L "$dst" ] && continue          # ya instalado
  rm -rf "$dst"                       # contenido idéntico, validado en fase 1
  ln -s "$src" "$dst"
  echo "link: $dst -> $src"
done

echo "OK: sistema instalado desde $REPO"
