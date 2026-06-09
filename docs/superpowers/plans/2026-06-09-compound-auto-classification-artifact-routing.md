# Compound Auto Classification And Artifact Routing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Jjamppong Harness record reusable learning candidates automatically and force each gate/skill to read the artifacts it actually depends on.

**Architecture:** Add two contract files: one registry for artifact roles and one map from gates to required artifact reads/writes. Extend task templates for learning capture and compound review, then make `verify` and `doctor` enforce read receipts and block long-term solution writes without compound review.

**Tech Stack:** Node.js CommonJS for `verify`/`doctor`/`lifecycle`, YAML contract files parsed by small in-repo line parser, PowerShell contract regression tests.

---

## User-Facing Success Criteria

This plan is not successful merely because new files exist. It is successful only if these scenarios work in a fresh installed project:

1. **Missed required artifact:** If an agent tries `writing_plan` without reading PRD, issues, module structure, and current planning context, `verify` fails with a clear `doctor` next action instead of letting the plan proceed.
2. **Repeated permission-boundary mistake:** If an agent performs or records a permission-like action without canonical approval evidence, the task creates a structured learning candidate during `compound_capture` so the user does not need to repeat the same correction next time.
3. **Explicit user correction:** If the user says the agent misunderstood the harness flow, a canonical `user_correction` event can be recorded, classified, shown in `learning-capture.md`, and reviewed before any long-term solution doc changes.
4. **No fake learning capture:** `compound_capture` cannot pass with an untouched starter `learning-capture.md`. It must prove either `candidate_count > 0` or `candidate_count: 0` with source hashes and a reason that no structured evidence was classifiable.

---

## File Structure

- Modify `harness/contracts/gate-contract-matrix.yaml`
  - Adds the missing `compound_review` gate so artifact routing and gate contracts agree.
- Create `harness/contracts/artifact-registry.yaml`
  - Defines artifact ids, paths, audience, language policy, lifecycle, canonical/projection role, and whether a read receipt is required.
- Create `harness/contracts/skill-artifact-map.yaml`
  - Defines gate-level `must_read`, `must_write`, and `must_not_read` artifact ids.
- Modify `harness/contracts/ledger-event.schema.yaml`
  - Adds `artifact_read`, `learning_candidate`, `user_correction`, and `compound_review_decision` event types, and tightens `artifact_written` payload expectations.
- Create `harness/templates/task/learning-capture.md`
  - Human-facing Korean starter document for reusable learning candidates.
- Create `harness/templates/task/compound-review.md`
  - Human-facing Korean starter document for deciding whether candidates become long-term solutions.
- Create `harness/docs/solutions/index.md`
  - Long-term solution index read by `compound_lookup`.
- Create `harness/docs/solutions/harness-drift-patterns.md`
  - Initial solution bucket for harness discipline drift.
- Create `harness/docs/solutions/installer-flow-patterns.md`
  - Initial solution bucket for install/update mistakes.
- Create `harness/docs/solutions/planning-gate-patterns.md`
  - Initial solution bucket for gate order and planning mistakes.
- Create `harness/docs/solutions/permission-boundary-patterns.md`
  - Initial solution bucket for approval/capability boundary mistakes.
- Modify `harness/state/compound.md`
  - Turns the empty placeholder into a short index pointing to solution files.
- Modify `harness/verify/verify.js`
  - Adds contract file checks, route parsing, active-task read receipt validation, and compound review protection.
- Modify `harness/doctor/doctor.js`
  - Adds next actions for the new verification failure ids.
- Create `harness/lifecycle/learning-classifier.js`
  - Classifies structured gate, permission, verification, and correction evidence into compound learning candidates.
- Modify `harness/lifecycle/lifecycle.js`
  - Adds a `capture-learning` command that writes `learning-capture.md` from structured candidate data.
- Modify `AGENTS.md`
  - Adds the artifact registry and skill artifact map to the first required read surface.
- Modify `harness/rules/workflow.md`
  - Documents artifact routing and compound automatic classification in the human-readable projection.
- Modify `harness/rules/rules.md`
  - Adds operational rules agents must follow before using gates/skills.
- Modify `README.md`
  - Adds beginner-friendly Korean explanation of automatic learning and why read receipts exist.
- Modify `tests/contracts/run-all.ps1`
  - Runs the new artifact routing contract test.
- Create `tests/contracts/test-artifact-routing-contracts.ps1`
  - Proves contract files, templates, rule docs, and regression ids exist.
- Modify `tests/contracts/test-verify-doctor.ps1`
  - Proves missing read receipts fail, valid read receipts pass, and solution writes require compound review.
- Modify `tests/contracts/test-lifecycle-templates.ps1`
  - Proves new task skeletons include learning capture and compound review templates.
- Create `tests/contracts/test-learning-classifier.ps1`
  - Proves automatic classification works from structured evidence and does not read raw transcripts.
- Modify `tests/contracts/test-workflow-rules.ps1`
  - Proves user-facing rule projections mention artifact routing and compound review.
- Modify `tests/contracts/regression-catalog.yaml`
  - Adds regression ids T041-T044.
- Modify `tests/contracts/verify-coverage-map.yaml`
  - Maps new regressions to verify checks.
- Modify `tests/fixtures/contracts/required-p0-regressions.txt`
  - Adds new P0 regression ids so required P0 coverage cannot drift.
- Modify `tests/contracts/test-agents-readme.ps1`
  - Proves `AGENTS.md` routes agents to the new artifact contracts.
- Modify `tests/contracts/test-release-candidate.ps1`
  - Proves release assertions include new contract, template, and solution surfaces.
- Modify `harness/release/SOURCE-MANIFEST.md`
  - Adds artifact routing and solution docs to canonical release surfaces.
- Modify `harness/release/RELEASE-NOTES.md`
  - Notes the new compound artifact routing behavior.
- Modify `harness/release/CHECKSUMS.sha256`
  - Regenerates release checksums after all source changes.

---

## Review Corrections Applied Before Implementation

CEO and Eng review both found that the first plan had the right direction but weak enforcement. These corrections are part of this plan and override any older step that conflicts.

1. `artifact_read` must not be mere self-attestation. For file-backed artifacts, verify resolves the path from `artifact-registry.yaml`, checks the file exists, recomputes SHA-256, and rejects stale hash, wrong path, wrong gate, wrong task, unknown artifact id, and malformed payload.
2. `skill-artifact-map.yaml` is not a second source of truth. Tests must prove every mapped gate exists in `gate-contract-matrix.yaml`, every mapped artifact exists in `artifact-registry.yaml`, and the map does not grant capabilities, transitions, or broad writes beyond the gate matrix.
3. Every non-exempt gate in `gate-contract-matrix.yaml` must have a routing entry in `skill-artifact-map.yaml`. If a gate truly has no task-local artifact obligation, represent it with an empty route rather than letting verify fail unknown valid gates.
4. `must_read`, `must_write`, and `must_not_read` are all enforced. `must_read` artifacts with `read_receipt_required: true` require receipts; non-receipt core state artifacts stay in the map for routing but are verified by their own core checks. `must_write` requires a gate-scoped `artifact_written` event, not just a pre-existing template file, except core state projections (`events_log`, `active_task_events`, `task_yaml`) that are already verified by active-task existence/hash-chain checks.
5. `compound_review` promotion is candidate-, path-, approval-, and order-scoped. A solution write is allowed only when a prior `compound_review_decision` references the same candidate as the `artifact_written` event, the exact `target_solution_path`, includes `user_approval_event_id`, and has decision `promote` or `merge_existing`.
6. `compound_capture` must create classification candidates from structured evidence only: verification failures, gate-order violations, permission-boundary failures, and explicit correction events in canonical event data. It must not classify from raw transcript text.
7. `compound_capture` cannot pass with a stale starter file. It must record `candidate_count`, source verify/event hashes, and either generated candidates or an explicit no-candidate reason.
8. `AGENTS.md` must be updated after contracts/tests exist so future agents read the new routing layer from the first invocation surface.
9. Git commits in this plan are optional checkpoints only. Do not run `git commit` unless the user explicitly approves that exact action in the current chat.

## Parallelization Strategy

This plan has shared test and release files, so unconstrained parallel workers will conflict. Use these lanes only after Task 1 freezes artifact ids and regression ids.

| Lane | Workstream | Owns | Depends on |
| --- | --- | --- | --- |
| A | Contracts, parser, verify, doctor | `harness/contracts/`, `harness/verify/`, `harness/doctor/`, `tests/contracts/test-verify-doctor.ps1` | Task 1 |
| B | Templates, solution docs, human docs | `harness/templates/`, `harness/docs/solutions/`, `harness/state/compound.md`, `README.md` | Task 1 artifact ids |
| C | Lifecycle classifier | `harness/lifecycle/learning-classifier.js`, `harness/lifecycle/lifecycle.js`, `tests/contracts/test-learning-classifier.ps1` | A event schema + B templates |
| D | Runtime entrypoint and rule projections | `AGENTS.md`, `harness/rules/`, `tests/contracts/test-agents-readme.ps1`, `tests/contracts/test-workflow-rules.ps1` | A contract names |
| E | Release metadata | `harness/release/`, `tests/contracts/test-release-candidate.ps1` | A+B+C+D passing |

Keep these files sequential, not parallel: `tests/contracts/regression-catalog.yaml`, `tests/contracts/verify-coverage-map.yaml`, `tests/fixtures/contracts/required-p0-regressions.txt`, and `harness/release/CHECKSUMS.sha256`.

Checkpoint commits are optional. Run a checkpoint commit only when the user explicitly approves that exact checkpoint commit in the current chat. If not approved, leave changes in the working tree and report exact files changed.

### Task 1: Add Regression Tests For Artifact Routing Contracts

**Files:**
- Create: `tests/contracts/test-artifact-routing-contracts.ps1`
- Modify: `tests/contracts/run-all.ps1`
- Modify: `tests/contracts/regression-catalog.yaml`
- Modify: `tests/contracts/verify-coverage-map.yaml`

- [ ] **Step 1: Create the failing artifact routing contract test**

Create `tests/contracts/test-artifact-routing-contracts.ps1`:

```powershell
param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Check {
  param([bool]$Condition, [string]$Message)
  $script:checks += 1
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

$artifactRegistryPath = Join-Path $RepoRoot 'harness\contracts\artifact-registry.yaml'
$skillMapPath = Join-Path $RepoRoot 'harness\contracts\skill-artifact-map.yaml'
$learningTemplatePath = Join-Path $RepoRoot 'harness\templates\task\learning-capture.md'
$compoundReviewTemplatePath = Join-Path $RepoRoot 'harness\templates\task\compound-review.md'
$solutionsIndexPath = Join-Path $RepoRoot 'harness\docs\solutions\index.md'
$workflowPath = Join-Path $RepoRoot 'harness\rules\workflow.md'
$rulesPath = Join-Path $RepoRoot 'harness\rules\rules.md'
$catalogPath = Join-Path $RepoRoot 'tests\contracts\regression-catalog.yaml'
$coveragePath = Join-Path $RepoRoot 'tests\contracts\verify-coverage-map.yaml'

foreach ($path in @(
  $artifactRegistryPath,
  $skillMapPath,
  $learningTemplatePath,
  $compoundReviewTemplatePath,
  $solutionsIndexPath
)) {
  Assert-Check (Test-Path -LiteralPath $path) "Missing required artifact routing surface: $path"
}

if (Test-Path -LiteralPath $artifactRegistryPath) {
  $registry = Get-Content -LiteralPath $artifactRegistryPath -Raw
  foreach ($token in @(
    'planning_prd:',
    'planning_issues:',
    'planning_module_structure:',
    'planning_writing_plan:',
    'learning_capture:',
    'compound_review:',
    'compound_state:',
    'solutions_index:',
    'audience: human',
    'language: user',
    'canonical: true',
    'read_receipt_required: true'
  )) {
    Assert-Check ($registry.Contains($token)) "artifact-registry.yaml missing token: $token"
  }
}

if (Test-Path -LiteralPath $skillMapPath) {
  $skillMap = Get-Content -LiteralPath $skillMapPath -Raw
  foreach ($token in @(
    'writing_plan:',
    'planning_current_context',
    'planning_prd',
    'planning_issues',
    'planning_module_structure',
    'compound_lookup:',
    'compound_state',
    'solutions_index',
    'compound_capture:',
    'learning_capture',
    'compound_review:'
  )) {
    Assert-Check ($skillMap.Contains($token)) "skill-artifact-map.yaml missing token: $token"
  }
}

foreach ($solutionFile in @(
  'harness\docs\solutions\harness-drift-patterns.md',
  'harness\docs\solutions\installer-flow-patterns.md',
  'harness\docs\solutions\planning-gate-patterns.md',
  'harness\docs\solutions\permission-boundary-patterns.md'
)) {
  Assert-Check (Test-Path -LiteralPath (Join-Path $RepoRoot $solutionFile)) "Missing solution category file: $solutionFile"
}

$workflow = Get-Content -LiteralPath $workflowPath -Raw
foreach ($token in @(
  'Artifact Routing',
  'Read receipts',
  'compound_lookup reads solution indexes before detailed solution files',
  'compound_capture records candidates',
  'compound_review decides long-term promotion'
)) {
  Assert-Check ($workflow.Contains($token)) "workflow.md missing artifact routing token: $token"
}

$rules = Get-Content -LiteralPath $rulesPath -Raw
foreach ($token in @(
  'Before a gate or skill starts, check harness/contracts/skill-artifact-map.yaml',
  'Do not rely on memory for required artifacts',
  'Record artifact_read events for required artifact reads',
  'Do not promote learning candidates into harness/docs/solutions without compound_review'
)) {
  Assert-Check ($rules.Contains($token)) "rules.md missing artifact routing token: $token"
}

$catalog = Get-Content -LiteralPath $catalogPath -Raw
foreach ($token in @('T041', 'T042', 'T043', 'T044')) {
  Assert-Check ($catalog.Contains($token)) "regression catalog missing $token"
}

$coverage = Get-Content -LiteralPath $coveragePath -Raw
foreach ($token in @(
  'artifact_routing_contract',
  'artifact_read_receipts',
  'compound_review_promotion_gate'
)) {
  Assert-Check ($coverage.Contains($token)) "verify coverage map missing token: $token"
}

if ($failures.Count -gt 0) {
  Write-Output "artifact routing contract tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "artifact routing contract tests passed $checks checks."
```

- [ ] **Step 2: Add the new test to the contract suite**

In `tests/contracts/run-all.ps1`, insert `test-artifact-routing-contracts.ps1` immediately after `run-contract-regression.ps1`:

```powershell
$scripts = @(
  'run-contract-regression.ps1',
  'test-artifact-routing-contracts.ps1',
  'test-permission-decision.ps1',
  'test-verify-doctor.ps1',
  'test-installer-package.ps1',
  'test-lifecycle-templates.ps1',
  'test-workflow-rules.ps1',
  'test-agents-readme.ps1',
  'test-release-candidate.ps1'
)
```

- [ ] **Step 3: Add regression ids**

Append these entries to `tests/contracts/regression-catalog.yaml` under `regressions:`:

```yaml
  - id: T041
    priority: P0
    title: writing_plan requires read receipts for PRD issues and module structure
    expected: verify_fail_without_required_artifact_read_receipts
  - id: T042
    priority: P1
    title: compound capture writes learning candidates before archive
    expected: require_learning_capture_artifact
  - id: T043
    priority: P0
    title: long-term solution writes require compound_review approval
    expected: verify_fail_solution_write_without_compound_review
  - id: T044
    priority: P1
    title: compound learning artifacts are human-facing user-language documents
    expected: require_user_language_learning_templates
```

- [ ] **Step 4: Add coverage mapping**

In `tests/contracts/verify-coverage-map.yaml`, extend `compound_contract` to include the new tests and checks:

```yaml
  compound_contract:
    tests: [T039, T040, T041, T042, T043, T044]
    verify_checks:
      - compound_proposal_only_for_rule_change
      - compound_lookup_limited_body_reads
      - artifact_routing_contract
      - artifact_read_receipts
      - compound_review_promotion_gate
      - learning_capture_template
```

- [ ] **Step 5: Add required P0 regression fixture entries**

Append these ids to `tests/fixtures/contracts/required-p0-regressions.txt`:

```text
T041
T043
```

Expected behavior: `run-contract-regression.ps1` must fail if either P0 id is missing from `regression-catalog.yaml`.

- [ ] **Step 6: Extend contract test beyond token checks**

In `tests/contracts/test-artifact-routing-contracts.ps1`, add structural assertions after the token checks. This test intentionally uses line-oriented checks because no package install is approved.

```powershell
function Get-YamlTopLevelKeys {
  param([string]$Text, [string]$Parent)
  $lines = $Text -split "`r?`n"
  $inside = $false
  $keys = New-Object System.Collections.Generic.HashSet[string]
  foreach ($line in $lines) {
    if ($line -match "^$Parent`:") {
      $inside = $true
      continue
    }
    if ($inside -and $line -match '^[a-zA-Z0-9_-]+:') {
      break
    }
    if ($inside -and $line -match '^  ([a-zA-Z0-9_-]+):') {
      [void]$keys.Add($Matches[1])
    }
  }
  return $keys
}

if ((Test-Path -LiteralPath $artifactRegistryPath) -and (Test-Path -LiteralPath $skillMapPath)) {
  $registry = Get-Content -LiteralPath $artifactRegistryPath -Raw
  $skillMap = Get-Content -LiteralPath $skillMapPath -Raw
  $gateMatrix = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\contracts\gate-contract-matrix.yaml') -Raw

  $artifactIds = Get-YamlTopLevelKeys -Text $registry -Parent 'artifacts'
  $gateIds = Get-YamlTopLevelKeys -Text $skillMap -Parent 'gates'
  $matrixGateIds = Get-YamlTopLevelKeys -Text $gateMatrix -Parent 'gates'
  foreach ($gateId in $gateIds) {
    Assert-Check ($gateMatrix.Contains("  $gateId`:")) "skill-artifact-map gate is missing from gate-contract-matrix: $gateId"
  }
  foreach ($gateId in $matrixGateIds) {
    Assert-Check ($gateIds.Contains($gateId)) "gate-contract-matrix gate is missing from skill-artifact-map: $gateId"
  }

  $artifactRefs = [regex]::Matches($skillMap, '      - ([a-zA-Z0-9_-]+)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
  foreach ($artifactRef in $artifactRefs) {
    Assert-Check ($artifactIds.Contains($artifactRef)) "skill-artifact-map references unknown artifact id: $artifactRef"
  }

  foreach ($forbiddenToken in @('effect_capabilities:', 'transition_to:', 'installer.install', 'git.push')) {
    Assert-Check (-not $skillMap.Contains($forbiddenToken)) "skill-artifact-map must not grant workflow or capability power: $forbiddenToken"
  }
}
```

- [ ] **Step 7: Run the new test and confirm it fails**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-artifact-routing-contracts.ps1
```

Expected: FAIL because `artifact-registry.yaml`, `skill-artifact-map.yaml`, learning templates, and solution docs do not exist yet.

- [ ] **Step 8: Optional checkpoint after explicit git approval**

Only run this after the user explicitly approves this exact git operation in the current chat:

```powershell
git add tests/contracts/test-artifact-routing-contracts.ps1 tests/contracts/run-all.ps1 tests/contracts/regression-catalog.yaml tests/contracts/verify-coverage-map.yaml
git add tests/fixtures/contracts/required-p0-regressions.txt
git commit -m "test: add artifact routing regressions"
```

---

### Task 2: Add Artifact Registry And Skill Artifact Map Contracts

**Files:**
- Modify: `harness/contracts/gate-contract-matrix.yaml`
- Create: `harness/contracts/artifact-registry.yaml`
- Create: `harness/contracts/skill-artifact-map.yaml`
- Modify: `harness/contracts/ledger-event.schema.yaml`
- Modify: `harness/verify/verify.js`

- [ ] **Step 0: Add missing `compound_review` gate to the gate matrix**

In `harness/contracts/gate-contract-matrix.yaml`, add this gate between `compound_capture` and `proposal`:

```yaml
  compound_review:
    user_label: 배운 점 장기반영 검토
    previous: [compound_capture]
    reads: [learning_capture, compound_state, solutions_index]
    writes: [compound-review.md, events.jsonl]
    required_artifacts: [compound_review_decision]
    forbidden: [silent_solution_promotion, raw_transcript_storage]
    transition_to: [archive, proposal]
    verify_ids: [T042]
```

Rationale: `skill-artifact-map.yaml` references `compound_review`; the gate matrix must own that gate first.

- [ ] **Step 1: Create `artifact-registry.yaml`**

Create `harness/contracts/artifact-registry.yaml`:

```yaml
version: 0.1.0
name: jjamppong-harness-artifact-registry
notes:
  - Artifacts describe durable planning, permission, verification, and compound surfaces.
  - Human-facing artifacts use the current user's language.
  - Machine-readable artifacts keep stable schema keys.
  - Dynamic task paths are relative to harness/docs/tasks/active/{task_id}/ unless root_relative is true.

artifacts:
  user_prompt:
    path: chat:user_prompt
    audience: human
    language: user
    lifecycle: conversation
    purpose: User's current request.
    canonical: true
    read_receipt_required: true

  prior_user_answers:
    path: chat:prior_user_answers
    audience: human
    language: user
    lifecycle: conversation
    purpose: User answers collected during the current gate.
    canonical: true
    read_receipt_required: true

  events_log:
    path: events.jsonl
    audience: machine
    language: stable_schema
    lifecycle: active_task
    purpose: Canonical gate, approval, permission, artifact, and verification event log.
    canonical: true
    read_receipt_required: false

  active_task_events:
    path: events.jsonl
    audience: machine
    language: stable_schema
    lifecycle: active_task
    purpose: Canonical event history for the active task.
    canonical: true
    read_receipt_required: false

  task_yaml:
    path: task.yaml
    audience: machine
    language: stable_schema
    lifecycle: active_task
    purpose: Derived cache projection of current task status.
    canonical: false
    read_receipt_required: false

  gate_ledger:
    path: gate-ledger.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Human-readable projection of approvals and gate state.
    canonical: false
    read_receipt_required: false

  planning_current_context:
    path: planning/00-current-planning-context.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Compiled planning context with source hashes.
    canonical: false
    read_receipt_required: true

  planning_grill_summary:
    path: planning/01-grill-summary.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Summary of user intent questions and answers.
    canonical: false
    read_receipt_required: true

  planning_research_summary:
    path: planning/02-research-summary.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Evidence and research summary.
    canonical: false
    read_receipt_required: true

  planning_compound_lookup:
    path: planning/02b-compound-lookup.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Relevant previous learning selected for the current task.
    canonical: false
    read_receipt_required: true

  planning_architecture_orientation:
    path: planning/02c-architecture-orientation.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Plain-language technical orientation.
    canonical: false
    read_receipt_required: true

  planning_prd:
    path: planning/03-prd.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Approved product requirements.
    canonical: false
    read_receipt_required: true

  planning_issues:
    path: planning/04-issues.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Work breakdown from the approved PRD.
    canonical: false
    read_receipt_required: true

  planning_module_structure:
    path: planning/05-module-structure.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Approved module and folder structure.
    canonical: false
    read_receipt_required: true

  planning_writing_plan:
    path: planning/06-writing-plan.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Implementation plan.
    canonical: false
    read_receipt_required: true

  planning_plan_review:
    path: planning/07-plan-review.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Review of the implementation plan.
    canonical: false
    read_receipt_required: true

  verification:
    path: verification.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Verification commands, expected results, actual results, and risk status.
    canonical: false
    read_receipt_required: true

  acceptance:
    path: acceptance.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: User acceptance, deferral, or blocked status.
    canonical: false
    read_receipt_required: true

  learning_capture:
    path: learning-capture.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Candidate reusable lessons classified during the task.
    canonical: false
    read_receipt_required: true

  compound_review:
    path: compound-review.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Review decision for promoting learning candidates into long-term solutions.
    canonical: false
    read_receipt_required: true

  compound_state:
    path: harness/state/compound.md
    root_relative: true
    audience: human
    language: user
    lifecycle: long_term
    purpose: Short index of reusable learning documents.
    canonical: false
    read_receipt_required: true

  solutions_index:
    path: harness/docs/solutions/index.md
    root_relative: true
    audience: human
    language: user
    lifecycle: long_term
    purpose: Long-term solution index.
    canonical: false
    read_receipt_required: true

  selected_relevant_solutions:
    path: harness/docs/solutions/*.md
    root_relative: true
    audience: human
    language: user
    lifecycle: long_term
    purpose: Narrowly selected solution summaries relevant to the current task.
    canonical: false
    read_receipt_required: true

  handoff_summary:
    path: handoff.md
    root_relative: true
    audience: human
    language: user
    lifecycle: project
    purpose: Next-chat handoff summary and restart prompt.
    canonical: false
    read_receipt_required: true

  project_source_before_approval:
    path: project_source:before_grill_or_approval
    audience: machine
    language: stable_schema
    lifecycle: project
    purpose: Forbidden early project-source read before the planning gate allows it.
    canonical: false
    read_receipt_required: false
```

- [ ] **Step 2: Create `skill-artifact-map.yaml`**

Create `harness/contracts/skill-artifact-map.yaml`:

```yaml
version: 0.1.0
name: jjamppong-harness-skill-artifact-map
notes:
  - This file refines gate-contract-matrix.yaml with artifact-level read and write requirements.
  - Missing or ambiguous artifact receipts fail closed for P0 gates.
  - It does not grant capability approvals.

gates:
  install:
    must_write:

  intake:
    must_read:
      - user_prompt
    must_write:
      - events_log
      - task_yaml
    must_not_read:
      - project_source_before_approval

  grill:
    must_read:
      - user_prompt
      - prior_user_answers
    must_write:
      - planning_grill_summary
      - events_log
    must_not_read:
      - project_source_before_approval

  research:
    must_read:
      - planning_grill_summary
    must_write:
      - planning_research_summary
      - events_log

  compound_lookup:
    must_read:
      - compound_state
      - solutions_index
    optional_read:
      - selected_relevant_solutions
    must_write:
      - planning_compound_lookup

  architecture_orientation:
    must_read:
      - planning_grill_summary
      - planning_research_summary
    must_write:
      - planning_architecture_orientation

  prd:
    must_read:
      - planning_grill_summary
      - planning_research_summary
    optional_read:
      - planning_compound_lookup
      - planning_architecture_orientation
    must_write:
      - planning_prd

  issues:
    must_read:
      - planning_prd
    must_write:
      - planning_issues

  module_structure:
    must_read:
      - planning_prd
      - planning_issues
    must_write:
      - planning_module_structure

  writing_plan:
    must_read:
      - planning_current_context
      - planning_prd
      - planning_issues
      - planning_module_structure
    must_write:
      - planning_writing_plan

  plan_review:
    must_read:
      - planning_writing_plan
    must_write:
      - planning_plan_review

  folder_skeleton:
    must_read:
      - planning_module_structure
    must_write:
      - events_log

  implementation:
    must_read:
      - planning_prd
      - planning_issues
      - planning_module_structure
      - planning_writing_plan
      - planning_plan_review
      - events_log
    must_write:
      - events_log

  work:
    must_read:
      - events_log
    must_write:
      - events_log

  verification:
    must_read:
      - events_log
    must_write:
      - verification

  acceptance:
    must_read:
      - verification
    must_write:
      - acceptance

  compound_capture:
    must_read:
      - verification
      - active_task_events
    optional_read:
      - acceptance
    must_write:
      - learning_capture

  compound_review:
    must_read:
      - learning_capture
      - compound_state
      - solutions_index
    must_write:
      - compound_review
    may_write_long_term:
      - solutions_index
      - selected_relevant_solutions
      - compound_state

  proposal:
    must_read:
      - active_task_events
    must_write:
      - events_log

  archive:
    must_read:
      - verification
      - learning_capture
    optional_read:
      - compound_review
    must_write:
      - events_log

  handoff:
    must_read:
      - active_task_events
    must_write:
      - handoff_summary
```

- [ ] **Step 3: Add event types to `ledger-event.schema.yaml`**

In `harness/contracts/ledger-event.schema.yaml`, add these entries under `fields.event_type.enum`:

```yaml
      - artifact_read
      - learning_candidate
      - user_correction
      - compound_review_decision
```

Also add payload schemas:

```yaml
  artifact_read:
    required: [gate_id, artifact_id, path, hash, proof_type]
    fields:
      gate_id: {type: string}
      artifact_id: {type: string}
      path: {type: string}
      hash: {type: string}
      proof_type: {enum: [file_sha256, pseudo_artifact_marker]}
  artifact_written:
    required: [gate_id, artifact_id, path, hash]
    fields:
      gate_id: {type: string}
      artifact_id: {type: string}
      path: {type: string}
      hash: {type: string}
      candidate_ref: {type: string, required: false}
  learning_candidate:
    required: [candidate_ref, category, summary, evidence, recurrence_prevention]
    fields:
      candidate_ref: {type: string}
      category: {type: string}
      summary: {type: string}
      evidence: {type: string}
      recurrence_prevention: {type: string}
      promotion_recommendation: {enum: [promote, keep_active_only, merge_existing, discard]}
  user_correction:
    required: [category, summary, correction_quote, recurrence_prevention, source_event_id]
    fields:
      category: {type: string}
      summary: {type: string}
      correction_quote: {type: string}
      recurrence_prevention: {type: string}
      source_event_id: {type: string}
  compound_review_decision:
    required: [candidate_ref, decision, reason, user_approval_event_id]
    fields:
      candidate_ref: {type: string}
      decision: {enum: [promote, keep_active_only, merge_existing, discard]}
      reason: {type: string}
      target_solution_path: {type: string}
      user_approval_event_id: {type: string}
```

Path rule: `artifact_read.path`, `artifact_written.path`, and `compound_review_decision.target_solution_path` use normalized repo-relative paths with `/` separators, never machine-local absolute paths. Pseudo artifacts keep their pseudo path, such as `chat:user_prompt`.

- [ ] **Step 4: Register the new contracts in verify**

In `harness/verify/verify.js`, extend `REQUIRED_CONTRACTS`:

```js
const REQUIRED_CONTRACTS = [
  'harness/contracts/capability-catalog.yaml',
  'harness/contracts/gate-contract-matrix.yaml',
  'harness/contracts/ledger-event.schema.yaml',
  'harness/contracts/permission-decision.schema.yaml',
  'harness/contracts/path-policy.schema.yaml',
  'harness/contracts/task.schema.yaml',
  'harness/contracts/installer-contract.yaml',
  'harness/contracts/artifact-registry.yaml',
  'harness/contracts/skill-artifact-map.yaml',
];
```

- [ ] **Step 5: Run the artifact contract test**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-artifact-routing-contracts.ps1
```

Expected: still FAIL because templates, docs, and rule projections are not present yet.

- [ ] **Step 6: Optional checkpoint after explicit git approval**

Only run this after the user explicitly approves this exact git operation in the current chat:

```powershell
git add harness/contracts/gate-contract-matrix.yaml harness/contracts/artifact-registry.yaml harness/contracts/skill-artifact-map.yaml harness/contracts/ledger-event.schema.yaml harness/verify/verify.js
git commit -m "feat: add artifact routing contracts"
```

---

### Task 3: Add Learning Templates And Long-Term Solution Indexes

**Files:**
- Create: `harness/templates/task/learning-capture.md`
- Create: `harness/templates/task/compound-review.md`
- Create: `harness/docs/solutions/index.md`
- Create: `harness/docs/solutions/harness-drift-patterns.md`
- Create: `harness/docs/solutions/installer-flow-patterns.md`
- Create: `harness/docs/solutions/planning-gate-patterns.md`
- Create: `harness/docs/solutions/permission-boundary-patterns.md`
- Modify: `harness/state/compound.md`
- Modify: `tests/contracts/test-lifecycle-templates.ps1`

- [ ] **Step 1: Add learning capture template**

Create `harness/templates/task/learning-capture.md`:

````markdown
# 배운 점 후보

이 문서는 이번 작업 중 재발방지에 쓸 수 있는 후보만 짧게 기록합니다.

raw 대화 전문을 저장하지 않습니다.

## Capture Metadata

candidate_count: 0
source_verify_hash:
source_events_hash:
no_candidate_reason:

## 자동분류 후보

아직 기록된 후보가 없습니다.

## 후보 작성 형식

```text
분류:
요약:
문제가 된 이유:
재발방지 후보:
관련 게이트:
관련 산출물:
장기 반영 추천: promote / keep_active_only / merge_existing / discard
```

## 장기 반영 원칙

- 이 파일에 적힌 후보는 바로 장기 규칙이 되지 않습니다.
- 장기 반영은 `compound-review.md`에서 검토합니다.
- `harness/docs/solutions/` 수정은 `compound_review` 결정 뒤에만 가능합니다.
````

- [ ] **Step 2: Add compound review template**

Create `harness/templates/task/compound-review.md`:

```markdown
# Compound Review

이 문서는 `learning-capture.md`의 후보를 장기 지식으로 반영할지 결정합니다.

## 검토 대상

- 후보 파일: `learning-capture.md`
- 장기 지식 인덱스: `harness/docs/solutions/index.md`
- 짧은 상태 인덱스: `harness/state/compound.md`

## 결정

아직 검토된 후보가 없습니다.

## 결정 형식

```text
후보:
결정: promote / keep_active_only / merge_existing / discard
이유:
반영할 장기 문서:
사용자 승인 근거:
```

## 안전 규칙

- 오탐은 장기 지식으로 반영하지 않습니다.
- 한 번의 특이한 사건은 일반 규칙으로 승격하지 않습니다.
- 사용자 승인 없이 live harness rule을 직접 수정하지 않습니다.
```

- [ ] **Step 3: Add solution index**

Create `harness/docs/solutions/index.md`:

```markdown
# Compound Solutions Index

다음 작업에서 `compound_lookup`이 먼저 읽는 장기 지식 인덱스입니다.

긴 본문을 한 번에 읽지 않습니다. 이 인덱스에서 관련 항목을 고른 뒤 필요한 solution 파일만 좁게 읽습니다.

## 카테고리

- [Harness drift patterns](harness-drift-patterns.md): vowline, grill, writing plan, approval gate 같은 하네스 흐름 이탈
- [Installer flow patterns](installer-flow-patterns.md): 설치, 업데이트, origin, npm, 중첩 폴더 문제
- [Planning gate patterns](planning-gate-patterns.md): gate 순서, grill-with-docs 순서, module_structure/folder_skeleton 혼동
- [Permission boundary patterns](permission-boundary-patterns.md): 짧은 승인, package install, live access, commit, push 범위 오해

## 승격 규칙

`learning-capture.md`의 후보는 `compound-review.md`에서 검토한 뒤에만 이 인덱스나 solution 파일로 승격합니다.
```

- [ ] **Step 4: Add initial solution category files**

Create `harness/docs/solutions/harness-drift-patterns.md`:

```markdown
# Harness Drift Patterns

## 목적

하네스가 기본 흐름을 벗어난 사례와 재발방지 패턴을 모읍니다.

## 현재 패턴

아직 승격된 패턴이 없습니다.

## 후보 예시

- `grill` 전에 프로젝트 구현 폴더를 먼저 읽음
- `writing_plan` 없이 구현으로 넘어감
- plan review 완료를 implementation approval로 오해함
- handoff를 만들고 다음 채팅용 입력 문구를 채팅에 출력하지 않음
```

Create `harness/docs/solutions/installer-flow-patterns.md`:

```markdown
# Installer Flow Patterns

## 목적

설치, 업데이트, origin, npm, 중첩 폴더 문제의 재발방지 패턴을 모읍니다.

## 현재 패턴

아직 승격된 패턴이 없습니다.

## 후보 예시

- 템플릿 저장소를 프로젝트 루트 하위에 중첩 클론함
- 설치만 요청했는데 planning task를 시작함
- 기존 `.git`과 origin 보존 규칙을 오해함
- npm 패키지 미공개 상태를 설치 실패가 아닌 다른 문제로 해석함
```

Create `harness/docs/solutions/planning-gate-patterns.md`:

```markdown
# Planning Gate Patterns

## 목적

기획 게이트 순서와 산출물 흐름 문제의 재발방지 패턴을 모읍니다.

## 현재 패턴

아직 승격된 패턴이 없습니다.

## 후보 예시

- `grill-with-docs`를 `grill me` 완료 전에 실행함
- `module_structure` 승인만 받고 실제 폴더나 코드를 만듦
- `folder_skeleton`에서 실행 가능한 코드나 설정 파일을 만듦
- `writing_plan`이 PRD, 이슈, 모듈 구조를 읽지 않음
```

Create `harness/docs/solutions/permission-boundary-patterns.md`:

```markdown
# Permission Boundary Patterns

## 목적

승인 범위, capability, git, package, live access 문제의 재발방지 패턴을 모읍니다.

## 현재 패턴

아직 승격된 패턴이 없습니다.

## 후보 예시

- "좋아"를 직전 gate 범위보다 넓게 해석함
- package install을 별도 승인 없이 실행함
- commit과 push를 같은 승인으로 처리함
- live target access를 일반 web research와 혼동함
```

- [ ] **Step 5: Update compound state index**

Replace `harness/state/compound.md` with:

```markdown
# Compound State

이 파일은 장기 지식의 짧은 인덱스입니다.

긴 본문은 `harness/docs/solutions/` 아래 solution 문서에 둡니다.

## Solution Index

- `harness/docs/solutions/index.md`

## Current Solution Buckets

- `harness/docs/solutions/harness-drift-patterns.md`
- `harness/docs/solutions/installer-flow-patterns.md`
- `harness/docs/solutions/planning-gate-patterns.md`
- `harness/docs/solutions/permission-boundary-patterns.md`

## Lookup Rule

새 작업의 `compound_lookup`은 이 파일과 solution index를 먼저 읽고, 관련 solution 파일만 좁게 읽습니다.
```

- [ ] **Step 6: Extend lifecycle template tests**

In `tests/contracts/test-lifecycle-templates.ps1`, add these files to the first template existence loop:

```powershell
  'harness/templates/task/learning-capture.md',
  'harness/templates/task/compound-review.md',
  'harness/docs/solutions/index.md',
  'harness/docs/solutions/harness-drift-patterns.md',
  'harness/docs/solutions/installer-flow-patterns.md',
  'harness/docs/solutions/planning-gate-patterns.md',
  'harness/docs/solutions/permission-boundary-patterns.md',
```

After the existing `implementation approval` checks, add:

```powershell
$learningTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\learning-capture.md') -Raw
Assert-Check ($learningTemplate.Contains('배운 점 후보')) 'learning-capture template must be user-facing Korean by default.'
Assert-Check ($learningTemplate.Contains('raw 대화 전문을 저장하지 않습니다')) 'learning-capture template must reject raw transcript storage.'
Assert-Check ($learningTemplate.Contains('candidate_count: 0')) 'learning-capture template must expose candidate_count metadata.'
Assert-Check ($learningTemplate.Contains('source_events_hash:')) 'learning-capture template must expose source event hash metadata.'
Assert-Check ($learningTemplate.Contains('compound-review.md')) 'learning-capture template must point to compound review.'

$compoundReviewTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\compound-review.md') -Raw
Assert-Check ($compoundReviewTemplate.Contains('Compound Review')) 'compound review template must exist.'
Assert-Check ($compoundReviewTemplate.Contains('promote / keep_active_only / merge_existing / discard')) 'compound review template must define decisions.'
Assert-Check ($compoundReviewTemplate.Contains('사용자 승인 없이 live harness rule을 직접 수정하지 않습니다')) 'compound review template must block unapproved live rule edits.'

$solutionsIndex = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\docs\solutions\index.md') -Raw
Assert-Check ($solutionsIndex.Contains('Compound Solutions Index')) 'solutions index must define compound solutions.'
Assert-Check ($solutionsIndex.Contains('harness-drift-patterns.md')) 'solutions index must link harness drift bucket.'
Assert-Check ($solutionsIndex.Contains('compound-review.md')) 'solutions index must require compound review before promotion.'
```

In the generated task skeleton loop, add `learning-capture.md` and `compound-review.md`:

```powershell
foreach ($file in @('task.yaml', 'events.jsonl', 'gate-ledger.md', 'planning-pack.md', 'planning\00-current-planning-context.md', 'planning\06-writing-plan.md', 'learning-capture.md', 'compound-review.md', 'archive-summary.md')) {
  Assert-Check (Test-Path -LiteralPath (Join-Path $taskRoot $file)) "create-task missing $file"
}
```

- [ ] **Step 7: Run template and artifact contract tests**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-lifecycle-templates.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-artifact-routing-contracts.ps1
```

Expected: `test-lifecycle-templates.ps1` PASS and `test-artifact-routing-contracts.ps1` still FAIL until rule docs are updated in a later task.

- [ ] **Step 8: Optional checkpoint after explicit git approval**

Only run this after the user explicitly approves this exact git operation in the current chat:

```powershell
git add harness/templates/task/learning-capture.md harness/templates/task/compound-review.md harness/docs/solutions/index.md harness/docs/solutions/harness-drift-patterns.md harness/docs/solutions/installer-flow-patterns.md harness/docs/solutions/planning-gate-patterns.md harness/docs/solutions/permission-boundary-patterns.md harness/state/compound.md tests/contracts/test-lifecycle-templates.ps1
git commit -m "feat: add compound learning templates"
```

---

### Task 4A: Add Structured Learning Classifier

**Files:**
- Create: `harness/lifecycle/learning-classifier.js`
- Modify: `harness/lifecycle/lifecycle.js`
- Create: `tests/contracts/test-learning-classifier.ps1`

- [ ] **Step 1: Write classifier tests**

Create `tests/contracts/test-learning-classifier.ps1`:

```powershell
param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$classifier = Join-Path $RepoRoot 'harness\lifecycle\learning-classifier.js'
$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Check {
  param([bool]$Condition, [string]$Message)
  $script:checks += 1
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

function Invoke-ClassifierPayload {
  param([hashtable]$Payload)
  $payload = $Payload | ConvertTo-Json -Depth 8 -Compress
  $output = $payload | node $classifier --stdin --json
  return ($output -join "`n") | ConvertFrom-Json
}

function Invoke-Classifier {
  param([object[]]$Events, [object[]]$Failures)
  return Invoke-ClassifierPayload -Payload @{ events = $Events; failures = $Failures }
}

$gateCandidate = Invoke-Classifier -Events @() -Failures @(@{ id = 'artifact_forbidden_read'; message = 'grill read project source too early' })
Assert-Check (@($gateCandidate.candidates | Where-Object { $_.category -eq 'gate-order' }).Count -eq 1) 'forbidden early read should classify as gate-order.'

$permissionCandidate = Invoke-Classifier -Events @() -Failures @(@{ id = 'projection_without_canonical_event'; message = 'permission-like projection without approval' })
Assert-Check (@($permissionCandidate.candidates | Where-Object { $_.category -eq 'permission-boundary' }).Count -eq 1) 'permission projection drift should classify as permission-boundary.'

$installCandidate = Invoke-Classifier -Events @() -Failures @(@{ id = 'nested_harness_folder'; message = 'nested jjamppong-harness folder' })
Assert-Check (@($installCandidate.candidates | Where-Object { $_.category -eq 'installer-flow' }).Count -eq 1) 'nested harness folder should classify as installer-flow.'

$noCandidate = Invoke-Classifier -Events @() -Failures @()
Assert-Check (@($noCandidate.candidates).Count -eq 0) 'no structured evidence should produce no learning candidates.'

$rawTranscriptIgnored = Invoke-ClassifierPayload -Payload @{ events = @(); failures = @(); raw_transcript = 'agent skipped grill and then user corrected it'; conversation = 'do not mine this' }
Assert-Check (@($rawTranscriptIgnored.candidates).Count -eq 0) 'raw transcript and conversation fields must not create candidates.'

$correctionCandidate = Invoke-Classifier -Events @(@{ event_id = 'evt-user-correction-1'; event_type = 'user_correction'; payload = @{ category = 'gate-order'; summary = 'Grill happened after docs lookup.'; correction_quote = 'grill me 먼저 해야지'; recurrence_prevention = 'Run grill before docs lookup.'; source_event_id = 'evt-source-1' } }) -Failures @()
Assert-Check (@($correctionCandidate.candidates | Where-Object { $_.category -eq 'gate-order' -and $_.candidate_ref }).Count -eq 1) 'canonical user_correction event should become a candidate with candidate_ref.'

$text = Get-Content -LiteralPath $classifier -Raw
Assert-Check (-not $text.Contains('raw transcript')) 'classifier must not depend on raw transcript text.'
Assert-Check (-not $text.Contains('conversation')) 'classifier must not parse whole conversation text.'

if ($failures.Count -gt 0) {
  Write-Output "learning classifier tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "learning classifier tests passed $checks checks."
```

- [ ] **Step 2: Run classifier test and confirm failure**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-learning-classifier.ps1
```

Expected: FAIL because `harness/lifecycle/learning-classifier.js` does not exist.

- [ ] **Step 3: Implement the classifier**

Create `harness/lifecycle/learning-classifier.js`:

```js
#!/usr/bin/env node
'use strict';

function categoryForFailureId(id) {
  const table = {
    artifact_forbidden_read: 'gate-order',
    artifact_read_receipt_missing: 'artifact-routing',
    artifact_required_write_missing: 'artifact-routing',
    nested_harness_folder: 'installer-flow',
    planning_started_during_install: 'installer-flow',
    github_repo_created_during_install: 'installer-flow',
    commit_created_during_install: 'permission-boundary',
    push_performed_during_install: 'permission-boundary',
    projection_without_canonical_event: 'permission-boundary',
    compound_review_required_for_solution_write: 'harness-drift',
  };
  return table[id] || null;
}

function classifyLearningCandidates(input) {
  const failures = Array.isArray(input.failures) ? input.failures : [];
  const events = Array.isArray(input.events) ? input.events : [];
  const candidates = [];
  let next = 1;

  function pushCandidate(candidate) {
    candidates.push({
      candidate_ref: candidate.candidate_ref || `cand-${String(next++).padStart(3, '0')}`,
      ...candidate,
    });
  }

  for (const failure of failures) {
    const category = categoryForFailureId(failure.id);
    if (!category) continue;
    pushCandidate({
      category,
      summary: failure.message || failure.id,
      evidence: failure.id,
      recurrence_prevention: `Add or update ${category} solution guidance after compound_review if this repeats.`,
      promotion_recommendation: 'keep_active_only',
    });
  }

  for (const event of events) {
    const payload = event.payload || {};
    if (event.event_type === 'user_correction' && payload.category) {
      pushCandidate({
        category: payload.category,
        summary: payload.summary || 'User correction recorded in canonical event data.',
        evidence: event.event_id || 'user_correction',
        recurrence_prevention: payload.recurrence_prevention || 'Review this correction during compound_review.',
        promotion_recommendation: 'keep_active_only',
      });
    }
  }

  return { candidates };
}

function main() {
  const args = process.argv.slice(2);
  if (!args.includes('--stdin')) {
    throw new Error('Usage: learning-classifier.js --stdin --json');
  }
  let input = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (chunk) => { input += chunk; });
  process.stdin.on('end', () => {
    const parsed = input.trim() ? JSON.parse(input) : {};
    process.stdout.write(`${JSON.stringify(classifyLearningCandidates(parsed), null, 2)}\n`);
  });
}

if (require.main === module) {
  try {
    main();
  } catch (error) {
    process.stderr.write(`ERROR ${error.message}\n`);
    process.exitCode = 1;
  }
}

module.exports = {
  classifyLearningCandidates,
};
```

- [ ] **Step 4: Add lifecycle capture-learning command**

In `harness/lifecycle/lifecycle.js`, import the classifier:

```js
const crypto = require('crypto');
const { classifyLearningCandidates } = require('./learning-classifier');
```

Add a command that reads `events.jsonl` plus a verify JSON file and writes `learning-capture.md` using the existing template. The command must not read raw conversation transcripts.

```js
function sha256Text(text) {
  return `sha256:${crypto.createHash('sha256').update(text).digest('hex')}`;
}

function sha256File(filePath) {
  return `sha256:${crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex')}`;
}

function readEventsJsonl(eventsPath) {
  return fs.existsSync(eventsPath)
    ? fs.readFileSync(eventsPath, 'utf8').split(/\r?\n/).filter(Boolean).map((line) => JSON.parse(line))
    : [];
}

function appendLifecycleEvent(eventsPath, taskId, eventType, payload) {
  const events = readEventsJsonl(eventsPath);
  const previousHash = events.length > 0 ? events[events.length - 1].event_hash : '';
  const event = {
    event_id: crypto.randomUUID(),
    schema_version: '0.1.0',
    task_id: taskId,
    event_type: eventType,
    created_at: new Date().toISOString(),
    actor_type: 'assistant',
    previous_hash: previousHash,
    payload,
  };
  event.event_hash = sha256Text(JSON.stringify(event));
  fs.appendFileSync(eventsPath, `${JSON.stringify(event)}\n`, 'utf8');
  return event;
}

function captureLearning(options) {
  const root = path.resolve(options.root || process.cwd());
  const slug = options.slug;
  if (!slug) throw new Error('capture-learning requires --slug.');

  const taskRoot = path.join(root, 'harness', 'docs', 'tasks', 'active', slug);
  const eventsPath = path.join(taskRoot, 'events.jsonl');
  const verifyPath = options.verifyJson ? path.resolve(options.verifyJson) : null;
  const eventsText = fs.existsSync(eventsPath) ? fs.readFileSync(eventsPath, 'utf8') : '';
  const events = eventsText.split(/\r?\n/).filter(Boolean).map((line) => JSON.parse(line));
  const verifyText = verifyPath && fs.existsSync(verifyPath) ? fs.readFileSync(verifyPath, 'utf8') : '';
  const verifyResult = verifyPath && fs.existsSync(verifyPath)
    ? JSON.parse(verifyText)
    : { failures: [] };

  const result = classifyLearningCandidates({ events, failures: verifyResult.failures || [] });
  for (const candidate of result.candidates) {
    appendLifecycleEvent(eventsPath, slug, 'learning_candidate', candidate);
  }
  const candidateCount = result.candidates.length;
  const lines = [
    '# 배운 점 후보',
    '',
    '이 문서는 구조화된 검증 실패와 canonical event에서 나온 재발방지 후보만 기록합니다.',
    '',
    'raw 대화 전문을 저장하지 않습니다.',
    '',
    '## Capture Metadata',
    '',
    `candidate_count: ${candidateCount}`,
    `source_verify_hash: ${verifyText ? sha256Text(verifyText) : ''}`,
    `source_events_hash: ${sha256Text(eventsText)}`,
    `no_candidate_reason: ${candidateCount === 0 ? '분류 가능한 구조화 증거가 없습니다.' : ''}`,
    '',
    '## 자동분류 후보',
    '',
  ];
  if (candidateCount === 0) {
    lines.push('아직 기록된 후보가 없습니다.');
  } else {
    result.candidates.forEach((candidate, index) => {
      lines.push(`### 후보 ${index + 1}`);
      lines.push('');
      lines.push(`분류: ${candidate.category}`);
      lines.push(`요약: ${candidate.summary}`);
      lines.push(`증거: ${candidate.evidence}`);
      lines.push(`재발방지 후보: ${candidate.recurrence_prevention}`);
      lines.push(`장기 반영 추천: ${candidate.promotion_recommendation}`);
      lines.push('');
    });
  }

  const outputPath = path.join(taskRoot, 'learning-capture.md');
  fs.writeFileSync(outputPath, `${lines.join('\n')}\n`, 'utf8');
  appendLifecycleEvent(eventsPath, slug, 'artifact_written', {
    gate_id: 'compound_capture',
    artifact_id: 'learning_capture',
    path: `harness/docs/tasks/active/${slug}/learning-capture.md`,
    hash: sha256File(outputPath),
  });
  return { ok: true, task: slug, output_path: outputPath, candidates: result.candidates.length };
}
```

Wire it in `main()`:

```js
  } else if (command === 'capture-learning') {
    result = captureLearning({ root: flags.root, slug: flags.slug, verifyJson: flags['verify-json'] });
```

Export it:

```js
  captureLearning,
```

- [ ] **Step 5: Add classifier test to the suite and run it**

In `tests/contracts/run-all.ps1`, insert `test-learning-classifier.ps1` after `test-artifact-routing-contracts.ps1` only after the classifier test file exists:

```powershell
  'test-artifact-routing-contracts.ps1',
  'test-learning-classifier.ps1',
```

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-learning-classifier.ps1
```

Expected: PASS.

- [ ] **Step 6: Optional checkpoint after explicit git approval**

Only run this after the user explicitly approves this exact git operation in the current chat:

```powershell
git add harness/lifecycle/learning-classifier.js harness/lifecycle/lifecycle.js tests/contracts/test-learning-classifier.ps1 tests/contracts/run-all.ps1
git commit -m "feat: classify compound learning candidates"
```

---

### Task 4: Enforce Read Receipts And Compound Review In Verify

**Files:**
- Modify: `harness/verify/verify.js`
- Modify: `harness/doctor/doctor.js`
- Modify: `tests/contracts/test-verify-doctor.ps1`

- [ ] **Step 1: Add failing verify tests for artifact read receipts**

In `tests/contracts/test-verify-doctor.ps1`, add this helper after `Invoke-DoctorJson`:

```powershell
function New-Event {
  param(
    [string]$TaskId,
    [string]$EventId,
    [string]$EventType,
    [string]$PreviousHash,
    [string]$EventHash,
    [hashtable]$Payload
  )
  return [ordered]@{
    event_id = $EventId
    schema_version = '0.1.0'
    task_id = $TaskId
    event_type = $EventType
    created_at = '2026-06-09T00:00:00+09:00'
    actor_type = 'assistant'
    previous_hash = $PreviousHash
    event_hash = $EventHash
    payload = $Payload
  } | ConvertTo-Json -Compress
}

function Write-Events {
  param([string]$Path, [string[]]$Events)
  Set-Content -LiteralPath $Path -Value ($Events -join "`n") -Encoding UTF8
}
```

Add these test cases before the doctor proposal test:

```powershell
$writingPlanMissingReceiptRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $writingPlanMissingReceiptRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: product_feature',
    'status: active',
    'current_gate: writing_plan'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
  $result = Invoke-VerifyJson -Root $writingPlanMissingReceiptRoot
  Assert-Check ($result.ok -eq $false) 'writing_plan should fail without required artifact read receipts.'
  Assert-Check (@($result.failures | Where-Object { $_.id -eq 'artifact_read_receipt_missing' }).Count -ge 3) 'writing_plan should report missing PRD, issues, and module structure receipts.'
}
finally {
  Remove-Item -LiteralPath $writingPlanMissingReceiptRoot -Recurse -Force
}

$writingPlanReceiptRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $writingPlanReceiptRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path (Join-Path $taskDir 'planning') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: product_feature',
    'status: active',
    'current_gate: writing_plan'
  ) -Encoding UTF8
  $contextPath = Join-Path $taskDir 'planning\00-current-planning-context.md'
  $prdPath = Join-Path $taskDir 'planning\03-prd.md'
  $issuesPath = Join-Path $taskDir 'planning\04-issues.md'
  $modulePath = Join-Path $taskDir 'planning\05-module-structure.md'
  $writingPath = Join-Path $taskDir 'planning\06-writing-plan.md'
  $contextRel = 'harness/docs/tasks/active/task-one/planning/00-current-planning-context.md'
  $prdRel = 'harness/docs/tasks/active/task-one/planning/03-prd.md'
  $issuesRel = 'harness/docs/tasks/active/task-one/planning/04-issues.md'
  $moduleRel = 'harness/docs/tasks/active/task-one/planning/05-module-structure.md'
  $writingRel = 'harness/docs/tasks/active/task-one/planning/06-writing-plan.md'
  Set-Content -LiteralPath $contextPath -Value 'context' -Encoding UTF8
  Set-Content -LiteralPath $prdPath -Value 'prd' -Encoding UTF8
  Set-Content -LiteralPath $issuesPath -Value 'issues' -Encoding UTF8
  Set-Content -LiteralPath $modulePath -Value 'module' -Encoding UTF8
  Set-Content -LiteralPath $writingPath -Value 'writing plan' -Encoding UTF8
  $eventsPath = Join-Path $taskDir 'events.jsonl'
  $events = @(
    New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'artifact_read' -PreviousHash '' -EventHash 'h1' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_current_context'; path = $contextRel; hash = "sha256:$((Get-FileHash -Algorithm SHA256 -LiteralPath $contextPath).Hash.ToLowerInvariant())"; proof_type = 'file_sha256' },
    New-Event -TaskId 'task-one' -EventId 'evt-2' -EventType 'artifact_read' -PreviousHash 'h1' -EventHash 'h2' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_prd'; path = $prdRel; hash = "sha256:$((Get-FileHash -Algorithm SHA256 -LiteralPath $prdPath).Hash.ToLowerInvariant())"; proof_type = 'file_sha256' },
    New-Event -TaskId 'task-one' -EventId 'evt-3' -EventType 'artifact_read' -PreviousHash 'h2' -EventHash 'h3' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_issues'; path = $issuesRel; hash = "sha256:$((Get-FileHash -Algorithm SHA256 -LiteralPath $issuesPath).Hash.ToLowerInvariant())"; proof_type = 'file_sha256' },
    New-Event -TaskId 'task-one' -EventId 'evt-4' -EventType 'artifact_read' -PreviousHash 'h3' -EventHash 'h4' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_module_structure'; path = $moduleRel; hash = "sha256:$((Get-FileHash -Algorithm SHA256 -LiteralPath $modulePath).Hash.ToLowerInvariant())"; proof_type = 'file_sha256' },
    New-Event -TaskId 'task-one' -EventId 'evt-5' -EventType 'artifact_written' -PreviousHash 'h4' -EventHash 'h5' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_writing_plan'; path = $writingRel; hash = "sha256:$((Get-FileHash -Algorithm SHA256 -LiteralPath $writingPath).Hash.ToLowerInvariant())" }
  )
  Write-Events -Path $eventsPath -Events $events
  $result = Invoke-VerifyJson -Root $writingPlanReceiptRoot
  Assert-Check ($result.ok -eq $true) "writing_plan should pass when required receipts exist: $($result.failures | ConvertTo-Json -Compress)"
}
finally {
  Remove-Item -LiteralPath $writingPlanReceiptRoot -Recurse -Force
}

$compoundLookupMissingRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $compoundLookupMissingRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: product_feature',
    'status: active',
    'current_gate: compound_lookup'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
  $result = Invoke-VerifyJson -Root $compoundLookupMissingRoot
  Assert-Check ($result.ok -eq $false) 'compound_lookup should fail without compound_state and solutions_index receipts.'
  Assert-Check (@($result.failures | Where-Object { $_.id -eq 'artifact_read_receipt_missing' }).Count -ge 2) 'compound_lookup should report missing compound receipts.'
}
finally {
  Remove-Item -LiteralPath $compoundLookupMissingRoot -Recurse -Force
}

$solutionWriteBlockedRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $solutionWriteBlockedRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: knowledge_maintenance',
    'status: active',
    'current_gate: compound_capture'
  ) -Encoding UTF8
  $eventsPath = Join-Path $taskDir 'events.jsonl'
  $events = @(
    New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'artifact_written' -PreviousHash '' -EventHash 'h1' -Payload @{ path = 'harness/docs/solutions/harness-drift-patterns.md' }
  )
  Write-Events -Path $eventsPath -Events $events
  $result = Invoke-VerifyJson -Root $solutionWriteBlockedRoot
  Assert-Check ($result.ok -eq $false) 'solution writes should fail without compound_review approval.'
  Assert-Check (@($result.failures | Where-Object { $_.id -eq 'compound_review_required_for_solution_write' }).Count -eq 1) 'solution write failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $solutionWriteBlockedRoot -Recurse -Force
}

$staleLearningCaptureRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $staleLearningCaptureRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: knowledge_maintenance',
    'status: active',
    'current_gate: compound_capture'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'learning-capture.md') -Value @(
    '# 배운 점 후보',
    '',
    '아직 기록된 후보가 없습니다.'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
  $result = Invoke-VerifyJson -Root $staleLearningCaptureRoot
  Assert-Check ($result.ok -eq $false) 'compound_capture should fail with untouched learning-capture starter text.'
  Assert-Check (@($result.failures | Where-Object { $_.id -eq 'learning_capture_stale_template' }).Count -eq 1) 'stale learning capture failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $staleLearningCaptureRoot -Recurse -Force
}
```

- [ ] **Step 1b: Add spoofing and promotion-scope tests**

Extend the same PowerShell test block with these cases:

```powershell
$wrongTaskReceiptRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $wrongTaskReceiptRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path (Join-Path $taskDir 'planning') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: product_feature',
    'status: active',
    'current_gate: writing_plan'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'planning\03-prd.md') -Value 'prd' -Encoding UTF8
  $events = @(
    New-Event -TaskId 'other-task' -EventId 'evt-1' -EventType 'artifact_read' -PreviousHash '' -EventHash 'h1' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_prd'; path = 'harness/docs/tasks/active/task-one/planning/03-prd.md'; hash = 'sha256:fake'; proof_type = 'file_sha256' }
  )
  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
  $result = Invoke-VerifyJson -Root $wrongTaskReceiptRoot
  Assert-Check ($result.ok -eq $false) 'artifact_read from a different task_id must not satisfy required reads.'
}
finally {
  Remove-Item -LiteralPath $wrongTaskReceiptRoot -Recurse -Force
}

$staleHashRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $staleHashRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path (Join-Path $taskDir 'planning') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: product_feature',
    'status: active',
    'current_gate: writing_plan'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'planning\03-prd.md') -Value 'changed content' -Encoding UTF8
  $events = @(
    New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'artifact_read' -PreviousHash '' -EventHash 'h1' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_prd'; path = 'harness/docs/tasks/active/task-one/planning/03-prd.md'; hash = 'sha256:stale'; proof_type = 'file_sha256' }
  )
  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
  $result = Invoke-VerifyJson -Root $staleHashRoot
  Assert-Check ($result.ok -eq $false) 'stale artifact_read hash must not satisfy required reads.'
}
finally {
  Remove-Item -LiteralPath $staleHashRoot -Recurse -Force
}

$solutionWriteScopedRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $solutionWriteScopedRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: knowledge_maintenance',
    'status: active',
    'current_gate: compound_review'
  ) -Encoding UTF8
  $events = @(
    New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'compound_review_decision' -PreviousHash '' -EventHash 'h1' -Payload @{ candidate_ref = 'cand-1'; decision = 'promote'; reason = 'repeated violation'; target_solution_path = 'harness/docs/solutions/installer-flow-patterns.md'; user_approval_event_id = 'evt-user-1' },
    New-Event -TaskId 'task-one' -EventId 'evt-2' -EventType 'artifact_written' -PreviousHash 'h1' -EventHash 'h2' -Payload @{ gate_id = 'compound_review'; artifact_id = 'selected_relevant_solutions'; path = 'harness/docs/solutions/harness-drift-patterns.md'; hash = 'sha256:dummy'; candidate_ref = 'cand-1' }
  )
  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
  $result = Invoke-VerifyJson -Root $solutionWriteScopedRoot
  Assert-Check ($result.ok -eq $false) 'solution write must fail when compound_review target path does not match.'
}
finally {
  Remove-Item -LiteralPath $solutionWriteScopedRoot -Recurse -Force
}

$solutionWriteWrongCandidateRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $solutionWriteWrongCandidateRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: knowledge_maintenance',
    'status: active',
    'current_gate: compound_review'
  ) -Encoding UTF8
  $events = @(
    New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'compound_review_decision' -PreviousHash '' -EventHash 'h1' -Payload @{ candidate_ref = 'cand-1'; decision = 'promote'; reason = 'repeated violation'; target_solution_path = 'harness/docs/solutions/harness-drift-patterns.md'; user_approval_event_id = 'evt-user-1' },
    New-Event -TaskId 'task-one' -EventId 'evt-2' -EventType 'artifact_written' -PreviousHash 'h1' -EventHash 'h2' -Payload @{ gate_id = 'compound_review'; artifact_id = 'selected_relevant_solutions'; path = 'harness/docs/solutions/harness-drift-patterns.md'; hash = 'sha256:dummy'; candidate_ref = 'cand-2' }
  )
  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
  $result = Invoke-VerifyJson -Root $solutionWriteWrongCandidateRoot
  Assert-Check ($result.ok -eq $false) 'solution write must fail when compound_review candidate_ref does not match artifact_written candidate_ref.'
}
finally {
  Remove-Item -LiteralPath $solutionWriteWrongCandidateRoot -Recurse -Force
}
```

- [ ] **Step 2: Run verify tests and confirm failure**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-verify-doctor.ps1
```

Expected: FAIL because `verify.js` does not enforce artifact read receipts or compound review protection yet.

- [ ] **Step 3: Add fail-closed contract routing helpers to verify**

In `harness/verify/verify.js`, add this near the existing top-level `require` statements:

```js
const crypto = require('crypto');
```

Then add these helpers after `listDirectories`:

```js
function parseContractSections(text, sectionName) {
  const result = {};
  const lines = text.split(/\r?\n/);
  let inSection = false;
  let currentKey = null;
  let currentList = null;

  for (let index = 0; index < lines.length; index += 1) {
    const rawLine = lines[index];
    const withoutComment = rawLine.replace(/\s+#.*$/, '');
    if (!withoutComment.trim()) continue;
    const indent = withoutComment.match(/^\s*/)[0].length;
    const trimmed = withoutComment.trim();

    if (indent === 0 && trimmed === `${sectionName}:`) {
      inSection = true;
      currentKey = null;
      currentList = null;
      continue;
    }

    if (inSection && indent === 0 && trimmed.endsWith(':')) {
      break;
    }

    if (!inSection) continue;

    if (indent === 2 && /^[-A-Za-z0-9_]+:$/.test(trimmed)) {
      currentKey = trimmed.slice(0, -1);
      result[currentKey] = {};
      currentList = null;
      continue;
    }

    if (!currentKey) {
      throw new Error(`Unsupported ${sectionName} contract shape at line ${index + 1}: ${rawLine}`);
    }

    if (indent === 4 && /^[-A-Za-z0-9_]+:$/.test(trimmed)) {
      currentList = trimmed.slice(0, -1);
      result[currentKey][currentList] = [];
      continue;
    }

    if (indent === 4 && /^[-A-Za-z0-9_]+:\s+/.test(trimmed)) {
      const [key, ...rest] = trimmed.split(':');
      result[currentKey][key] = rest.join(':').trim().replace(/^["']|["']$/g, '');
      currentList = null;
      continue;
    }

    if (indent === 6 && trimmed.startsWith('- ')) {
      if (!currentList || !Array.isArray(result[currentKey][currentList])) {
        throw new Error(`List item without list owner at line ${index + 1}: ${rawLine}`);
      }
      result[currentKey][currentList].push(trimmed.slice(2).trim().replace(/^["']|["']$/g, ''));
      continue;
    }

    throw new Error(`Unsupported ${sectionName} contract shape at line ${index + 1}: ${rawLine}`);
  }

  return result;
}

function readArtifactRegistry(root) {
  return parseContractSections(readText(path.join(root, 'harness', 'contracts', 'artifact-registry.yaml')), 'artifacts');
}

function readSkillArtifactMap(root) {
  return parseContractSections(readText(path.join(root, 'harness', 'contracts', 'skill-artifact-map.yaml')), 'gates');
}

function currentGateFromTaskYaml(taskYaml) {
  return yamlScalar(taskYaml, 'current_gate');
}

function normalizeEventPath(value) {
  return String(value || '').replace(/\\/g, '/');
}

function artifactRelativePathFor(taskName, artifact) {
  if (!artifact || !artifact.path) return null;
  if (artifact.path.startsWith('chat:') || artifact.path.startsWith('project_source:')) return artifact.path;
  if (artifact.root_relative === 'true' || artifact.root_relative === true) {
    return normalizeEventPath(artifact.path);
  }
  return normalizeEventPath(path.join('harness', 'docs', 'tasks', 'active', taskName, artifact.path));
}

function artifactAbsolutePathFor(root, taskName, artifact) {
  const relativePath = artifactRelativePathFor(taskName, artifact);
  if (!relativePath || relativePath.startsWith('chat:') || relativePath.startsWith('project_source:')) return relativePath;
  return path.join(root, ...relativePath.split('/'));
}

function sha256File(filePath) {
  return `sha256:${crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex')}`;
}

function artifactReadReceipt(events, taskName, gateId, artifactId, artifact, expectedRelativePath, expectedAbsolutePath) {
  return events.find((event) => {
    const payload = event.payload || {};
    if (event.task_id !== taskName) return false;
    if (event.event_type !== 'artifact_read') return false;
    if (payload.gate_id !== gateId || payload.artifact_id !== artifactId) return false;
    if (normalizeEventPath(payload.path) !== expectedRelativePath) return false;
    if (artifact.path.startsWith('chat:') || artifact.path.startsWith('project_source:')) {
      return payload.proof_type === 'pseudo_artifact_marker' && typeof payload.hash === 'string' && payload.hash.length > 0;
    }
    if (payload.proof_type !== 'file_sha256' || !fs.existsSync(expectedAbsolutePath)) return false;
    return payload.hash === sha256File(expectedAbsolutePath);
  });
}

function artifactWrittenEvent(events, taskName, gateId, artifactId, artifact, expectedRelativePath, expectedAbsolutePath) {
  if (['events_log', 'active_task_events', 'task_yaml'].includes(artifactId)) {
    return expectedAbsolutePath && fs.existsSync(expectedAbsolutePath);
  }
  return events.find((event) => {
    const payload = event.payload || {};
    if (event.task_id !== taskName) return false;
    if (event.event_type !== 'artifact_written') return false;
    if (payload.gate_id !== gateId || payload.artifact_id !== artifactId) return false;
    if (normalizeEventPath(payload.path) !== expectedRelativePath) return false;
    if (artifact.path.startsWith('chat:') || artifact.path.startsWith('project_source:')) {
      return typeof payload.hash === 'string' && payload.hash.length > 0;
    }
    if (!fs.existsSync(expectedAbsolutePath)) return false;
    return payload.hash === sha256File(expectedAbsolutePath);
  });
}

function eventWritesSolution(event) {
  const payload = event.payload || {};
  const writtenPath = String(payload.path || payload.target_path || '');
  return event.event_type === 'artifact_written'
    && /^harness[\\/]docs[\\/]solutions[\\/].+\.md$/i.test(writtenPath);
}

function solutionWritePath(event) {
  const payload = event.payload || {};
  return String(payload.path || payload.target_path || '').replace(/\\/g, '/');
}

function solutionWriteCandidateRef(event) {
  const payload = event.payload || {};
  return String(payload.candidate_ref || '');
}

function hasMatchingCompoundReviewDecision(events, writeIndex, writePath, candidateRef) {
  return events.slice(0, writeIndex).some((event) => {
    const payload = event.payload || {};
    return event.event_type === 'compound_review_decision'
      && ['promote', 'merge_existing'].includes(payload.decision)
      && typeof candidateRef === 'string'
      && candidateRef.length > 0
      && payload.candidate_ref === candidateRef
      && typeof payload.user_approval_event_id === 'string'
      && payload.user_approval_event_id.length > 0
      && String(payload.target_solution_path || '').replace(/\\/g, '/') === writePath;
  });
}

function learningCaptureCandidateCount(text) {
  const match = text.match(/^candidate_count:\s*(\d+)\s*$/m);
  return match ? Number(match[1]) : null;
}
```

- [ ] **Step 4: Add route verification helper**

In `harness/verify/verify.js`, add this function after `verifyEventHashChain`:

```js
function verifyArtifactRoutingForTask(root, taskName, taskYaml, events, failures, warnings) {
  const registryPath = path.join(root, 'harness', 'contracts', 'artifact-registry.yaml');
  const mapPath = path.join(root, 'harness', 'contracts', 'skill-artifact-map.yaml');
  if (!fs.existsSync(registryPath) || !fs.existsSync(mapPath)) {
    failures.push({
      id: 'missing_contract',
      severity: 'P0',
      message: 'Missing artifact routing contract file.',
    });
    return;
  }

  let registry;
  let gates;
  try {
    registry = readArtifactRegistry(root);
    gates = readSkillArtifactMap(root);
  } catch (error) {
    failures.push({
      id: 'artifact_contract_parse_failed',
      severity: 'P0',
      message: `Artifact routing contract parse failed: ${error.message}`,
    });
    return;
  }

  const gateId = currentGateFromTaskYaml(taskYaml);
  if (!gateId) return;
  if (!gates[gateId]) {
    failures.push({
      id: 'artifact_gate_unknown',
      severity: 'P0',
      message: `Task ${taskName} has current_gate ${gateId}, but skill-artifact-map.yaml does not define it.`,
    });
    return;
  }

  const gate = gates[gateId];
  const requiredReads = Array.isArray(gate.must_read) ? gate.must_read : [];
  const requiredWrites = Array.isArray(gate.must_write) ? gate.must_write : [];
  const forbiddenReads = Array.isArray(gate.must_not_read) ? gate.must_not_read : [];

  for (const artifactId of [...requiredReads, ...requiredWrites, ...forbiddenReads]) {
    if (!registry[artifactId]) {
      failures.push({
        id: 'artifact_contract_unknown_artifact',
        severity: 'P0',
        message: `Gate ${gateId} references unknown artifact id ${artifactId}.`,
      });
    }
  }

  for (const artifactId of requiredReads) {
    const artifact = registry[artifactId];
    if (!artifact) continue;
    if (artifact.read_receipt_required === 'false' || artifact.read_receipt_required === false) continue;
    const expectedRelativePath = artifactRelativePathFor(taskName, artifact);
    const expectedAbsolutePath = artifactAbsolutePathFor(root, taskName, artifact);
    if (!artifactReadReceipt(events, taskName, gateId, artifactId, artifact, expectedRelativePath, expectedAbsolutePath)) {
      failures.push({
        id: 'artifact_read_receipt_missing',
        severity: ['writing_plan', 'compound_lookup', 'implementation'].includes(gateId) ? 'P0' : 'P1',
        message: `Task ${taskName} gate ${gateId} is missing a valid artifact_read receipt for ${artifactId}.`,
      });
    }
  }

  for (const artifactId of forbiddenReads) {
    const forbiddenRead = events.some((event) => {
      const payload = event.payload || {};
      return event.task_id === taskName
        && event.event_type === 'artifact_read'
        && payload.gate_id === gateId
        && payload.artifact_id === artifactId;
    });
    if (forbiddenRead) {
      failures.push({
        id: 'artifact_forbidden_read',
        severity: 'P0',
        message: `Task ${taskName} gate ${gateId} read forbidden artifact ${artifactId}.`,
      });
    }
  }

  for (const artifactId of requiredWrites) {
    const artifact = registry[artifactId];
    if (!artifact || artifact.path.startsWith('chat:') || artifact.path.startsWith('project_source:')) continue;
    const expectedRelativePath = artifactRelativePathFor(taskName, artifact);
    const expectedAbsolutePath = artifactAbsolutePathFor(root, taskName, artifact);
    if (!artifactWrittenEvent(events, taskName, gateId, artifactId, artifact, expectedRelativePath, expectedAbsolutePath)) {
      failures.push({
        id: 'artifact_required_write_missing',
        severity: ['compound_capture', 'compound_review', 'verification'].includes(gateId) ? 'P0' : 'P1',
        message: `Task ${taskName} gate ${gateId} is missing a valid artifact_written event for ${artifactId}.`,
      });
    }
  }

  if (gateId === 'compound_capture') {
    const learningPath = path.join(root, 'harness', 'docs', 'tasks', 'active', taskName, 'learning-capture.md');
    if (!fs.existsSync(learningPath)) {
      failures.push({
        id: 'learning_capture_missing',
        severity: 'P0',
        message: `Task ${taskName} is at compound_capture but learning-capture.md is missing.`,
      });
    } else {
      const learningText = readText(learningPath);
      const candidateCount = learningCaptureCandidateCount(learningText);
      const learningCandidateEvents = events.filter((event) => event.event_type === 'learning_candidate');
      if (candidateCount === null) {
        failures.push({
          id: 'learning_capture_stale_template',
          severity: 'P0',
          message: `Task ${taskName} learning-capture.md is missing candidate_count metadata.`,
        });
      } else if (candidateCount === 0 && !/^no_candidate_reason:\s*\S+/m.test(learningText)) {
        failures.push({
          id: 'learning_capture_no_candidate_reason_missing',
          severity: 'P0',
          message: `Task ${taskName} learning-capture.md has zero candidates without a no_candidate_reason.`,
        });
      } else if (candidateCount > learningCandidateEvents.length) {
        failures.push({
          id: 'learning_candidate_event_missing',
          severity: 'P0',
          message: `Task ${taskName} learning-capture.md candidate_count exceeds learning_candidate events.`,
        });
      }
    }
  }

  events.forEach((event, index) => {
    if (!eventWritesSolution(event)) return;
    const writePath = solutionWritePath(event);
    const candidateRef = solutionWriteCandidateRef(event);
    if (!hasMatchingCompoundReviewDecision(events, index, writePath, candidateRef)) {
      failures.push({
        id: 'compound_review_required_for_solution_write',
        severity: 'P0',
        message: `Task ${taskName} wrote ${writePath} without a prior matching compound_review decision for candidate ${candidateRef || '(missing)'}.`,
      });
    }
  });
}
```

- [ ] **Step 5: Call the route verifier from active task verification**

In `verifyActiveTasks`, after `verifyEventHashChain(events, task, failures);`, call:

```js
    if (fs.existsSync(taskYamlPath)) {
      const taskYaml = readText(taskYamlPath);
      verifyArtifactRoutingForTask(root, task, taskYaml, events, failures, warnings);
      if (/(approved|allowed|permission|capabilit)/i.test(taskYaml) && !hasApprovalDecision(events)) {
        failures.push({
          id: 'projection_without_canonical_event',
          severity: 'P0',
          message: `Task ${task} has task.yaml permission-like state without approval_decision in events.jsonl.`,
        });
      }
    } else {
      warnings.push({
        id: 'active_task_missing_task_yaml',
        severity: 'warning',
        message: `Task ${task} has no task.yaml derived cache.`,
      });
    }
```

This replaces the existing `if (fs.existsSync(taskYamlPath)) { ... } else { ... }` block in `verifyActiveTasks`.

- [ ] **Step 6: Add doctor next actions**

In `harness/doctor/doctor.js`, add these keys to the `table` in `nextActionFor`:

```js
    artifact_contract_parse_failed: 'Fix artifact-registry.yaml or skill-artifact-map.yaml; malformed routing contracts fail closed.',
    artifact_gate_unknown: 'Add the current gate to skill-artifact-map.yaml or correct task.yaml current_gate.',
    artifact_contract_unknown_artifact: 'Define the artifact in artifact-registry.yaml or remove the bad reference from skill-artifact-map.yaml.',
    artifact_read_receipt_missing: 'Read the required artifact, resolve its registry path, compute SHA-256 for file-backed artifacts, and append artifact_read with gate_id, artifact_id, path, hash, and proof_type.',
    artifact_forbidden_read: 'Stop the task and create a repair proposal; the current gate read a forbidden artifact.',
    artifact_required_write_missing: 'Create the required gate output artifact and append artifact_written with gate_id, artifact_id, repo-relative path, and file hash, or move the task back to the previous gate.',
    learning_capture_missing: 'Run lifecycle capture-learning before compound_capture finishes.',
    learning_capture_stale_template: 'Regenerate learning-capture.md from structured evidence; the starter template is not a valid capture result.',
    learning_capture_no_candidate_reason_missing: 'Add a no_candidate_reason with source hashes when candidate_count is 0.',
    learning_candidate_event_missing: 'Append learning_candidate events matching learning-capture.md candidate_count.',
    compound_review_required_for_solution_write: 'Revert the long-term solution write or add a prior matching compound_review_decision with candidate_ref, target_solution_path, decision, reason, and user_approval_event_id.',
```

- [ ] **Step 7: Run verify tests**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-verify-doctor.ps1
```

Expected: PASS.

- [ ] **Step 8: Optional checkpoint after explicit git approval**

Only run this after the user explicitly approves this exact git operation in the current chat:

```powershell
git add harness/verify/verify.js harness/doctor/doctor.js tests/contracts/test-verify-doctor.ps1
git commit -m "feat: enforce artifact read receipts"
```

---

### Task 5: Document Artifact Routing In Runtime Rules

**Files:**
- Modify: `AGENTS.md`
- Modify: `harness/rules/workflow.md`
- Modify: `harness/rules/rules.md`
- Modify: `tests/contracts/test-workflow-rules.ps1`
- Modify: `tests/contracts/test-agents-readme.ps1`
- Modify: `README.md`

- [ ] **Step 1: Add workflow projection section**

In `harness/rules/workflow.md`, add this section after `## Planning Gates`:

```markdown
## Artifact Routing

Before a gate or skill starts, check:

```text
harness/contracts/artifact-registry.yaml
harness/contracts/skill-artifact-map.yaml
```

Do not rely on memory for required artifacts.

Read receipts prove that the required artifacts were actually read.

Read receipts are recorded as `artifact_read` events in `events.jsonl`.

`compound_lookup` reads solution indexes before detailed solution files.

`compound_capture` records candidates in `learning-capture.md`.

`compound_review` decides long-term promotion before anything under `harness/docs/solutions/` is changed.

`learning-capture.md` and `compound-review.md` are human-facing artifacts and use the user's language.
```

- [ ] **Step 2: Add operational rules**

In `harness/rules/rules.md`, add this section near the existing gate rules:

```markdown
## Artifact Routing Rules

Before a gate or skill starts, check `harness/contracts/skill-artifact-map.yaml`.

Do not rely on memory for required artifacts.

Record `artifact_read` events for required artifact reads.

The `artifact_read` event payload must include:

```text
gate_id
artifact_id
path
hash
```

If a required artifact is missing, stop at the current gate and explain the missing artifact.

If a required read receipt is missing, verification fails.

Do not promote learning candidates into `harness/docs/solutions/` without `compound_review`.

`compound_capture` writes candidates to `learning-capture.md`.

`compound_review` decides whether each candidate is promoted, kept active-only, merged into an existing solution, or discarded.

Long-term solution files are read through `harness/state/compound.md` and `harness/docs/solutions/index.md` first. Read detailed solution files only when relevant.
```

- [ ] **Step 3: Extend workflow/rules tests**

In `tests/contracts/test-workflow-rules.ps1`, add these tokens to the `$workflow` token list:

```powershell
  'Artifact Routing',
  'Read receipts',
  'compound_lookup reads solution indexes before detailed solution files',
  'compound_capture records candidates in `learning-capture.md`',
  'compound_review decides long-term promotion',
  'learning-capture.md',
  'compound-review.md',
```

Add these tokens to the `$rules` token list:

```powershell
  'Before a gate or skill starts, check `harness/contracts/skill-artifact-map.yaml`',
  'Do not rely on memory for required artifacts',
  'Record `artifact_read` events for required artifact reads',
  'Do not promote learning candidates into `harness/docs/solutions/` without `compound_review`',
  'compound_capture',
  'compound_review',
```

- [ ] **Step 4: Add README explanation**

In `README.md`, add this section after `## 자주 보이는 문구와 파일`:

```markdown
## 자동으로 배운 점을 남기는 방식

작업 중 AI가 하네스 흐름을 놓치거나, 설치 방식을 오해하거나, 승인 범위를 넓게 해석하면 하네스는 그 사건을 장기 규칙으로 바로 박아넣지 않습니다.

먼저 현재 작업의 `learning-capture.md`에 후보로 기록합니다.

그 다음 `compound-review.md`에서 장기 지식으로 반영할지 검토합니다.

승격된 내용만 `harness/docs/solutions/`에 들어갑니다.

이 방식은 사용자가 매번 같은 지적을 반복하지 않게 하되, 한 번의 특이한 상황이 영구 규칙으로 굳어지는 문제를 막기 위한 장치입니다.

## 필요한 문서를 읽었는지 확인하는 방식

각 단계는 읽어야 하는 산출물이 정해져 있습니다.

예를 들어 `writing_plan` 단계는 PRD, 이슈, 모듈 구조를 읽어야 합니다.

AI가 이 문서들을 읽으면 `events.jsonl`에 `artifact_read` 기록이 남습니다.

이 기록이 없으면 verify가 실패할 수 있습니다.

즉, AI가 "읽은 것 같다"고 말하는 게 아니라 실제 읽은 흔적을 남기게 하는 구조입니다.
```

- [ ] **Step 5: Update AGENTS.md required reads**

In `AGENTS.md`, add these lines to the `## Required Reads` code block immediately after `harness/contracts/gate-contract-matrix.yaml`:

```text
harness/contracts/artifact-registry.yaml
harness/contracts/skill-artifact-map.yaml
```

Add this hard rule under `## Hard Rules`:

```markdown
- Before running a gate or skill, check `harness/contracts/skill-artifact-map.yaml` for required artifacts and record valid `artifact_read` events for file-backed reads.
```

- [ ] **Step 6: Extend AGENTS/README tests**

In `tests/contracts/test-agents-readme.ps1`, add assertions that `AGENTS.md` includes the new contract reads:

```powershell
$agents = Get-Content -LiteralPath (Join-Path $RepoRoot 'AGENTS.md') -Raw
Assert-Check ($agents.Contains('harness/contracts/artifact-registry.yaml')) 'AGENTS.md must route agents to artifact-registry.yaml.'
Assert-Check ($agents.Contains('harness/contracts/skill-artifact-map.yaml')) 'AGENTS.md must route agents to skill-artifact-map.yaml.'
Assert-Check ($agents.Contains('artifact_read')) 'AGENTS.md must mention artifact_read receipts.'
```

- [ ] **Step 7: Run docs contract tests**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-workflow-rules.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-artifact-routing-contracts.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-agents-readme.ps1
```

Expected: PASS.

- [ ] **Step 8: Optional checkpoint after explicit git approval**

Only run this after the user explicitly approves this exact git operation in the current chat:

```powershell
git add AGENTS.md harness/rules/workflow.md harness/rules/rules.md README.md tests/contracts/test-workflow-rules.ps1 tests/contracts/test-agents-readme.ps1
git commit -m "docs: explain artifact routing workflow"
```

---

### Task 6: Update Release Metadata And Run Full Verification

**Files:**
- Modify: `harness/release/SOURCE-MANIFEST.md`
- Modify: `harness/release/RELEASE-NOTES.md`
- Modify: `harness/release/CHECKSUMS.sha256`
- Modify: `tests/contracts/test-release-candidate.ps1`

- [ ] **Step 1: Update source manifest**

In `harness/release/SOURCE-MANIFEST.md`, add these bullets under `## Canonical Surfaces`:

```markdown
- `harness/contracts/artifact-registry.yaml`: artifact role, language, lifecycle, and receipt policy.
- `harness/contracts/skill-artifact-map.yaml`: gate-to-artifact read/write routing contract.
- `harness/lifecycle/learning-classifier.js`: structured evidence classifier for compound learning candidates.
- `harness/docs/solutions/`: long-term compound learning summaries read through indexes before detailed bodies.
```

- [ ] **Step 2: Update release notes**

In `harness/release/RELEASE-NOTES.md`, add these bullets under `Included:`:

```markdown
- Artifact registry and skill-artifact-map contracts.
- Read receipt verification for artifact-dependent gates.
- Structured compound learning classifier plus capture and review templates.
- Canonical user correction events that can become learning candidates.
- Indexed long-term solution buckets for repeated harness mistakes.
```

Add these bullets under `Important behavior:`:

```markdown
- `writing_plan` requires read receipts for PRD, issues, module structure, and current planning context.
- `compound_lookup` reads compound state and solution index before detailed solution files.
- `compound_capture` classifies only structured verify, permission, gate-order, and canonical correction evidence.
- `compound_capture` must produce candidate metadata; an untouched starter capture file is invalid.
- Long-term solution writes require `compound_review`.
```

- [ ] **Step 3: Extend release candidate contract test**

In `tests/contracts/test-release-candidate.ps1`, add manifest, release-note, and checksum assertions for the new surfaces:

```powershell
Assert-Check ($manifest.Contains('harness/contracts/artifact-registry.yaml')) 'source manifest must name artifact-registry.yaml.'
Assert-Check ($manifest.Contains('harness/contracts/skill-artifact-map.yaml')) 'source manifest must name skill-artifact-map.yaml.'
Assert-Check ($manifest.Contains('harness/lifecycle/learning-classifier.js')) 'source manifest must name the structured learning classifier.'
Assert-Check ($manifest.Contains('harness/docs/solutions/')) 'source manifest must name compound solution docs.'
Assert-Check ($notes.Contains('Structured compound learning classifier')) 'release notes must mention structured compound learning classification.'
Assert-Check ($notes.Contains('Canonical user correction events')) 'release notes must mention canonical user correction events.'
Assert-Check ($notes.Contains('compound_capture')) 'release notes must document compound_capture behavior.'
```

Extend the checksum token list with:

```powershell
'harness/contracts/artifact-registry.yaml',
'harness/contracts/skill-artifact-map.yaml',
'harness/lifecycle/learning-classifier.js',
'harness/templates/task/learning-capture.md',
'harness/templates/task/compound-review.md',
'harness/docs/solutions/index.md',
'tests/contracts/test-artifact-routing-contracts.ps1',
'tests/contracts/test-learning-classifier.ps1',
'tests/fixtures/contracts/required-p0-regressions.txt'
```

- [ ] **Step 4: Regenerate checksums**

Run this PowerShell command from the repo root:

```powershell
$files = git ls-files --cached --others --exclude-standard | Sort-Object -Unique | Where-Object { $_ -ne 'harness/release/CHECKSUMS.sha256' -and $_ -notlike 'harness/docs/tasks/active/*' -and $_ -notlike 'source-history/*' }
$lines = foreach ($file in $files) {
  $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file).Hash.ToLowerInvariant()
  "$hash  $($file -replace '\\','/')"
}
Set-Content -LiteralPath 'harness/release/CHECKSUMS.sha256' -Value $lines -Encoding UTF8
```

- [ ] **Step 5: Run full contract tests**

Run:

```powershell
npm.cmd run test:contracts
```

Expected:

```text
All contract tests passed.
```

- [ ] **Step 6: Run verify and doctor on the repo**

Run:

```powershell
node harness/verify/verify.js --root . --json
node harness/doctor/doctor.js --root . --json
```

Expected:

- `verify` returns `"ok": true`
- `doctor` returns `"ok": true`

- [ ] **Step 7: Optional checkpoint after explicit git approval**

Only run this after the user explicitly approves this exact git operation in the current chat:

```powershell
git add harness/release/SOURCE-MANIFEST.md harness/release/RELEASE-NOTES.md harness/release/CHECKSUMS.sha256 tests/contracts/test-release-candidate.ps1
git commit -m "chore: update artifact routing release metadata"
```

---

## Self-Review

**Spec coverage:** Covered automatic classification, canonical user correction events, active task learning capture with candidate metadata, stale capture rejection, compound review before long-term promotion, artifact registry, skill artifact map, read/write receipt verification, user-language human documents, and beginner README explanation.

**Open markers:** None.

**Type consistency:** Artifact ids use snake_case consistently across `artifact-registry.yaml`, `skill-artifact-map.yaml`, `artifact_read` events, and verify failure messages.

**Risk notes:**

- The YAML parser is intentionally small and supports the contract shape used here. It must not become a general YAML parser.
- File-backed `artifact_read` events must be verified by recomputing SHA-256 from the resolved registry path. Only `chat:` and `project_source:` pseudo artifacts may use non-file proof markers.
- Long-term solution writes are blocked by event evidence. Git diff based enforcement is outside this plan.
