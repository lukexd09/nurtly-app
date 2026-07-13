# Local data deletion contract

This document records the local-data behavior implemented for task #180.

## Delete all local data

The action covers the three Nurtly-owned local stores:

| Component | Store/state removed on success | Google-managed state touched |
| --- | --- | --- |
| Journal | All persisted Journal entries and active in-memory Journal state | None |
| Language | Saved language preference; the active language returns to the current system language | None |
| Reviewer access | Persisted reviewer-access flag and active-session reviewer access | None |

Real Google Play Premium entitlement, Google Play purchase history and UMP consent
are intentionally preserved. The action is safe to repeat when stores are already
empty.

Each store operation runs independently. The result is `complete` when all three
operations succeed, `partial` when at least one succeeds and another fails, and
`failed` when all three fail. The UI reports these states without exposing store
keys or internal errors. A retry runs the same idempotent operations and can finish
components that failed previously.

## Individual Journal deletion

Deleting a Journal entry removes it from the controller list and writes the
remaining list to persistence. The entry body, note and other fields are not kept
as a soft-deleted record. Unknown and repeated IDs are safe. The legacy
`isDeleted` field remains decodable for historical payload compatibility, but new
deletions do not create records with `isDeleted: true`.
