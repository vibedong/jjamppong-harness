# Domain Docs

This harness uses a single-context documentation layout.

Required files:

- Root glossary: `CONTEXT.md`
- Architecture decisions: `harness/docs/adr/`

Consumer rules:

- `CONTEXT.md` is a glossary, not a PRD or scratch pad.
- ADRs are for decisions that are hard to reverse, surprising without context, and chosen after a real trade-off.
- Do not create ADRs for routine implementation details.
