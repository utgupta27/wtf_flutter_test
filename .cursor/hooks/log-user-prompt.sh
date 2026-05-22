#!/usr/bin/env bash
# Appends every user prompt to PROMPT_LOG.md (project root).
set -euo pipefail

INPUT=$(cat)
LOG_FILE="PROMPT_LOG.md"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

extract_prompt() {
  if command -v jq >/dev/null 2>&1; then
    echo "$INPUT" | jq -r '
      .prompt // .text // .user_message // .content // .message //
      .userPrompt // .user_prompt // empty
    ' 2>/dev/null || true
    return
  fi
  python3 - <<'PY' 2>/dev/null || true
import json, sys
d = json.load(sys.stdin)
for key in ("prompt", "text", "user_message", "content", "message", "userPrompt", "user_prompt"):
    v = d.get(key)
    if isinstance(v, str) and v.strip():
        print(v)
        break
PY
}

PROMPT=$(extract_prompt <<<"$INPUT")
PROMPT=${PROMPT//$'\r'/}

if [[ -z "${PROMPT//[[:space:]]/}" ]]; then
  echo '{}'
  exit 0
fi

if [[ ! -f "$LOG_FILE" ]]; then
  cat >"$LOG_FILE" <<'EOF'
# PROMPT_LOG.md — User Prompt Audit Trail

> Auto-appended by `.cursor/hooks/log-user-prompt.sh` on every user message.

---

EOF
fi

{
  printf '\n## %s\n\n' "$TIMESTAMP"
  printf '%s\n\n' "$PROMPT"
  printf '%s\n' '---'
} >>"$LOG_FILE"

echo '{}'
exit 0
