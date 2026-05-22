# ARCHITECTURE.md — WTF Platform

## Monorepo Structure

```
wtf_flutter_test/
├── guru_app/          # Flutter app — Member (DK) facing
├── trainer_app/       # Flutter app — Trainer (Aarav) facing
├── shared/            # Dart package — shared models, services, widgets, utils
├── token_server/      # Node.js — 100ms JWT token server
├── BACKLOG.md
├── MEMORY.md
├── ERRORS.md
├── AI_LEDGER.md
├── ARCHITECTURE.md
├── DECISIONS.md
└── README.md
```

## lib/ Structure (both apps)

```
lib/
├── main.dart
├── app.dart              # ProviderScope + MaterialApp.router
├── core/
│   ├── theme/            # AppTheme, colors, text styles
│   └── constants.dart    # API base URL, Hive box names, seed IDs
├── features/
│   ├── auth/             # Mock auth provider + auto-login
│   ├── chat/             # Chat list + conversation
│   ├── calls/            # Schedule, approve, join call
│   └── sessions/         # Session logs
├── providers/            # Global Riverpod providers (storage, services)
└── router/               # go_router config
```

## Data Flow

```
UI Widget
  └── ref.watch(someProvider)
        └── Riverpod Provider/Notifier
              └── Service (ChatService / CallService etc.)
                    └── Hive Box (local storage)
```

For video calls:
```
CallNotifier
  └── TokenService (POST /token → token_server)
        └── HMSSDK (100ms Flutter SDK)
              └── In-call UI widgets
```

## Personas (pre-seeded, no real auth)

| App | User | ID | Role | Assigned To |
|-----|------|-----|------|-------------|
| guru_app | DK | member-dk-001 | member | trainer-aarav-001 |
| trainer_app | Aarav | trainer-aarav-001 | trainer | — |

## Color System

| App | Primary | Usage |
|-----|---------|-------|
| guru_app | `#1769E0` | Buttons, app bar, member chat bubbles |
| trainer_app | `#E50914` | Buttons, app bar, trainer chat bubbles |
| Shared | `#12B76A` success, `#F79009` warning, `#D92D20` error | Status chips |
