---
name: start-dev-flow
description: Execute the next open BACKLOG.md issue through code, test, human review gate, commit, PR, and ledger update. Use when the user sends /start-dev-flow.
---

# Autonomous dev flow

Execute the **next uncompleted** item in `BACKLOG.md`. Do not skip phases.

## Phase 1 — Code & test

1. Read the next `[ ]` issue in `BACKLOG.md`.
2. Checkout the app branch (`guru` / `trainer` / `node-server`) and create `feat/<app>/<name>`.
3. Write tests, then implementation.
4. Run `flutter analyze` + `flutter test` (or `npm run lint` for Node).
5. Loop until green.

## Phase 2 — Human review gate

6. **STOP.** Do not commit. Do not update `AI_LEDGER.md` or check off backlog.
7. Summarize changes and ask: *"Ready for review. Do you approve, or are there changes needed?"*
8. Wait. On changes → Phase 1. On approval → Phase 3.

## Phase 3 — Finalize

9. Commit (Conventional Commits, scope `guru` | `trainer` | `node` | `shared`).
10. Push and open PR to the app branch (not `main` / `staging` without approval).
11. Update `AI_LEDGER.md` and mark `[x]` in `BACKLOG.md`.
12. Start Phase 1 for the next open issue unless the user stops you.
