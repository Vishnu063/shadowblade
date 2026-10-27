#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "$0")/.." && pwd)"
for suite in gameplay journey exploration input_safety campaign powers hero_bosses; do
  "$project_root/tools/godot.sh" --headless --fixed-fps 60 "res://tests/$suite.tscn"
done
