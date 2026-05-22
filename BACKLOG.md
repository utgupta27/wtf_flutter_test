# BACKLOG.md — WTF Platform

> Issues map to GitHub Issues. Branch: feat/<app>/<name>. Status: [ ] open, [x] done.

---

## SHARED

- [x] #1 — Data models: User, Message, CallRequest, SessionLog, RoomMeta (`feat/shared/data-models`)

---

## GURU APP

- [x] #2 — Mock Auth: Auto-login as DK, seed profile + assign to Aarav (`feat/guru/mock-auth`)
- [x] #3 — Onboarding: 2-slide flow → lands on Home (`feat/guru/onboarding`)
- [ ] #4 — Home Screen: 3 cards (Chat, Schedule Call, My Sessions) (`feat/guru/home-screen`)
- [ ] #5 — Chat: Conversation screen with send/receive, bubbles, status ticks (`feat/guru/chat-ui`)
- [ ] #6 — Chat: Chat list with unread badge, last message, timestamp (`feat/guru/chat-list`)
- [ ] #7 — Schedule Call: Calendar UI, note field, create CallRequest.pending (`feat/guru/schedule-call`)
- [ ] #8 — Video Call: Pre-join modal, in-call UI, end call → rate session (`feat/guru/video-call`)
- [ ] #9 — Session Logs: List with filter chips (All, Last 7d, This Month) (`feat/guru/session-logs`)

---

## TRAINER APP

- [ ] #10 — Mock Auth: Auto-login as Aarav, seed profile (`feat/trainer/mock-auth`)
- [ ] #11 — Home Screen: 4 tiles (Members, Chats, Requests, Sessions) (`feat/trainer/home-screen`)
- [ ] #12 — Chat: Member chat list + conversation screen (`feat/trainer/chat`)
- [ ] #13 — Requests: Approve/Decline inline, system message on approve (`feat/trainer/requests`)
- [ ] #14 — Video Call: Pre-join modal, in-call UI, end call → add notes (`feat/trainer/video-call`)
- [ ] #15 — Session Logs: List with trainer notes (`feat/trainer/session-logs`)

---

## NODE SERVER

- [x] #16 — Token Server: POST /token endpoint generating 100ms JWT (`feat/node/token-endpoint`)
