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

### Decision: Cursor mirrors Claude Code project brain
- **Chosen:** `.cursor/rules` (always-on), `.cursor/skills` (grill-me + dev-flow + record-activity), `beforeSubmitPrompt` hook → `PROMPT_LOG.md`, `AGENTS.md` as config map
- **Why:** Same workflows in Cursor as Claude Code; auditable prompt trail without relying on chat history alone
- **Rejected:** Duplicating full `claude.md` into every rule file (pointer + focused recording rule instead)

### Decision: 100ms management JWT must include `jti`
- **What was decided:** `signManagementToken()` signs with `jwtid: uuidv4()` like app tokens.
- **Why:** 100ms Management API rejects management tokens without `jti` (401 `null jti`); room creation then fell back to fake `room-<id>` and SDK init failed with 401.
- **What was rejected:** Changing only Flutter join flow — root cause was server-side room creation.

---
### Decision: 100ms video requires manifest + HMSVideoView (not placeholders)
- **What was decided:** Declare `CAMERA`/`RECORD_AUDIO` (and related) in Android/iOS manifests; request via `permission_handler` before join; render tracks with `HMSVideoView` driven by `tracksUpdated` events from `HmsVideoCallService`.
- **Why:** In-call UI was avatar placeholders only — SDK was joining but no video surfaces or permission prompts existed.
- **What was rejected:** Relying on HMS SDK internal permission handling alone (still need manifest entries; explicit request gives clearer errors).

---

_Append new decisions below after each session._
