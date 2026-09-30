#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
if [[ -f "$root_dir/.env" ]]; then
  # shellcheck disable=SC1091
  source "$root_dir/.env"
fi

project_dir="${WORKFLOW_PROJECT_DIR:?Set WORKFLOW_PROJECT_DIR in $root_dir/.env}"
project_dir="$(cd "$project_dir" && pwd -P)"
exec claude --plugin-dir "$root_dir/integrations/claude" --add-dir "$project_dir" "$@"
