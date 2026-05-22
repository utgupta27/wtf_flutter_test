# DECISIONS.md — Architecture Decision Records

---

## ADR-001: State Management → Riverpod

- **Status:** Accepted
- **Decision:** Use `flutter_riverpod` ^2.6.1 with `riverpod_annotation` for code generation.
- **Rationale:** Best async state handling for chat + call flows. Dependency injection without boilerplate. Code-gen (`@riverpod`) reduces manual provider wiring.
- **Rejected:** Bloc (verbose for 6h timebox), Provider (not scalable for reactive call state).

---

## ADR-002: Local Storage → Hive

- **Status:** Accepted
- **Decision:** Use `hive_flutter` ^1.1.0 for all local persistence (Users, Messages, CallRequests, SessionLogs).
- **Rationale:** Zero native dependencies, fast binary storage, simple key-value + typed adapters. Works immediately on Android emulator.
- **Rejected:** SQLite/drift (relational overhead not needed), Firebase (violates local-first rule).

---

## ADR-003: RTC Strategy → 100ms SDK (hmssdk_flutter)

- **Status:** Accepted
- **Decision:** Use `hmssdk_flutter` ^1.11.0. Token server generates JWTs locally via Node.js.
- **Rationale:** 100ms is mandated by requirements. Local token server avoids cloud dependency for demos.
- **Note:** Low-level WebRTC networking details are flagged as outside current expertise — will rely on SDK abstractions.

---

## ADR-004: Navigation → go_router

- **Status:** Accepted
- **Decision:** Use `go_router` ^14.8.1 for both apps.
- **Rationale:** Declarative, deep-link ready, Riverpod-compatible redirect guards. Needed for in-call screen routing.

---

## ADR-005: Git Branch Strategy

- **Status:** Accepted
- **Decision:** 3 long-lived app branches (guru, trainer, node-server) + feature branches per issue + staging as integration target. main is human-only.
- **Rationale:** Keeps app concerns isolated. Staging allows integration testing before touching main.
