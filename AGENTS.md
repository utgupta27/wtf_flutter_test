# AGENTS.md — Cursor / AI agent entry

This repo is configured for **Claude Code** and **Cursor** with the same project brain.

## Configuration map

| Layer | Path | Purpose |
|-------|------|---------|
| Project instructions | `claude.md`, `CLAUDE.md` | Role, git workflow, linting, dev flow |
| Cursor rules | `.cursor/rules/*.mdc` | Always-on: platform rules + recording |
| Cursor skills | `.cursor/skills/*/SKILL.md` | `grill-me`, `start-dev-flow`, `record-activity` |
| Claude Code skills | `.claude/skills/*/SKILL.md` | Same `grill-me` skill (keep in sync with `.cursor/skills`) |
| Prompt audit (auto) | `PROMPT_LOG.md` | Every user message via `.cursor/hooks/log-user-prompt.sh` |
| Task audit | `AI_LEDGER.md` | Completed work entries |
| Decisions | `MEMORY.md`, `DECISIONS.md`, `ERRORS.md` | Memory and failures |
| Work queue | `BACKLOG.md` | Issue checklist |

## Session checklist

1. Read `claude.md`, `MEMORY.md`, `ERRORS.md`, `BACKLOG.md`.
2. On `/start-dev-flow`, load skill `start-dev-flow`.
3. After completed tasks, use skill `record-activity` or follow `.cursor/rules/project-recording.mdc`.

## Hooks

`beforeSubmitPrompt` → `.cursor/hooks/log-user-prompt.sh` logs to `PROMPT_LOG.md`.

Reload: save `hooks.json` or restart Cursor. Verify in **Settings → Hooks** or the Hooks output channel.
