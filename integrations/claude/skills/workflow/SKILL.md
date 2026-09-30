---
name: workflow
description: Handle queued claude-host tasks for this example workflow. Use when asked to process the next Claude task or inspect a workflow run.
---

# Claude workflow host

Find this example repository's absolute path. Use its `scripts/claude-host.sh` so the task uses the same target project and SQLite database as the Slack worker.

When asked to take the next task, run `scripts/claude-host.sh next`. It claims one `claude-host` task and returns JSON containing `token_id`, `instructions`, `inputs`, `outputs`, `workdir`, and allowed `outcomes`. `null` means there is no queued task. Do not claim a second task while handling one.

Perform the instructions in the returned `workdir`. Review the inputs and previous outputs. Write a concise factual result to a UTF-8 file outside the target Git checkout, then run `scripts/claude-host.sh complete TOKEN_ID OUTCOME OUTPUT_FILE` with a listed outcome. Use `scripts/claude-host.sh heartbeat TOKEN_ID` periodically for work approaching two hours. Use `scripts/claude-host.sh status RUN_ID` to inspect progress.

If the task is interrupted and its effects are uncertain, tell the user what changed before reporting an outcome. An expired lease needs an explicit `scripts/claude-host.sh resume RUN_ID` before another claim.
