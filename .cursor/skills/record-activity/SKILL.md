---
name: record-activity
description: Append structured entries to PROMPT_LOG, AI_LEDGER, MEMORY, BACKLOG, ERRORS, and README per project standards. Use after completing work or when the user asks to log or record activity.
---

# Record activity

Update project docs in this order:

1. **PROMPT_LOG.md** — User's exact prompt (if not already logged by hook).
2. **AI_LEDGER.md** — New `## Entry NNN` block with Prompt/Intent, Tool, Output Summary, Files Modified, Commit.
3. **BACKLOG.md** — `[x]` only when the issue is actually complete and approved if review gate applied.
4. **MEMORY.md** — Any significant decision from this session.
5. **ERRORS.md** — Only if something failed twice before succeeding.
6. **README.md** — Only if setup, docs index, or branch strategy changed.

Use the table format already in `AI_LEDGER.md`. Increment entry numbers sequentially.
