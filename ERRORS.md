# ERRORS.md — WTF Platform Failure Log

> Log entries here only when an approach takes more than 2 attempts. Format: What failed → What worked → Note for next time.

---

## 2026-05-22 — 100ms call join 401 (INIT)

- **What failed:** `prod-init.100ms.live` returned 401 on join; management API room creation returned `Token validation error` / `null jti`.
- **What worked:** Add `jwtid: uuidv4()` to `signManagementToken()` (app tokens already had `jti`). Restart token server; recreate room via `POST /rooms` so `hmsRoomId` is a real 100ms room ID (not `room-<requestId>` fallback).
- **Note for next time:** Fallback `room-*` IDs in Hive mean HMS room creation failed — check token server logs for `[HMS] Room creation failed` before debugging the Flutter SDK.
