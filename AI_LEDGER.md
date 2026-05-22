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

## Entry 016 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #35 — Onboarding: DK profile (name prefilled) + trainer selection from seeded list |
| **Tool** | Cursor Agent |
| **Output Summary** | 2 intro slides + profile setup page; `SeedTrainers` (Aarav, Priya, Mike); profile saved on complete with `assignedTrainerId`; stable GoRouter + splash→home redirect. Merged PR #36 → `guru`. |
| **Files Modified** | shared/lib/models/seed_trainers.dart, guru_app onboarding/auth/router, tests |
| **Commit** | `feat(guru): onboarding profile setup with trainer selection` |

---

## Entry 017 — 2026-05-22

| Field | Value |
|---|---|
| **Prompt/Intent** | #37 — AppBar back + Android system back to Home |
| **Tool** | Cursor Agent |
| **Output Summary** | `GuruSubpageScaffold` with header back + `PopScope`; Home uses `push`; applied to chat, conversation, schedule, sessions, video pre-join. Merged PR #38 → `guru`. |
| **Files Modified** | guru_app/lib/core/widgets/guru_subpage_scaffold.dart, home + feature screens, test |
| **Commit** | `feat(guru): AppBar and Android back navigation to Home` |

---

_Append new entries below after each completed task._
