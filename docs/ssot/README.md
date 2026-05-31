# SSOT

This folder is reserved for the single source of truth for product and project decisions.

## Source-of-truth hierarchy

For the current MVP, use this order of authority:

1. Implemented behavior in `app/lib` and the matching tests in `app/test`
2. Runtime content in `app/assets/content`
3. Release process in `docs/release`
4. QA process in `docs/qa`
5. Legal and privacy drafts in `docs/legal`
6. Product context and decisions in `docs/knowledge-base`
7. Editorial workspace materials in `content/`

## Conflict rule

If the knowledge base conflicts with code or release docs, treat the code and release docs as current for MVP behavior and mark the knowledge-base item as historical, deferred, or assumption-based.
