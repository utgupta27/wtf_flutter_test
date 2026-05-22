# BACKLOG.md — WTF Platform

> Issues map to GitHub Issues. Branch: feat/<app>/<name>. Status: [ ] open, [x] done.

---

## SHARED (Phase 1)

- [x] #1 — Data models: User, Message, CallRequest, SessionLog, RoomMeta (`feat/shared/data-models`)

---

## GURU APP (Phase 1 — per-app UI)

- [x] #2 — Mock Auth: Auto-login as DK, seed profile + assign to Aarav (`feat/guru/mock-auth`)
- [x] #3 — Onboarding: 2-slide flow → lands on Home (`feat/guru/onboarding`)
- [x] #4 — Home Screen: 3 cards (Chat, Schedule Call, My Sessions) (`feat/guru/home-screen`)
- [x] #5 — Chat: Conversation screen with send/receive, bubbles, status ticks (`feat/guru/chat-ui`)
- [x] #6 — Chat: Chat list with unread badge, last message, timestamp (`feat/guru/chat-list`)
- [x] #7 — Schedule Call: Calendar UI, note field, create CallRequest.pending (`feat/guru/schedule-call`)
- [x] #8 — Video Call: Pre-join modal, in-call UI, end call → rate session (`feat/guru/video-call`)
- [x] #9 — Session Logs: List with filter chips (All, Last 7d, This Month) (`feat/guru/session-logs`)

---

## TRAINER APP (Phase 1)

- [x] #10 — Mock Auth: Auto-login as Aarav (`feat/trainer/mock-auth`)
- [x] #11 — Home Screen: 4 tiles (Members, Chats, Requests, Sessions) (`feat/trainer/home-screen`)
- [x] #12 — Chat: Member chat list + conversation screen (`feat/trainer/chat`)
- [x] #13 — Requests: Approve/Decline inline (`feat/trainer/requests`)
- [x] #14 — Video Call: Pre-join modal, in-call UI, end call → add notes (`feat/trainer/video-call`)
- [x] #15 — Session Logs: List with trainer notes (`feat/trainer/video-call`)

---

## NODE SERVER (Phase 1)

- [x] #16 — Token Server: POST /token endpoint generating 100ms JWT (`feat/node/token-endpoint`)

---

## Phase 2 — Cross-app manual test script (GitHub #38–#55)

- [x] #38 / #40+ — Node sync hub API (`token_server` `/sync/*`, `/rooms`)
- [x] #39 — Shared `SyncService` + Hive outbox + poll merge
- [x] #40 — Guru: Say hi / direct chat / FAB
- [x] #42 — Chat UX: read receipts, typing, 5m ago, system bubbles
- [x] #43 — Guru: schedule sync + My Requests + toast
- [x] #44 — Trainer: requests sync + decline modal
- [x] #45 — Approve → RoomMeta + system message sync
- [x] #46 — Upcoming Calls + dev join window (1 min)
- [x] #47 — Room id on token join
- [x] #48 — Pre-join device toggles
- [x] #50 — Flip camera + reconnect overlay
- [x] #51 — Session log sync + sort latest first
- [x] #52 — README manual test script
- [ ] #53 — Chat FAB + quick reply chips (bonus polish)
- [ ] #54 — UI polish pass (optional)
- [ ] #55 — Image attachment (bonus)
