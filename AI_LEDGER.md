# AI_LEDGER.md — WTF Platform AI Activity Log

> Every completed task must have an entry. Format: Prompt/Intent | Tool | Output Summary | Files Modified | Commit

---

## Entry 001 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | Set up the full WTF Platform project from claude.md instructions |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | Scaffolded monorepo: guru_app, trainer_app (Flutter 3.41.9), shared Dart package, Node.js token server. Configured Riverpod, Hive, go_router in pubspec.yaml. Set up Flutter linting (analysis_options.yaml ×3) and ESLint for Node. Created git repo, GitHub remote (wtf_flutter_test, private), branch strategy (main/staging/guru/trainer/node-server). Created 16 GitHub issues. Wrote MEMORY.md, ERRORS.md, AI_LEDGER.md, BACKLOG.md, ARCHITECTURE.md, DECISIONS.md, README.md. |
| **Files Modified** | guru_app/pubspec.yaml, trainer_app/pubspec.yaml, shared/pubspec.yaml, guru_app/analysis_options.yaml, trainer_app/analysis_options.yaml, shared/analysis_options.yaml, token_server/index.js, token_server/package.json, token_server/eslint.config.cjs, token_server/.env.example, claude.md |
| **Commit** | `chore(setup): initial project scaffold with linting and branch strategy` |

---


## Entry 002 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #1 — Shared data models (User, Message, CallRequest, SessionLog, RoomMeta) |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | 5 Hive-annotated models with typed adapters, MessageStatus + CallRequestStatus enums, SeedUsers constants, barrel export, 4 unit tests passing, flutter analyze → 0 issues. |
| **Files Modified** | shared/lib/models/*.dart, shared/lib/shared.dart, shared/test/shared_test.dart, shared/pubspec.yaml |
| **Commit** | `feat(shared): add Hive data models` |

## Entry 003 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #16 — Node token server: POST /token for 100ms JWT |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | Express server with POST /token (HS256 JWT) and GET /health. Then migrated to TypeScript + ESM: src/index.ts with TokenRequestBody/TokenPayload interfaces, tsconfig.json (NodeNext), eslint.config.js (typescript-eslint v8). npm run lint → 0, npm run build → clean. |
| **Files Modified** | token_server/src/index.ts, token_server/tsconfig.json, token_server/eslint.config.js, token_server/package.json, .gitignore |
| **Commit** | `feat(node): implement 100ms JWT token endpoint` → `refactor(node): migrate to TypeScript and ES modules` |

## Entry 004 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #2 — Guru mock auth: auto-login as DK, seed profile |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | AuthNotifier seeds DK profile in Hive on first launch. Hive adapters registered in main.dart. ProviderScope + GoRouter wired in app.dart. AppTheme (#1769E0), AppConstants. flutter analyze → 0, flutter test → 1 passed. |
| **Files Modified** | guru_app/lib/main.dart, guru_app/lib/app.dart, guru_app/lib/features/auth/auth_provider.dart, guru_app/lib/router/app_router.dart, guru_app/lib/core/constants.dart, guru_app/lib/core/theme/app_theme.dart |
| **Commit** | `feat(guru): add mock auth, app structure, and routing scaffold` |

## Entry 005 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #3 — Guru onboarding: 2-slide flow |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | OnboardingScreen with PageView (2 slides), Skip/Next/Get Started controls, animated OnboardingDot indicator. onComplete saves Hive flag + navigates to /home. Router wired to real screen. 9/9 widget tests passing, flutter analyze → 0. |
| **Files Modified** | guru_app/lib/features/onboarding/onboarding_screen.dart, guru_app/lib/router/app_router.dart, guru_app/test/features/onboarding/onboarding_screen_test.dart |
| **Commit** | `feat(guru): add 2-slide onboarding flow` |

## Entry 006 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #5 + #6 + Architecture — Apply MVVM with clear separation of concerns to both Flutter apps |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | Added Repository layer (AuthRepository, OnboardingRepository, ChatRepository — interfaces + Hive impls). Added ViewModel layer (AuthViewModel, OnboardingViewModel, ConversationViewModel, ChatListViewModel — Riverpod Notifiers). Refactored all screens to ConsumerWidgets with zero business logic. Router reduced to routing only. Tests use ProviderScope + fake repositories. 27 tests passing, flutter analyze → 0. |
| **Files Modified** | guru_app/lib/features/*/data/*, guru_app/lib/features/*/viewmodel/*, guru_app/lib/providers/repository_providers.dart, all screen files refactored, guru_app/test/fakes/fake_repositories.dart, shared/lib/models/message.dart |
| **Commit** | `refactor(guru): apply MVVM architecture with clear separation of concerns` |

---

## Entry 007 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #7 — Guru Schedule Call: 3-day calendar, 30-min slot grid, 140-char note, conflict check, CallRequest.pending |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | CallRequestRepository interface + HiveCallRequestRepository impl. ScheduleCallViewModel (Notifier) with day/slot/note state, hasConflict check, submit creates CallRequest.pending. ScheduleCallScreen: 3-day ChoiceChip row, 24×30-min slot grid (8 AM–8 PM), 140-char TextField, success view, conflict/validation error display. callRequestRepositoryProvider added to repository_providers.dart. /schedule route wired to real screen. FakeCallRequestRepository added to test fakes. 8 widget tests passing, 35 total. flutter analyze → 0. |
| **Files Modified** | guru_app/lib/features/calls/data/call_request_repository.dart, call_request_repository_impl.dart, guru_app/lib/features/calls/viewmodel/schedule_call_viewmodel.dart, guru_app/lib/features/calls/schedule_call_screen.dart, guru_app/lib/providers/repository_providers.dart, guru_app/lib/router/app_router.dart, guru_app/test/fakes/fake_repositories.dart, guru_app/test/features/calls/schedule_call_screen_test.dart |
| **Commit** | `feat(guru): schedule call screen with MVVM — Issue #7` |

---

## Entry 008 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #8 — Guru Video Call: pre-join modal, in-call UI (100ms SDK), post-call rating, SessionLog auto-creation |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | VideoCallService interface + HmsVideoCallService (100ms SDK wrapper, JWT fetched from local token server via dart:io). SessionLogRepository interface + HiveSessionLogRepository. VideoCallViewModel (FamilyNotifier, 5-phase state machine: preJoin/connecting/inCall/rating/done, Timer.periodic for duration, saves SessionLog on rating submit). VideoCallScreen renders each phase. FakeVideoCallService + FakeSessionLogRepository in test fakes. /call/:requestId route added. 14 widget tests, 49 total passing. flutter analyze → 0. Issues #7 and #8 closed on GitHub. |
| **Files Modified** | guru_app/lib/features/calls/service/*, guru_app/lib/features/calls/viewmodel/video_call_viewmodel.dart, guru_app/lib/features/calls/video_call_screen.dart, guru_app/lib/features/sessions/data/*, guru_app/lib/providers/repository_providers.dart, guru_app/lib/router/app_router.dart, guru_app/test/fakes/fake_repositories.dart, guru_app/test/features/calls/video_call_screen_test.dart |
| **Commit** | `feat(guru): video call screen with MVVM — Issue #8` |

---

## Entry 009 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #9 — Guru Session Logs: list with filter chips (All, Last 7d, This Month) |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | SessionLogsViewModel (AsyncNotifier) with SessionFilter enum; filtered getter on SessionLogsState. SessionLogsScreen with FilterChip row, SessionLogTile (trainer name, date, duration, star badge), empty state, pull-to-refresh. /sessions route wired. 10 widget tests, 59 total passing. flutter analyze → 0. Issue #9 closed. |
| **Files Modified** | guru_app/lib/features/sessions/viewmodel/session_logs_viewmodel.dart, guru_app/lib/features/sessions/session_logs_screen.dart, guru_app/lib/router/app_router.dart, guru_app/test/features/sessions/session_logs_screen_test.dart |
| **Commit** | `feat(guru): session logs screen with filter chips — Issue #9` |

---

## Entry 010 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #10 — Trainer Mock Auth: auto-login as Aarav, seed profile, full app scaffold |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | Full trainer_app scaffold: main.dart (7 Hive adapters, 5 boxes, ProviderScope), TrainerApp ConsumerWidget, Material3 red theme (#E50914). AuthRepository + HiveAuthRepository + AuthViewModel (auto-seeds Aarav). Router: splash → home redirect. Placeholder HomeScreen (greeting + role badge). FakeAuthRepository + 2 widget tests. Pulled shared model files from guru branch (message, call_request, session_log, room_meta). flutter analyze → 0, 3 tests passing. |
| **Files Modified** | trainer_app/lib/* (all new), trainer_app/test/*, trainer_app/pubspec.yaml, shared/lib/models/*.dart, shared/pubspec.yaml |
| **Commit** | `feat(trainer): mock auth + app scaffold — Issue #10` |

---

## Entry 011 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #11 — Trainer Home Screen: 4 dashboard tiles (Members, Chats, Requests, Sessions) |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | HomeViewModel (AsyncNotifier<User>) loads Aarav. HomeScreen 2×2 GridView of HomeActionTile (Members, Chats, Requests, Sessions). Router extended with 4 placeholder routes. 8 widget tests, 9 total passing. flutter analyze → 0. Issue #11 closed. |
| **Files Modified** | trainer_app/lib/features/home/home_screen.dart, trainer_app/lib/features/home/viewmodel/home_viewmodel.dart, trainer_app/lib/router/app_router.dart, trainer_app/test/features/home/home_screen_test.dart |
| **Commit** | `feat(trainer): home screen with 4 action tiles — Issue #11` |

---

## Entry 012 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #12 — Trainer Chat: member list + conversation screen |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | ChatRepository + HiveChatRepository. ChatListViewModel (AsyncNotifier, unread detection). ConversationViewModel (FamilyAsyncNotifier, optimistic send). ChatListScreen (DK tile, UnreadBadge). ConversationScreen (coloured bubbles, status ticks, input bar). FakeChatRepository in fakes. 12 widget tests, 21 total. flutter analyze → 0. Issue #12 closed. |
| **Files Modified** | trainer_app/lib/features/chat/*, trainer_app/lib/providers/repository_providers.dart, trainer_app/lib/router/app_router.dart, trainer_app/test/fakes/fake_repositories.dart, trainer_app/test/features/chat/* |
| **Commit** | `feat(trainer): chat screens (member list + conversation) — Issue #12` |

---

## Entry 013 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #13 — Trainer Requests: approve/decline inline, system message on approve |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | CallRequestRepository + HiveCallRequestRepository. RequestsViewModel (AsyncNotifier): approve() → status=approved + system chat message, decline() → status=declined; both reload. RequestsScreen: pending-only list, RequestCard with inline Approve/Decline. FakeCallRequestRepository in fakes. 8 widget tests, 29 total. flutter analyze → 0. Issue #13 closed. |
| **Files Modified** | trainer_app/lib/features/requests/*, trainer_app/lib/providers/repository_providers.dart, trainer_app/lib/router/app_router.dart, trainer_app/test/fakes/fake_repositories.dart, trainer_app/test/features/requests/requests_screen_test.dart |
| **Commit** | `feat(trainer): requests screen with approve/decline — Issue #13` |

---

## Entry 014 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #14 + #15 — Trainer Video Call (pre-join/in-call/notes) + Session Logs with trainer notes |
| **Tool** | Claude Code (claude-sonnet-4-6) |
| **Output Summary** | VideoCallService + HmsVideoCallService (trainer role). VideoCallViewModel (FamilyNotifier, 5-phase: preJoin/connecting/inCall/notes/done). VideoCallScreen. SessionLogRepository + HiveSessionLogRepository (addTrainerNote). SessionLogsViewModel (AsyncNotifier, addNote/refresh). SessionLogsScreen (tile, Add/Edit note dialog). FakeVideoCallService + FakeSessionLogRepository. 18 widget tests, 46 total. flutter analyze → 0. Issues #14, #15 closed. |
| **Files Modified** | trainer_app/lib/features/calls/*, trainer_app/lib/features/sessions/*, trainer_app/lib/providers/repository_providers.dart, trainer_app/lib/router/app_router.dart, trainer_app/test/fakes/fake_repositories.dart, trainer_app/test/features/calls/*, trainer_app/test/features/sessions/* |
| **Commit** | `feat(trainer): video call + session logs with trainer notes — Issues #14 & #15` |

---

## Entry 015 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | Analyse Claude Code config; mirror skills/rules in Cursor; global recording to AI_LEDGER, BACKLOG, MEMORY, README; auto-record all user prompts |
| **Tool** | Cursor Agent |
| **Output Summary** | Documented Claude setup (`claude.md` + `.claude/skills/grill-me`). Added Cursor rules, skills (`grill-me`, `start-dev-flow`, `record-activity`), `beforeSubmitPrompt` hook → `PROMPT_LOG.md`, `AGENTS.md`, updated README docs index. |
| **Files Modified** | `.cursor/rules/wtf-platform.mdc`, `.cursor/rules/project-recording.mdc`, `.cursor/skills/grill-me/SKILL.md`, `.cursor/skills/start-dev-flow/SKILL.md`, `.cursor/skills/record-activity/SKILL.md`, `.cursor/hooks.json`, `.cursor/hooks/log-user-prompt.sh`, `PROMPT_LOG.md`, `AGENTS.md`, `README.md`, `AI_LEDGER.md` |
| **Commit** | — |

---

## Entry 016 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | Implement Manual Test Sync Plan: cross-app Hive+Node sync, Guru chat entry, calls, 100ms join, session sync; GitHub issues #40–#53 |
| **Tool** | Cursor Agent |
| **Output Summary** | Extended `token_server` with `/sync/messages`, `/sync/call-requests`, `/sync/session-logs`, `/rooms`, CORS, optional HMS. Added `shared` `SyncService` + JSON helpers. Both apps: sync polling bootstrap, chat sync/read/typing, schedule+My Requests, upcoming calls (1 min join window), RoomMeta join, pre-join toggles, flip/reconnect, session log sync. Guru Say hi + FAB. README manual script. BACKLOG Phase 2. GitHub issues #40–#53 created. guru 67 + trainer 46 tests pass. |
| **Files Modified** | `token_server/index.js`, `token_server/eslint.config.cjs`, `shared/lib/sync/sync_service.dart`, `shared/lib/models/*_json.dart`, `shared/lib/constants/sync_constants.dart`, `guru_app/lib/**`, `trainer_app/lib/**`, `README.md`, `ARCHITECTURE.md`, `BACKLOG.md`, tests |
| **Commit** | — |

---

_Append new entries below after each completed task._
