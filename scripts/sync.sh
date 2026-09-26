#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
git -C "$root_dir" pull --ff-only

workflow_bin="$root_dir/.venv/bin/workflow"
if [[ ! -x "$workflow_bin" ]]; then
  echo "Install the engine in $root_dir/.venv as described in README.md" >&2
  exit 2
fi

for definition in "$root_dir"/definitions/*.yaml; do
  "$workflow_bin" validate "$definition"
done
