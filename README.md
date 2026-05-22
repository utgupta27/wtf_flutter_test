# WTF Platform

Guru ↔ Trainer Chat + Video Call System. Local-first Flutter monorepo.

## Apps


| App           | Persona         | Color     |
| ------------- | --------------- | --------- |
| `guru_app`    | DK (Member)     | `#1769E0` |
| `trainer_app` | Aarav (Trainer) | `#E50914` |


## Demo Video

Part 1: [https://drive.google.com/file/d/1zouY-8FLfxZBt0kTOnfizfq4AiCTAo0s/view?usp=sharing](https://drive.google.com/file/d/1zouY-8FLfxZBt0kTOnfizfq4AiCTAo0s/view?usp=sharing) 
Part 2: [https://drive.google.com/file/d/141aXiEhfcTtwgiB6DgvcEVESqFkta-fq/view?usp=sharing](https://drive.google.com/file/d/141aXiEhfcTtwgiB6DgvcEVESqFkta-fq/view?usp=sharing)

## Quick Start

### 1. Token Server

```bash
cd token_server
cp .env.example .env          # Fill in HMS_APP_ACCESS_KEY and HMS_APP_SECRET
npm install
npm start                     # http://localhost:3000
```

### 2. Guru App

```bash
cd guru_app
flutter pub get
flutter run
```

### 3. Trainer App

```bash
cd trainer_app
flutter pub get
flutter run
```

## Cross-app sync (Phase 2)

Both apps share data through the local Node hub (`token_server`). Each app writes to Hive first, then syncs via HTTP poll (~1.5s).

```bash
cd token_server && npm start   # http://localhost:3000 — sync works without HMS keys
```

Android emulator uses `http://10.0.2.2:3000` (already set in app constants).

### Manual test script (reviewer)

1. Start `token_server` (`npm start`).
2. Launch **Trainer App** → logged in as Aarav.
3. Launch **Guru App** → onboarding DK → assigned to Aarav.
4. DK: Home → **Chat with Trainer** (or **Say hi**) → send `Hi Coach 👋`.
5. Trainer: **Chats** → unread badge → open DK → reply. While DK types, trainer sees **typing...**; after open, read receipts show double ticks.
6. DK: **Schedule Call** → today 6:00 PM, note `Macros review` → see **Pending approval by Aarav**.
7. Trainer: **Requests** → **Approve** → DK sees system message in chat.
8. DK & Trainer: **Upcoming Calls** (or chat camera badge) → **Join** (opens **10 minutes** before scheduled time).
9. Pre-join toggles → **Join Call** (requires HMS `.env` on token server).
10. End call → DK rates 5★ + note; Trainer adds notes.
11. Both: **Sessions** → latest log with duration/rating.

### Chat sync API (curl)

```bash
# Post message (server ack → status sent)
curl -X POST http://localhost:3000/sync/messages -H 'Content-Type: application/json' \
  -d '{"id":"m1","chatId":"chat-dk-aarav","senderId":"member-dk-001","receiverId":"trainer-aarav-001","text":"Hi","createdAt":"2026-05-22T10:00:00Z","status":"sending"}'

# Mark read
curl -X PATCH http://localhost:3000/sync/messages/m1/status -H 'Content-Type: application/json' \
  -d '{"status":"read"}'

# Typing indicator
curl -X POST http://localhost:3000/sync/typing -H 'Content-Type: application/json' \
  -d '{"chatId":"chat-dk-aarav","userId":"member-dk-001","isTyping":true}'
curl 'http://localhost:3000/sync/typing?chatId=chat-dk-aarav'
```

## Linting

```bash
# Flutter (run inside each app or shared)
flutter analyze

# Node.js
cd token_server && npm run lint
```

## Branch Strategy

```
main (human-only)
  └── staging
        ├── guru          → feat/guru/<name>
        ├── trainer       → feat/trainer/<name>
        └── node-server   → feat/node/<name>
```

## Docs

- [AGENTS.md](AGENTS.md) — Cursor / AI agent config map
- [claude.md](claude.md) — project instructions (Claude Code + Cursor)
- [ARCHITECTURE.md](ARCHITECTURE.md) — system design
- [DECISIONS.md](DECISIONS.md) — ADRs
- [BACKLOG.md](BACKLOG.md) — issue tracker
- [AI_LEDGER.md](AI_LEDGER.md) — AI activity log (completed tasks)
- [PROMPT_LOG.md](PROMPT_LOG.md) — user prompt audit trail (auto)
- [MEMORY.md](MEMORY.md) — decisions + session summaries
- [ERRORS.md](ERRORS.md) — failed approaches log

