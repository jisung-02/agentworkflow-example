#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$root_dir/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$root_dir/.env"
  set +a
fi
project_dir="${WORKFLOW_PROJECT_DIR:?Set WORKFLOW_PROJECT_DIR to the target Git repository}"
project_dir="$(cd "$project_dir" && pwd)"
database="${WORKFLOW_DB:-$project_dir/.workflow/state.db}"
workflow_bin="$root_dir/.venv/bin/workflow"

if [[ -z "${WORKFLOW_ALLOWED_ACTORS:-}" ]] || \
   [[ -z "${WORKFLOW_SLACK_SIGNING_SECRET:-}" ]] || \
   [[ -z "${WORKFLOW_SLACK_BOT_TOKEN:-}" ]] || \
   [[ "${WORKFLOW_ALLOWED_ACTORS:-}" == *U0123456789* ]] || \
   [[ "${WORKFLOW_SLACK_SIGNING_SECRET:-}" == replace-* ]] || \
   [[ "${WORKFLOW_SLACK_BOT_TOKEN:-}" == xoxb-replace-* ]]; then
  echo "Fill in Slack values in $root_dir/.env before starting" >&2
  exit 2
fi

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
