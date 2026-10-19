# Sync API — single source of truth

The contract the offline-first clients (`:profile` on Android, `Profile` on iOS)
will use to push guest data to the backend once a user registers. The client
schema already carries every field this contract needs (`id`, `accountUserId`,
`updatedAt`, `syncState`, `deleted`), so no migration is required to adopt it.

Status: **not implemented yet**. This documents the target so both platforms can
be built against one spec. Auth UI stays deferred while accounts are offline-first
(see `SplashTokens.ShowAuthActions`).

This is a prose contract: it has no `sync-contract.json` and no parity verifier,
because no transport code exists yet to check. Add both once the first client
sync path lands.

## Conventions

| Rule | Value |
| --- | --- |
| Base URL | `https://api.levela.app/v1` |
| Auth | `Authorization: Bearer <accessToken>`; guest requests omit it |
| IDs | UUIDv4, **client-generated** for every entity — the server never assigns entity IDs |
| Timestamps | ISO-8601 UTC, millisecond precision |
| Idempotency | `PUT` by entity UUID is an upsert; replaying a `PUT` is safe |
| Concurrency | `revision` (server-monotonic integer) returned on read/write; the client echoes it on write |

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| `POST` | `/auth/register` | Guest → account. Creates the user and claims guest data. |
| `POST` | `/auth/login` | Existing user signs in on a new device. |
| `GET` | `/profile` | Pull the account's profile (or `404` if none). |
| `PUT` | `/profile/{id}` | Upsert one profile; returns authoritative state. |
| `DELETE` | `/profile/{id}` | Soft-delete (tombstone). |

## Register (the "login later" moment)

```http
POST /auth/register
{
  "installId": "7f9c…-uuid",
  "email": "user@example.com",
  "password": "…"
}
```

`201`:

```json
{
  "accountUserId": "3c2d…-uuid",
  "accessToken": "eyJ…",
  "refreshToken": "…",
  "claimedProfileIds": ["8a1b…-uuid"]
}
```

The server uses `installId` to link any previously-synced guest rows (those with
no account but tagged to this install) to the new account. The client then sets
`accountUserId` on its local pending row and pushes normally.

## Profile resource

```json
{
  "id": "8a1b…-uuid",
  "accountUserId": "3c2d…-uuid",
  "goal": "Lose fat",
  "ageYears": 30,
  "sex": "Male",
  "weightKg": 70.5,
  "heightCm": 170.0,
  "activityLevel": "Moderately active",
  "weightUnit": "kg",
  "heightUnit": "cm",
  "onboardingCompleted": true,
  "createdAt": "2026-10-12T08:00:00.000Z",
  "updatedAt": "2026-10-12T08:00:00.000Z",
  "revision": 3,
  "deleted": false
}
```

`GET /profile` returns this shape (`404` when absent). `PUT /profile/{id}` sends
the same body without server-owned fields (`revision`) and receives it back.

Responses for `PUT`:

- `200` — updated; body is the authoritative resource with the new `revision`.
- `201` — created (first push of this UUID).
- `409` — `revision` mismatch; body carries the server's current copy to merge.
- `401` / `403` — re-auth; keep the row pending and retry later.

## Error model

```json
{ "error": { "code": "revision_conflict", "message": "…", "entity": { } } }
```

## Client sync algorithm

1. **Push:** read rows where `syncState != Synced` → `PUT /profile/{id}`.
2. On `2xx`: set `syncState = Synced`, store the returned `revision` + `updatedAt`.
3. On `409`: merge by `updatedAt` (last-write-wins), rewrite locally as pending, retry once.
4. On network / `5xx`: leave pending; retry on next launch or connectivity.
5. **Pull:** `GET /profile`; if a server copy exists and the local row is pending, merge by `updatedAt`; otherwise adopt the server copy.
6. Later edits (e.g. a weight update) just flip the row back to pending — same engine, no new code.
