#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "$0")/.." && pwd)"
# The managed cloud home is read-only; keep Godot's local data in writable storage.
case "$project_root" in
  /workspace/*)
    export XDG_DATA_HOME="${XDG_DATA_HOME:-/workspace/.local/share}"
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/workspace/.config}"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/workspace/.cache}"
    mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
    ;;
esac
exec "${GODOT_BIN:-godot}" --path "$project_root" "$@"
