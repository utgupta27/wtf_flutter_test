# WTF Platform

Guru ↔ Trainer Chat + Video Call System. Local-first Flutter monorepo.

## Apps

| App | Persona | Color |
|-----|---------|-------|
| `guru_app` | DK (Member) | `#1769E0` |
| `trainer_app` | Aarav (Trainer) | `#E50914` |

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
