Project: WTF Platform — Guru ↔ Trainer Chat + Video Call System

## 1. Project Overview

Goal: Build two Flutter apps that work together locally, supported by a minimal local token server.

- Guru App (Member facing)
- Trainer App (Trainer facing)

Core modules: Mock Auth, real-time chat, 100ms video call scheduling + calling, session logs, basic CRM lists.

Non-negotiable requirement: AI-Native workflow. We must use AI for coding, debugging, tests, and documentation, and prove it by maintaining an `AI_LEDGER.md` file.

## 2. Project Constraints & Rules

- Local-first: Must run on an Android emulator/real device without a cloud backend (local Hive/SQLite storage).
- RTC: 100ms SDK is mandatory for video calls.
- Token Server: Must include a minimal token server (Node/Go/Dart) to generate 100ms tokens.
- Personas:
  - Guru App automatically logs in as Member "DK" (pre-seeded profile).
  - Trainer App automatically logs in as Trainer "Aarav" (pre-seeded profile).
- State Management: Choose Riverpod, Bloc, or Provider and document in DECISIONS.md.
- Commits: Must use Conventional Commits (feat:, fix:, chore:, docs:, etc.).

## 3. Repository & Project Scaffolding

wtf_flutter_project/

├─ README.md

├─ AI_LEDGER.md               # Must contain all prompts + where/how used + outputs

├─ ARCHITECTURE.md

├─ DECISIONS.md               # ADRs (#1 state mgmt, #2 storage, #3 RTC strategy)

├─ token_server/              # tiny 100ms token server (Node/Go/Dart)

├─ shared/

│  ├─ models/

│  ├─ services/               # abstractions: AuthService, ChatService, CallService, LogService

│  ├─ widgets/                # reusable UI

│  └─ utils/                  # theme, validators, extensions

├─ guru_app/

│  ├─ lib/

│  ├─ test/

│  └─ pubspec.yaml

└─ trainer_app/

   ├─ lib/

   ├─ test/

   └─ pubspec.yaml

## 4. Data Model (Minimum)

- User { id, role: [trainer|member], name, email, avatarUrl?, assignedTrainerId? }
- Message { id, chatId, senderId, receiverId, text, createdAt, status: [sending|sent|read] }
- CallRequest { id, memberId, trainerId, requestedAt, scheduledFor, note, status: [pending|approved|declined|cancelled] }
- SessionLog { id, memberId, trainerId, startedAt, endedAt, durationSec, rating?, trainerNotes?, memberNotes? }
- RoomMeta { id, callRequestId, hmsRoomId, hmsRoleMember, hmsRoleTrainer }

## 5. UX & Feature Requirements

A. First-Run & Auth

- Guru App (DK): Onboarding (2 slides) -> Auto-creates DK profile -> Auto-assigns to Trainer Aarav -> Lands on Home with 3 cards: Chat with Trainer, Schedule Call, My Sessions.
- Trainer App (Aarav): Login (mock) -> Home with 4 tiles: Members, Chats, Requests, Sessions.

B. Member–Trainer Chat

- Real-time feel via local sync.
- Chat List: Recent conversations, unread badge, last message, timestamp.
- Conversation Screen: Left/right bubble alignment (Member=Blue, Trainer=Red).
- Typing indicator (simulated 400-800ms delay).
- Status ticks: single (sent), double (read).
- Pull to load history, auto-scroll to bottom.

C. Schedule a Call (100ms pipeline)

- Member (DK): Calendar UI (next 3 days, 30-min blocks). Note field (140 chars). CTA: Request Call -> creates CallRequest.pending.
- Trainer (Aarav): Requests tab shows pending. Approve/Decline inline.
- On Approve: Create RoomMeta + scheduled entry; send system message into chat: "Call approved for 6:00 PM". Date/time validation and conflict check required.

D. Join Video Call (100ms)

- 10 mins before call, both see "Join Call" button.
- Pre-join device check modal (cam/mic preview).
- In-Call UI: Two participant tiles (grid), Mute/Unmute, Video On/Off, Flip Camera, End Call.
- Post-call sheets:
  - Member: Rate session (1-5).
  - Trainer: Add quick notes.
- Auto-write SessionLog on end.

E. Session Logs & Insights

- List of past sessions with chips (All, Last 7 days, This Month). Shows date, duration, rating. Tap for details.

## 6. UI/UX Design System

- Spacing: 8pt system. Clean, modern.
- Typography: H1 24sp, H2 20sp, Body 14–16sp.
- Colors:
  - Trainer App Primary: #E50914
  - Guru App Primary: #1769E0
  - Status: Success #12B76A, Warning #F79009, Error #D92D20
- Components: AppBar with role badge, sticky input bar, loading skeletons, empty states.

## 7. Performance Targets

- Cold start <= 2.5s on emulator.
- Chat send -> render on peer <= 400ms (simulated ok).
- RTC join time <= 4s on local network.
- Scroll 60fps on chat list.

## 8. Launch & Acceptance Criteria (Passing Criteria)

To consider this project successfully built, it must pass the following manual testing script:

1. Repo builds both apps with one command documented in README.
2. Token server runs locally (with clear setup instructions and env sample).
3. Launch Trainer App -> Logged in as Aarav.
4. Launch Guru App -> Onboarding -> Assigned to Aarav.
5. Chat Engine: DK sends message -> Trainer sees unread badge, replies. Both see read receipts and typing indicators.
6. Call Scheduler: DK schedules call -> Trainer approves -> System message appears. Conflict handling works correctly.
7. 100ms SDK: Both tap Join Call -> Connect via 100ms with working camera/mic, device toggles, and role-based permissions.
8. Session Tracking: End Call -> Logs created -> Ratings/Notes added.
9. `AI_LEDGER.md` is fully populated with all generation prompts and debugging steps.

