# DECISIONS.md — Architecture Decision Records

Lightweight ADRs for the WTF Platform monorepo. `MEMORY.md` holds session notes; this file is the canonical decision log for reviewers and future agents.

---

## ADR-001: State Management → Riverpod

- **Status:** Accepted
- **Decision:** Use `flutter_riverpod` ^2.6.1 with `riverpod_annotation` for code generation.
- **Rationale:** Best async state handling for chat + call flows. Dependency injection without boilerplate. Code-gen (`@riverpod`) reduces manual provider wiring.
- **Rejected:** Bloc (verbose for 6h timebox), Provider (not scalable for reactive call state).

---

## ADR-002: Local Storage → Hive

- **Status:** Accepted
- **Decision:** Use `hive_flutter` ^1.1.0 for all local persistence (Users, Messages, CallRequests, SessionLogs, RoomMeta, sync outbox/settings).
- **Rationale:** Zero native dependencies, fast binary storage, simple key-value + typed adapters. Works immediately on Android emulator.
- **Rejected:** SQLite/drift (relational overhead not needed), Firebase (violates local-first rule).

---

## ADR-003: RTC Strategy → 100ms SDK (hmssdk_flutter)

- **Status:** Accepted
- **Decision:** Use `hmssdk_flutter` ^1.11.0. Token server generates JWTs locally via Node.js.
- **Rationale:** 100ms is mandated by requirements. Local token server avoids cloud dependency for demos.
- **Note:** Low-level WebRTC networking details are flagged as outside current expertise — rely on SDK abstractions.

---

## ADR-004: Navigation → go_router

- **Status:** Accepted
- **Decision:** Use `go_router` ^14.8.1 for both apps.
- **Rationale:** Declarative, deep-link ready, Riverpod-compatible redirect guards. Needed for in-call screen routing.

---

## ADR-005: Git Branch Strategy

- **Status:** Accepted
- **Decision:** 3 long-lived app branches (`guru`, `trainer`, `node-server`) + feature branches per issue + `staging` as integration target. `main` is human-only.
- **Rationale:** Keeps app concerns isolated. Staging allows integration testing before touching main.

---

## ADR-006: Monorepo Layout → `shared` Dart Package

- **Status:** Accepted
- **Decision:** Single repo with `guru_app`, `trainer_app`, `shared/`, and `token_server/`. Cross-app models, sync, chat UI, and observability live in `shared` and are imported via path dependency.
- **Rationale:** One source of truth for `Message`, `CallRequest`, `SessionLog`, sync logic, and chat widgets. Avoids copy-paste between apps.
- **Rejected:** Fully duplicated `lib/` per app (harder to keep chat/sync in sync for reviewer demo).

---

## ADR-007: Backend → Node.js `token_server` (Express)

- **Status:** Accepted
- **Decision:** One local Node.js service (`token_server/index.js`) on port 3000 using Express, `jsonwebtoken`, `uuid`, and optional `dotenv` for 100ms credentials.
- **Rationale:** Approved stack; fastest path for JWT signing and a minimal HTTP sync hub. Single process for reviewer setup (`npm start`).
- **Rejected:** Separate sync microservice, Go/Dart token-only servers (extra setup for same demo scope).

### Responsibilities

| Concern | Endpoints | Notes |
|--------|-----------|-------|
| 100ms app tokens | `POST/GET /token` | `roomId`, `userId`, `role` → JWT with `jti` |
| Chat messages | `POST/GET /sync/messages`, `PATCH /sync/messages/:id/status` | In-memory `Map`; POST ack promotes `sending` → `sent` |
| Typing presence | `POST/GET /sync/typing` | Ephemeral; 3s TTL |
| Call requests | `POST/GET /sync/call-requests` | Conflict check on approve (same trainer + slot) |
| Session logs | `POST/GET /sync/session-logs` | Replicated after call end |
| Room metadata | `POST /rooms` | On approve: create real HMS room when keys set, else stub `room-<requestId>` |
| CORS | Middleware | `*` origin for emulator ↔ host |

HMS features are **optional**: sync APIs work without `HMS_APP_ACCESS_KEY` / `HMS_APP_SECRET`; video join returns 503 until configured.

---

## ADR-008: Cross-App Data → Local-First + HTTP Poll Sync

- **Status:** Accepted
- **Decision:** UI reads/writes Hive immediately. `SyncService` in `shared` pushes outbox entities to `token_server` and polls ~every 1.5s. Server store is in-memory (demo only, not durable).
- **Rationale:** Satisfies “local-first” requirement while giving real-time feel between two emulators/devices on the same machine. No WebSockets or cloud DB in scope.
- **Rejected:** Firebase/backend-as-source-of-truth, pure Hive with no bridge (apps would not see each other’s messages).

### Sync flow

```
Widget → Riverpod → Repository → Hive (immediate UI)
                    ↓
              SyncService (outbox + poll)
                    ↓
              token_server in-memory Maps
                    ↓
              Peer app poll → merge by entity id → Hive
```

- **Message status:** Monotonic merge (`sending` < `sent` < `read`) on client and server (`message_status_merge.dart`).
- **Android emulator URL:** `http://10.0.2.2:3000` via `SyncConstants.syncBaseUrl`.
- **Dedicated chat helper:** `MessageSyncService` wraps `SyncService` for message-only polling; home screens use `HomeMessageSyncListener` to refresh lists on sync ticks.

---

## ADR-009: Auth → Mock / Pre-Seeded Personas

- **Status:** Accepted
- **Decision:** No real login or OAuth. Guru app: onboarding then auto-login as DK (`member-dk-001`). Trainer app: auto-login as Aarav (`trainer-aarav-001`). Profiles stored in Hive `users` box.
- **Rationale:** Requirements specify fixed personas for demo; auth is out of timebox scope.
- **Rejected:** Firebase Auth, custom JWT session for users.

---

## ADR-010: Data Access → Repository Interfaces + Hive Implementations

- **Status:** Accepted
- **Decision:** Abstract repositories per domain (`AuthRepository`, `ChatRepository`, `CallRequestRepository`, `SessionLogRepository`) with `Hive*` implementations registered in Riverpod `repository_providers.dart`. Tests use fakes in `test/fakes/`.
- **Rationale:** Swappable persistence for widget tests; clear boundary between UI/viewmodels and storage/sync.
- **Rejected:** Viewmodels calling Hive boxes directly everywhere.

---

## ADR-011: Chat UI → Shared Package (`shared/lib/chat`)

- **Status:** Accepted
- **Decision:** Shared `ChatListPage`, `ConversationPage`, viewmodels, bubbles, typing indicator, and theme config. Apps inject `ChatAppConfig` (colors, persona) and wire `HiveChatRepository` + sync bootstrap in `main.dart`.
- **Rationale:** One implementation for member/trainer bubble alignment and unread logic; apps only differ by theme (blue vs red).
- **Rejected:** Duplicate conversation screens per app.

---

## ADR-012: Call Lifecycle → Approve Creates RoomMeta + System Chat Message

- **Status:** Accepted
- **Decision:** Trainer approve updates `CallRequest` to `approved`, posts system message to default chat (`chat-dk-aarav`), and syncs `RoomMeta` via `POST /rooms`. Decline supports optional reason. Schedule conflict: server rejects second `approved` for same trainer + `scheduledFor`.
- **Join window:** `SyncConstants.joinWindowMinutes = 10` before `scheduledFor` (spec-aligned).
- **Rationale:** Ties scheduling UX to chat thread and 100ms room id in one flow reviewers can follow.

---

## ADR-013: 100ms Room Creation → Management API with `jti`

- **Status:** Accepted
- **Decision:** Management JWTs and app tokens both include `jwtid: uuidv4()`. `createHmsRoom()` calls `POST https://api.100ms.live/v2/rooms` on approve when HMS env is set.
- **Rationale:** 100ms rejects management tokens without `jti` (401 `null jti`); fallback `room-<requestId>` breaks SDK join.
- **Rejected:** Fixing join only in Flutter while server still emitted invalid management tokens.

---

## ADR-014: In-Call Video → Manifest + Runtime Permissions + `HMSVideoView`

- **Status:** Accepted
- **Decision:** Declare camera/mic in Android/iOS manifests; request via `permission_handler` before join (`call_permissions.dart`). `HmsVideoCallService` listens to `onTrackUpdate` and drives `HMSVideoView` from `tracksUpdated` (not avatar placeholders).
- **Rationale:** SDK join succeeded but UI showed no surfaces without explicit permissions and track wiring.
- **Rejected:** Relying on HMS internal permission handling alone.

---

## ADR-015: Video Call Abstraction → `VideoCallService` per App

- **Status:** Accepted
- **Decision:** Interface `VideoCallService` with `HmsVideoCallService` implementation in each app; `VideoCallViewModel` handles phases (preJoin → connecting → inCall → notes/done). Token fetch via HTTP to `token_server`.
- **Rationale:** Keeps 100ms SDK details out of widgets; enables `FakeVideoCallService` in tests.

---

## ADR-016: Dev Observability → Shared Dev Panel (debug builds)

- **Status:** Accepted
- **Decision:** `shared/lib/observability/` provides ring buffer logging (`AppLog`), env snapshot with masked secrets, and `DevToolsShell` / `DevPanel` for on-device debugging during manual QA.
- **Rationale:** Reviewer and agents need visibility into sync/HMS failures without adb logcat alone.
- **Scope:** Debug-oriented; not a production analytics pipeline.

---

## ADR-017: UI Copy → Centralized `ui_copy.dart`

- **Status:** Accepted
- **Decision:** Canonical user-facing strings for empty chat, call lifecycle, join prompts, and session-ended copy live in `shared/lib/constants/ui_copy.dart`.
- **Rationale:** Keeps guru/trainer wording identical where required by acceptance script; single place to update copy.

---

## ADR-018: AI Workflow Audit Trail

- **Status:** Accepted
- **Decision:** Maintain `AI_LEDGER.md`, `PROMPT_LOG.md` (Cursor `beforeSubmitPrompt` hook), `MEMORY.md`, `ERRORS.md`. Cursor rules/skills mirror Claude Code (`AGENTS.md` map).
- **Rationale:** Project requirement to prove AI-native development; decisions and failures survive across sessions.
- **Rejected:** Relying on chat history only.

---

## ADR-019: Linting Gates

- **Status:** Accepted
- **Decision:** `flutter analyze` (0 errors) before Flutter commits; `npm run lint` before Node commits. No `// ignore:` without human approval.
- **Rationale:** Keeps monorepo mergeable under timebox pressure.

---

## Index

| ADR | Topic |
|-----|--------|
| 001 | Riverpod |
| 002 | Hive |
| 003 | 100ms SDK |
| 004 | go_router |
| 005 | Git branches |
| 006 | Monorepo + `shared` |
| 007 | Node `token_server` |
| 008 | Local-first HTTP sync |
| 009 | Mock auth / personas |
| 010 | Repository pattern |
| 011 | Shared chat UI |
| 012 | Call approve + join window |
| 013 | HMS management `jti` + rooms |
| 014 | Permissions + `HMSVideoView` |
| 015 | `VideoCallService` abstraction |
| 016 | Dev observability |
| 017 | `ui_copy.dart` |
| 018 | AI audit docs |
| 019 | Lint gates |
