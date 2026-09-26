#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$root_dir/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$root_dir/.env"
  set +a
fi

project_dir="${WORKFLOW_PROJECT_DIR:?Set WORKFLOW_PROJECT_DIR in .env}"
if [[ ! -d "$project_dir" ]]; then
  echo "Set WORKFLOW_PROJECT_DIR to an existing target Git repository in $root_dir/.env" >&2
  exit 2
fi
project_dir="$(cd "$project_dir" && pwd)"
database="${WORKFLOW_DB:-$project_dir/.workflow/state.db}"
workflow_bin="$root_dir/.venv/bin/workflow"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 RUN_ID" >&2
  exit 2
fi

exec "$workflow_bin" --db "$database" --workdir "$project_dir" status "$1"
