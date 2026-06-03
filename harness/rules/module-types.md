# Module Types

## Principle

This harness does not ship fixed module type names.

Each project defines its own module types and folder standards through the Full Workflow.

Module structure design is a substantive planning decision inside the Full Workflow.

It is handled by the Module Structure Gate, not by an ad hoc side flow.

When a project has no approved module structure, the first product request uses the Module Structure Gate before product PRD, issue decomposition, writing plans, module folders, or product code.

## When To Use This Rule

Read this file when:

- Starting module structure design
- Creating a new module
- Changing module folders
- Changing module type names
- Deciding whether a folder is standard or project-specific

## Required Process

Module type and folder standards are substantive work.

They must follow:

```text
Request Intake
-> setup-matt-pocock-skills Readiness Check
-> Grill Routing And Completion Gate
-> Grill Result Record
-> Module Structure Gate
-> to-prd
-> User PRD Approval
-> to-issues
-> User Issue Approval
-> Task Brief
-> Superpowers Writing Plans
-> Mandatory Plan Review Question
-> Implementation / Apply
-> Verification
-> ce-compound
-> Archive Task Artifacts
-> Learning Update Question
```

## Output Location

Record approved module type and folder standards in:

```text
harness/state/module-structure.md
```

If the request cannot create or change product module folders or product code, record `Module Structure Gate: not applicable` in `harness/docs/tasks/active/<slug>/grill.md` and do not ask module-structure questions.

## Ledger Requirement

Module structure approval must be traceable to the active task gate ledger.

For the task that creates or changes module structure, the task gate ledger must contain `Gate id: module_structure` with `Status: approved` before `harness/state/module-structure.md` is treated as approved.

Future tasks may rely on `harness/state/module-structure.md` as the long-lived module structure record, but they must record one of these task-local entries before product PRD drafting:

- `Gate id: module_structure` with `Status: existing-approved`: existing approved structure applies.
- `Gate id: module_structure` with `Status: approved`: this task approved a new or changed structure.
- `Gate id: module_structure` with `Status: not-applicable`: this task cannot create or change product module folders or product code.

The state file records the approved structure. The task ledger records the user response that opened the gate.

## Required Content

`harness/state/module-structure.md` must record:

- Project module types
- Folder set for each module type
- Active modules
- Deferred modules
- Any extra folder and the reason it exists

## Creation Rule

Do not create a module under `modules/` unless its module type and folder set are recorded in `harness/state/module-structure.md`.

## Template Rule

Every module starts from:

```text
module-template/MODULE.md
module-template/README.md
```

Then the approved folder set from `harness/state/module-structure.md` is added.
