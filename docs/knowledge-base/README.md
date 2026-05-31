# Nurtly Knowledge Base

Status: Initial Knowledge Base v1  
Last updated: 2026-05-31  
Purpose: Source material for future RAG, AI agents, product planning, and project continuity.

## Purpose

This folder is the structured knowledge base for the Nurtly project.

It is intended to become the single place where core product knowledge is stored in a clean, stable, and machine-readable format. The goal is not only to document the project for humans, but also to prepare the repository for future AI-assisted workflows such as RAG, feature planning, automated product review, architecture reasoning, and implementation support.

The knowledge base should help answer questions such as:

- What is Nurtly?
- Who is it for?
- What is included in the MVP?
- What decisions have already been made?
- What assumptions still need validation?
- How should future features be evaluated?
- What should AI agents know before working on the project?

## Important rule

This knowledge base is not perfect and is not final.

The first version is based on the current project context and historical planning discussions. Some sections are intentionally marked as assumptions or items requiring review. This is expected. The purpose of v1 is to create a useful foundation that can be improved during real project work.

## Confidence levels

Each document may use the following confidence levels:

- High: strongly established through prior project discussions or product decisions.
- Medium: likely accurate, but should be reviewed when the related area is actively developed.
- Low: hypothesis, draft direction, or placeholder for future validation.

## Document structure

- 01-product-vision.md — product purpose, mission, target users, positioning.
- 02-product-principles.md — product rules and decision filters.
- 03-user-personas.md — initial user groups and needs.
- 04-mvp-scope.md — current MVP boundaries and priorities.
- 05-feature-catalog.md — known product areas and feature candidates.
- 06-architecture.md — technical and architectural assumptions.
- 07-decisions.md — key product and technical decisions.
- 08-roadmap.md — staged development direction.
- 09-competitor-research.md — competitor-inspired observations.
- 10-privacy-and-compliance.md — privacy-first assumptions.
- 11-design-principles.md — product look, feel, UX rules.
- 12-monetization.md — monetization hypotheses.
- 13-project-history.md — historical context and evolution.
- 99-chatgpt-project-context.md — compact AI-agent context file.

## Maintenance rules

When a major product, technical, or business decision is made, update:

1. 07-decisions.md
2. The relevant topic document
3. 99-chatgpt-project-context.md if the decision changes how AI agents should understand the project

When something is uncertain, mark it clearly instead of pretending it is confirmed.

## Future RAG usage

This folder is designed to be indexed by a future RAG system.

Recommended RAG behavior:

- Prefer documents in this folder over chat history.
- Treat decision records as more authoritative than exploratory notes.
- Use confidence levels when answering.
- Cite the source document and section where possible.
- Do not treat assumptions as confirmed facts.
