#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workflow_bin="$root_dir/.venv/bin/workflow"
if [[ ! -x "$workflow_bin" ]]; then
  echo "Install the engine in $root_dir/.venv as described in README.md" >&2
  exit 2
fi

upstream_ref="$(git -C "$root_dir" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}')"
remote="${upstream_ref%%/*}"
git -C "$root_dir" fetch "$remote"
revision="$(git -C "$root_dir" rev-parse "$upstream_ref")"
git -C "$root_dir" merge-base --is-ancestor HEAD "$revision"

scratch="$(mktemp -d "${TMPDIR:-/tmp}/agentworkflow-sync.XXXXXX")"
staged="$scratch/revision"
cleanup() {
  git -C "$root_dir" worktree remove --force "$staged" >/dev/null 2>&1 || true
  rm -rf "$scratch"
}
trap cleanup EXIT
git -C "$root_dir" worktree add --detach "$staged" "$revision"

shopt -s nullglob
definitions=("$staged"/definitions/*.yaml)
if (( ${#definitions[@]} == 0 )); then
  echo "No YAML definitions found in fetched revision" >&2
  exit 2
fi
for definition in "${definitions[@]}"; do
  "$workflow_bin" validate "$definition"
done

git -C "$root_dir" merge --ff-only "$revision"
