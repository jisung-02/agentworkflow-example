#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
if [[ -f "$root_dir/.env" ]]; then
  # shellcheck disable=SC1091
  source "$root_dir/.env"
fi

project_dir="${WORKFLOW_PROJECT_DIR:?Set WORKFLOW_PROJECT_DIR in $root_dir/.env}"
project_dir="$(cd "$project_dir" && pwd -P)"
workflow_bin="$root_dir/.venv/bin/workflow"
database="${WORKFLOW_DB:-$project_dir/.workflow/state.db}"

if [[ ! -x "$workflow_bin" ]]; then
  echo "Install the engine in $root_dir/.venv as described in README.md" >&2
  exit 2
fi

case "${1:-}" in
  next)
    [[ $# -eq 1 ]] || { echo "Usage: $0 next" >&2; exit 2; }
    exec "$workflow_bin" --db "$database" --workdir "$project_dir" \
      host-next --runner claude-host
    ;;
  complete)
    [[ $# -eq 4 ]] || { echo "Usage: $0 complete TOKEN_ID OUTCOME OUTPUT_FILE" >&2; exit 2; }
    exec "$workflow_bin" --db "$database" --workdir "$project_dir" \
      host-complete "$2" "$3" --output-file "$4"
    ;;
  heartbeat)
    [[ $# -eq 2 ]] || { echo "Usage: $0 heartbeat TOKEN_ID" >&2; exit 2; }
    exec "$workflow_bin" --db "$database" --workdir "$project_dir" host-heartbeat "$2"
    ;;
  status)
    [[ $# -eq 2 ]] || { echo "Usage: $0 status RUN_ID" >&2; exit 2; }
    exec "$workflow_bin" --db "$database" --workdir "$project_dir" status "$2"
    ;;
  resume)
    [[ $# -eq 2 ]] || { echo "Usage: $0 resume RUN_ID" >&2; exit 2; }
    exec "$workflow_bin" --db "$database" --workdir "$project_dir" resume "$2"
    ;;
  *)
    echo "Usage: $0 next|complete TOKEN_ID OUTCOME OUTPUT_FILE|heartbeat TOKEN_ID|status RUN_ID|resume RUN_ID" >&2
    exit 2
    ;;
esac
