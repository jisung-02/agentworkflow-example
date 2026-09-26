#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
project_dir="${WORKFLOW_PROJECT_DIR:?Set WORKFLOW_PROJECT_DIR to the target Git repository}"
project_dir="$(cd "$project_dir" && pwd)"
database="${WORKFLOW_DB:-$project_dir/.workflow/state.db}"
workflow_bin="$root_dir/.venv/bin/workflow"

if [[ ! -x "$workflow_bin" ]]; then
  echo "Install the engine in $root_dir/.venv as described in README.md" >&2
  exit 2
fi

case "${1:-}" in
  http)
    exec "$workflow_bin" --db "$database" --workdir "$project_dir" \
      serve-http --definitions "$root_dir/definitions" --host 127.0.0.1 --port 8080
    ;;
  worker)
    exec "$workflow_bin" --db "$database" --workdir "$project_dir" serve --interval 10
    ;;
  *)
    echo "Usage: $0 http|worker" >&2
    exit 2
    ;;
esac
