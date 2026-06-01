# Module Types

## Principle

This harness does not ship fixed module type names.

Each project defines its own module types and folder standards through the Full Workflow.

Module structure design is not a separate workflow stage; it is a substantive task that uses the Full Workflow.

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
-> OuroSuper Planning
-> Superpowers Writing Plans
-> Mandatory Plan Review Question
-> Implementation / Apply
-> Verification
-> ce-compound
-> Learning Update Question
-> Optional Handoff Update
```

## Output Location

Record approved module type and folder standards in:

```text
harness/state/module-structure.md
```

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
