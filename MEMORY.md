# MEMORY.md — WTF Platform Decision Log

## Session 1 — 2026-05-22

### Decision: State Management → Riverpod
- **Chosen:** flutter_riverpod ^2.6.1 + riverpod_annotation (code-gen)
- **Why:** Best fit for complex async state across chat, calls, and session logs. Code-gen reduces boilerplate. Supports dependency injection cleanly.
- **Rejected:** Bloc (too verbose for 6h timebox), Provider (not scalable for this scope)

### Decision: Local Storage → Hive
- **Chosen:** hive_flutter ^1.1.0
- **Why:** Lightweight, no native dependencies, fast for local-first. Works on Android without setup overhead.
- **Rejected:** SQLite (more setup, overkill for this data shape), Firebase (cloud = violates local-first rule)

### Decision: Navigation → go_router
- **Chosen:** go_router ^14.8.1
- **Why:** Declarative, URL-based, supports deep linking for in-call screens. Works well with Riverpod.

### Decision: Git Branch Strategy
- `main` = human-only, never touched by AI
- `staging` = integration branch, features land here after human approval
- `guru`, `trainer`, `node-server` = per-app integration branches
- Feature branches: `feat/guru/<name>`, `feat/trainer/<name>`, `feat/node/<name>`

### Decision: Token Server → Node.js (Express + jsonwebtoken)
- **Why:** Fastest to implement. 100ms JWT format is well-documented. Node is in the approved stack.

---
_Append new decisions below after each session._
