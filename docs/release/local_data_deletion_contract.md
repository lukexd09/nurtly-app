# Local Data Deletion Contract

The MVP delete-all flow is local-only and must be truthful about what is removed from persistence.

## Current contract

- Journal entries are deleted from local persistence.
- Saved language preference is deleted from local persistence.
- Reviewer access is deleted from local persistence.
- Google Play purchase history is not touched.
- Premium entitlement is not reset.
- UMP consent state is not deleted by local data removal.

## Legacy journal migration

Older persisted Journal payloads may contain entries with `isDeleted == true`.

When those entries are encountered during load:

- they are excluded from loaded Journal state;
- the stored JSON is rewritten without them;
- the deleted entry IDs and note/body content are removed from persistence.

The migration preserves active entries and remains safe on repeated loads.

## Persistence truthfulness

Deletion flows must not report success when the underlying persistence operation returns `false`.

For the Journal store, language preference store, and reviewer-access store:

- a failed write or remove result must surface as a failure;
- delete-all must not be reported as complete if any component fails;
- retrying a failed component should remain possible on a later attempt.
