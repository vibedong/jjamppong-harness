# Ledgerless Workflow Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `events.jsonl`, `gate-ledger.md`, `artifact_read`, `artifact_written`, event hash chain을 짬뽕하네스 코어에서 제거하고, AI가 `질문 -> 기획 -> 승인 -> 실행 -> 검증` 흐름을 가볍게 따르게 만든다.

**Architecture:** 현재 상태는 `task.yaml`이 machine-readable cache로 요약하고, 사용자가 읽는 승인/검증/인계는 markdown 문서가 맡는다. `PermissionDecision`은 `task.yaml.current_gate`로 read/research 권한을 판단하고, 위험 권한은 현재 채팅의 명시 승인에서 파생된 `implementation-approval.md`와 `task.yaml approval_summary`로 판단한다. `verify`와 `doctor`는 원장 무결성 검사가 아니라 workflow 상태 검사와 안전 진단만 수행한다.

**Tech Stack:** Node.js CommonJS CLI, PowerShell contract tests, YAML-like text contracts, Markdown templates.

---

## Scope Check

이 계획은 하나의 하네스 코어 변경이다. 독립 하위 시스템은 많지만 모두 `ledgerless workflow adherence`라는 하나의 목표에 묶여 있다.

작업 중 절대 하지 말 것:

- product code 수정 금지
- live target access 금지
- npm publish 금지
- git commit 금지, 사용자가 그 시점에 명시 승인하기 전까지
- git push 금지
- 사용자 승인 없이 원격 저장소 변경 금지

기존 `docs/superpowers/plans/*` 같은 historical docs는 과거 의사결정 기록이다. `events.jsonl` 제거 검사는 live harness surface에만 적용한다.

Live harness surface:

```text
AGENTS.md
README.md
CONTEXT.md
harness/**
module-template/**
tests/**
```

Historical docs allowlist:

```text
docs/superpowers/plans/**
docs/superpowers/specs/**
```

## Workflow Adherence Acceptance Matrix

이 구현은 `events.jsonl`을 지우는 작업만으로 성공하지 않는다. 아래 matrix가 통과해야 한다.

| 상황 | 기대 동작 |
| --- | --- |
| 새 작업 요청 | 바로 구현하지 않고 active task 상태와 grill/research 필요 여부를 확인한다. |
| module 폴더가 비어 있음 | 폴더/모듈 구조 계획을 먼저 묻고, 코드/테스트는 만들지 않는다. |
| research 단계 | `file.read.project`, `network.web_research`는 `current_gate`가 허용할 때만 가능하다. |
| implementation 전 | `implementation-approval.md`와 `task.yaml approval_summary`가 없으면 write/package/git/live access가 막힌다. |
| 짧은 답변 `좋아/ㅇ/그래` | 직전 메시지가 명확한 구현 승인 질문일 때만 구현 승인으로 해석한다. |
| 새 task 생성 | `events.jsonl`, `gate-ledger.md`가 생성되지 않는다. |
| 기존 ledgerful task | 깨뜨리지 않고 migration-needed warning으로만 표시한다. |
| handoff 생성 | `handoff.md`와 다음 채팅에 붙여넣을 한국어 문구가 나온다. |
| Compound Engineering | startup/hot context가 아니며, 명시 트리거나 반복 drift가 있을 때만 진입한다. |

## File Structure

### 계약 파일

- Modify: `harness/contracts/task.schema.yaml`
- Modify: `harness/contracts/artifact-registry.yaml`
- Modify: `harness/contracts/skill-artifact-map.yaml`
- Modify: `harness/contracts/gate-contract-matrix.yaml`
- Delete after consumers are removed: `harness/contracts/ledger-event.schema.yaml`

### 템플릿과 lifecycle

- Modify: `harness/templates/task/task.yaml`
- Delete after consumers are removed: `harness/templates/task/events.jsonl.template`
- Delete after consumers are removed: `harness/templates/task/gate-ledger.md`
- Modify: `harness/templates/task/implementation-approval.md`
- Modify: `harness/templates/task/learning-capture.md`
- Modify: `harness/templates/task/compound-review.md`
- Modify: `harness/lifecycle/lifecycle.js`
- Modify: `harness/lifecycle/learning-classifier.js`

### 권한/검증

- Modify: `harness/permission/permission-decision.js`
- Modify: `harness/verify/verify.js`
- Modify: `harness/doctor/doctor.js`

### 설치/문서

- Modify: `harness/installer/install.js`
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `CONTEXT.md`
- Modify: `harness/rules/rules.md`
- Modify: `harness/rules/workflow.md`
- Modify: `harness/rules/module-types.md`
- Modify: `harness/state/planning.md`

### 테스트

- Modify: `tests/contracts/run-contract-regression.ps1`
- Modify: `tests/contracts/test-artifact-routing-contracts.ps1`
- Modify: `tests/contracts/test-lifecycle-templates.ps1`
- Modify: `tests/contracts/test-permission-decision.ps1`
- Modify: `tests/contracts/test-verify-doctor.ps1`
- Modify: `tests/contracts/test-learning-classifier.ps1`
- Modify: `tests/contracts/test-installer-package.ps1`
- Modify: `tests/contracts/test-workflow-rules.ps1`
- Modify: `tests/contracts/test-agents-readme.ps1`

Do not update `harness/release/CHECKSUMS.sha256`, `SOURCE-MANIFEST.md`, npm package metadata, or publish surfaces in this plan. Release surface updates happen after the core is green and the user explicitly asks for release/publish.

---

### Task 0: 실행 기준선, ledger 참조 inventory, dirty worktree 정리

**Files:**
- Create: `docs/superpowers/plans/2026-06-09-ledgerless-reference-inventory.md`
- Do not modify product or harness source in this task.

- [ ] **Step 1: 현재 git 상태 기록**

Run:

```powershell
git status --short --branch
git diff --name-only
git diff --cached --name-only
```

Expected:

```text
main is ahead of origin/main by 2 commits.
Only known pre-existing hot-context changes and this plan file are dirty.
No staged files unless the user staged them deliberately.
```

- [ ] **Step 2: ledger reference inventory 생성**

Run:

```powershell
rg -n "events\.jsonl|gate-ledger|artifact_read|artifact_written|event_hash|ledger-event|canonical_event_log|canonical log|approval_decision" AGENTS.md README.md CONTEXT.md harness module-template tests > docs/superpowers/plans/2026-06-09-ledgerless-reference-inventory.md
```

Expected: live harness surface의 원장 참조 목록이 파일에 저장된다.

- [ ] **Step 3: historical docs는 실패 근거에서 제외하는지 확인**

Run:

```powershell
rg -n "events\.jsonl|gate-ledger|artifact_read|artifact_written" docs/superpowers/plans docs/superpowers/specs
```

Expected: 결과가 있어도 구현 실패 근거로 삼지 않는다. 이 출력은 historical reference다.

- [ ] **Step 4: commit gate를 계획에 고정**

Rule:

```text
각 task 완료 후에는 변경 파일, 테스트 결과, 제안 커밋 메시지만 보고한다.
git commit은 사용자가 그 시점에 명시 승인할 때만 실행한다.
git push는 별도 명시 승인 없이는 실행하지 않는다.
```

- [ ] **Step 5: Task 0 결과 보고**

Report:

```text
ledger reference inventory path
dirty worktree summary
commit/push not performed
next task readiness
```

---

### Task 1: contracts + tests를 ledgerless 기준으로 먼저 뒤집기

**Files:**
- Modify: `tests/contracts/run-contract-regression.ps1`
- Modify: `tests/contracts/test-artifact-routing-contracts.ps1`
- Modify: `tests/contracts/test-lifecycle-templates.ps1`
- Modify: `tests/contracts/test-permission-decision.ps1`
- Modify: `tests/contracts/test-verify-doctor.ps1`
- Modify: `tests/contracts/test-installer-package.ps1`

- [ ] **Step 1: regression 테스트의 canonical log 기대 제거**

`tests/contracts/run-contract-regression.ps1`에서 `ledger-event.schema.yaml`, `canonical_log: events.jsonl`, `append_only: true`, `human_projection: gate-ledger.md` 필수 기대를 제거한다.

새 기대:

```powershell
Assert-Contract (-not $taskSchema.Contains('canonical_event_log: events.jsonl')) 'task schema must not require events.jsonl.'
Assert-Contract (-not $taskSchema.Contains('human_projection: gate-ledger.md')) 'task schema must not require gate-ledger.md.'
Assert-Contract ($taskSchema.Contains('approval_summary')) 'task schema must define approval_summary.'
```

- [ ] **Step 2: lifecycle 테스트의 새 task 생성 기대 변경**

`tests/contracts/test-lifecycle-templates.ps1`에서 task 생성 후 아래를 검사한다.

```powershell
Assert-Check (Test-Path -LiteralPath (Join-Path $taskRoot 'task.yaml')) 'create-task must create task.yaml.'
Assert-Check (-not (Test-Path -LiteralPath (Join-Path $taskRoot 'events.jsonl'))) 'create-task must not create events.jsonl.'
Assert-Check (-not (Test-Path -LiteralPath (Join-Path $taskRoot 'gate-ledger.md'))) 'create-task must not create gate-ledger.md.'
```

- [ ] **Step 3: verify 테스트의 legacy 정책 수정**

`tests/contracts/test-verify-doctor.ps1`에서 기존 active task에 `events.jsonl`이 있을 때 P0 failure가 아니라 warning이어야 한다.

Expected warning id:

```text
legacy_ledger_artifact_present
```

P0 failure는 새 task 생성 결과나 live template/contract surface에 ledger file이 남는 경우에만 사용한다.

- [ ] **Step 4: PermissionDecision 테스트에 current_gate 권한과 구현 권한을 분리**

테스트 케이스를 둘로 나눈다.

Research/read allow:

```yaml
current_gate: research
approval_summary:
  implementation: locked
```

Expected:

```powershell
file.read.project -> allow
network.web_research -> allow
file.write.module -> deny
```

Implementation write allow:

```yaml
current_gate: work
approval_summary:
  implementation: approved
  allowed_capabilities:
    - file.write.module
  allowed_paths:
    - modules/sample/**
  package_install: false
  network_live_target: false
  git_commit: false
  git_push: false
```

Expected:

```powershell
file.write.module modules/sample/app.js -> allow
file.write.module modules/other/app.js -> deny
git.commit -> deny
```

- [ ] **Step 5: installer update 테스트 추가**

`tests/contracts/test-installer-package.ps1`에 기존 ledgerful 설치본 업데이트 시나리오를 추가한다.

Setup:

```powershell
New-Item -ItemType File -Path (Join-Path $root 'harness\contracts\ledger-event.schema.yaml') -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $root 'harness\templates\task\events.jsonl.template') -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $root 'harness\templates\task\gate-ledger.md') -Force | Out-Null
```

Expected after installer:

```powershell
Assert-Check (-not (Test-Path -LiteralPath (Join-Path $root 'harness\contracts\ledger-event.schema.yaml'))) 'installer update must prune legacy ledger-event schema.'
Assert-Check (-not (Test-Path -LiteralPath (Join-Path $root 'harness\templates\task\events.jsonl.template'))) 'installer update must prune legacy events template.'
Assert-Check (-not (Test-Path -LiteralPath (Join-Path $root 'harness\templates\task\gate-ledger.md'))) 'installer update must prune legacy gate ledger template.'
```

- [ ] **Step 6: 테스트 실패 확인**

Run:

```powershell
npm.cmd run test:contracts
```

Expected: 아직 구현 전이므로 ledgerless 기대와 관련된 테스트가 실패한다.

- [ ] **Step 7: Task 1 결과 보고**

Report:

```text
changed test files
expected failing tests
commit not performed unless user explicitly approved
```

---

### Task 2: contracts/schema와 live consumers를 ledgerless 모델로 정리

**Files:**
- Modify: `harness/contracts/task.schema.yaml`
- Modify: `harness/contracts/artifact-registry.yaml`
- Modify: `harness/contracts/skill-artifact-map.yaml`
- Modify: `harness/contracts/gate-contract-matrix.yaml`
- Delete: `harness/contracts/ledger-event.schema.yaml`
- Modify if referenced: `tests/contracts/verify-coverage-map.yaml`
- Modify if referenced: `tests/contracts/regression-catalog.yaml`

- [ ] **Step 1: live consumer 참조 제거 확인**

Run:

```powershell
rg -n "ledger-event\.schema\.yaml|canonical_event_log|human_projection|events_log|active_task_events|gate_ledger|artifact_read|artifact_written" harness tests/contracts
```

Expected: 제거할 live consumer 목록이 나온다.

- [ ] **Step 2: task schema 교체**

`harness/contracts/task.schema.yaml`은 `task.yaml`을 current-state cache로 정의한다.

Required content:

```yaml
version: 0.2.0
name: task-schema

state_surface: task.yaml
approval_surface: implementation-approval.md
verification_surface: verification.md
handoff_surface: handoff.md
stores_history: false

task_yaml:
  status: current_state_cache
  grants_permission_alone: false
  required_fields:
    - task_id
    - task_type
    - status
    - current_gate
    - created_at
    - updated_at
    - next_action
    - approval_summary
```

- [ ] **Step 3: artifact registry에서 ledger artifacts 제거**

Remove artifact ids:

```text
events_log
active_task_events
gate_ledger
```

Add:

```yaml
  implementation_approval:
    path: implementation-approval.md
    audience: human
    language: user
    lifecycle: active_task
    purpose: Human-readable exact-scope approval summary derived from current chat approval.
    canonical: false
    read_receipt_required: false
```

- [ ] **Step 4: skill artifact map에서 ledger must_read/must_write 제거**

No gate may require:

```text
events_log
active_task_events
gate_ledger
artifact_read
artifact_written
```

Implementation gate must write:

```text
implementation_approval
task_yaml
```

Handoff gate must read:

```text
task_yaml
planning_current_context
```

- [ ] **Step 5: gate matrix에서 원장 artifacts 제거**

Remove required artifacts:

```text
events.jsonl
gate_question_events
user_answer_events
artifact_hash_snapshot
permission_decisions
skeleton_log
```

Keep gate sequence unchanged.

- [ ] **Step 6: ledger-event schema 삭제**

Run:

```powershell
git rm -- harness/contracts/ledger-event.schema.yaml
```

Expected: file removed from index. Do not commit yet unless user explicitly approves.

- [ ] **Step 7: contract tests 실행**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/run-contract-regression.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-artifact-routing-contracts.ps1
```

Expected: contract tests pass or fail only on next implementation surfaces.

- [ ] **Step 8: Task 2 결과 보고**

Report:

```text
contract files changed
deleted ledger-event schema
remaining rg hits in live surface
commit not performed unless user explicitly approved
```

---

### Task 3: lifecycle/templates + existing install prune

**Files:**
- Modify: `harness/templates/task/task.yaml`
- Delete: `harness/templates/task/events.jsonl.template`
- Delete: `harness/templates/task/gate-ledger.md`
- Modify: `harness/templates/task/implementation-approval.md`
- Modify: `harness/templates/task/learning-capture.md`
- Modify: `harness/templates/task/compound-review.md`
- Modify: `harness/lifecycle/lifecycle.js`
- Modify: `harness/installer/install.js`
- Modify: `tests/contracts/test-lifecycle-templates.ps1`
- Modify: `tests/contracts/test-installer-package.ps1`

- [ ] **Step 1: task.yaml template을 current-state cache로 교체**

Required template:

```yaml
task_id: "{{task_id}}"
task_type: "{{task_type}}"
status: active
current_gate: intake
created_at: "{{created_at}}"
updated_at: "{{updated_at}}"
next_action: "사용자 의도를 확인하고 grill 단계로 이동한다."
approval_summary:
  implementation: locked
  allowed_capabilities: []
  allowed_paths: []
  package_install: false
  network_live_target: false
  git_commit: false
  git_push: false
  approval_source: ""
```

- [ ] **Step 2: implementation approval template 교체**

Required headings:

```markdown
# 구현 승인

## 승인 질문
## 사용자 답변 요약
## 허용 작업
## 금지 작업
## 파일 범위
## 테스트 범위
## Capability 허용 여부
## 승인 만료 또는 철회 조건
```

The template must say:

```text
이 문서는 현재 채팅에서 사용자가 명시 승인한 범위를 사람이 읽기 쉽게 정리한 파생 문서입니다.
```

- [ ] **Step 3: learning/compound templates에서 event hash 제거**

`learning-capture.md` must contain:

```text
candidate_count:
source_verify_summary:
source_user_correction:
no_candidate_reason:
```

It must not contain:

```text
source_events_hash
events.jsonl
```

`compound-review.md` must contain:

```text
이 문서는 startup, permission, verify, implementation gate의 필수 입력이 아닙니다.
```

- [ ] **Step 4: lifecycle에서 events special case 제거**

Remove:

```js
if (entry.name === 'events.jsonl.template') {
  fs.writeFileSync(path.join(targetRoot, 'events.jsonl'), '', 'utf8');
}
```

Task creation must copy only existing templates.

- [ ] **Step 5: capture-learning을 event-free로 변경**

`captureLearning` reads:

```text
verification.md
acceptance.md
```

It does not read or create `events.jsonl`.

- [ ] **Step 6: installer에서 obsolete managed files prune 추가**

`harness/installer/install.js` should remove obsolete files from the target if they exist:

```text
harness/contracts/ledger-event.schema.yaml
harness/templates/task/events.jsonl.template
harness/templates/task/gate-ledger.md
```

This prune applies only to those exact paths under the install target.

- [ ] **Step 7: 삭제 실행**

Run:

```powershell
git rm -- harness/templates/task/events.jsonl.template harness/templates/task/gate-ledger.md
```

- [ ] **Step 8: lifecycle/installer tests 실행**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-lifecycle-templates.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-installer-package.ps1
```

Expected: both tests pass.

- [ ] **Step 9: Task 3 결과 보고**

Report changed files, deleted templates, installer prune behavior, and test results.

---

### Task 4: PermissionDecision current_gate/approval 분리

**Files:**
- Modify: `harness/permission/permission-decision.js`
- Modify: `harness/contracts/permission-decision.schema.yaml`
- Modify: `tests/contracts/test-permission-decision.ps1`

- [ ] **Step 1: event parser 제거**

Remove event-based permission functions:

```text
readJsonl
eventPayload
gateStatus
invalidatedApprovalIds
findApproval
hasCapabilityInApproval
matched_events based allow
```

- [ ] **Step 2: current_gate 권한 규칙 추가**

Rules:

```text
file.read.project: allow only when current_gate is research, architecture_orientation, prd, issues, module_structure, writing_plan, plan_review, implementation, work, verification, acceptance, compound_capture, compound_review, archive, handoff.
network.web_research: allow only when current_gate is research.
```

Before grill/research, deny project source read unless the task type is install or harness_update and the requested path is harness-owned.

- [ ] **Step 3: dangerous capability 권한 규칙 추가**

Dangerous capabilities require `approval_summary.implementation: approved`:

```text
file.write.module
file.write.outside_modules
file.write.harness_core
package.install
network.live_target
git.commit
git.push
parallel.write
```

`allowed_capabilities` and `allowed_paths` must both match for file write capabilities.

- [ ] **Step 4: implementation-approval.md는 proof가 아니라 derived summary로 취급**

Decision output must not claim cryptographic proof. Allow reason:

```text
Allowed by task.yaml approval_summary derived from current chat approval.
```

If `implementation-approval.md` is missing when dangerous capability is requested, deny:

```text
Implementation approval summary is missing.
```

- [ ] **Step 5: approval parser는 task.yaml만 machine-readable로 사용**

Do not parse markdown lists for authorization. For markdown, only check that required headings exist.

- [ ] **Step 6: tests 실행**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-permission-decision.ps1
```

Expected: permission tests pass.

- [ ] **Step 7: Task 4 결과 보고**

Report allow/deny matrix results and remaining risks.

---

### Task 5: verify/doctor 상태 검사 + product write guard

**Files:**
- Modify: `harness/verify/verify.js`
- Modify: `harness/doctor/doctor.js`
- Modify: `tests/contracts/test-verify-doctor.ps1`

- [ ] **Step 1: verify에서 event/hash/receipt 검사 제거**

Remove:

```text
readJsonl
sha256File
artifactReadReceipt
artifactWrittenEvent
verifyEventHashChain
hasApprovalDecision
compound event matching
```

- [ ] **Step 2: allowed gate enum 검사**

Allowed gates:

```text
intake
grill
research
compound_lookup
architecture_orientation
prd
issues
module_structure
writing_plan
plan_review
folder_skeleton
implementation
work
verification
acceptance
compound_capture
compound_review
proposal
archive
handoff
```

Failure id:

```text
task_gate_unknown
```

- [ ] **Step 3: gate별 최소 산출물 존재와 내용 검사**

Presence is not enough. Each required markdown file must not be empty and must not contain only starter text.

Minimum checks:

```text
planning/03-prd.md: contains at least one requirement-like bullet after PRD heading.
planning/04-issues.md: contains at least one issue/work item.
planning/05-module-structure.md: contains at least one approved module path or explicit "no module yet" decision.
planning/06-writing-plan.md: contains checkbox steps.
planning/07-plan-review.md: contains at least one review decision or "no blocking issues" statement.
implementation-approval.md: contains required headings and at least one allowed or explicitly denied capability.
verification.md: contains command, expected result, actual result, and status.
handoff.md: contains next-chat prompt.
```

Failure id:

```text
gate_artifact_content_insufficient
```

- [ ] **Step 4: legacy ledger active task는 warning**

If active task contains:

```text
events.jsonl
gate-ledger.md
```

Warning:

```text
legacy_ledger_artifact_present
```

Do not fail. Do not read the file contents.

- [ ] **Step 5: live core surface ledger refs는 P0**

If live template/contract/rule surface still requires ledger:

```text
harness/contracts/ledger-event.schema.yaml exists
harness/templates/task/events.jsonl.template exists
harness/templates/task/gate-ledger.md exists
AGENTS/rules/workflow says events.jsonl is required/canonical
```

Failure id:

```text
ledger_reference_in_live_core
```

- [ ] **Step 6: hot context size 검사 강화**

Targets:

```text
AGENTS.md
harness/rules/workflow.md
active task task.yaml
active task planning/00-current-planning-context.md
```

Thresholds:

```text
warning: combined size > 12KB
failure: combined size > 24KB
```

Ids:

```text
hot_context_large_warning
hot_context_too_large
```

- [ ] **Step 7: doctor next action 변경**

Examples:

```js
legacy_ledger_artifact_present: 'Legacy ledger artifact found. Do not hot-read it. Migrate or archive only with explicit user approval.',
implementation_approval_missing: 'Ask the user for exact implementation approval and write implementation-approval.md before coding.',
approval_summary_missing: 'Update task.yaml approval_summary from the current chat approval; do not invent approval.',
ledger_reference_in_live_core: 'Remove the live ledger dependency from contracts/templates/rules before release.',
hot_context_too_large: 'Compact current planning context to decisions, open questions, and next action only.',
```

- [ ] **Step 8: tests 실행**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-verify-doctor.ps1
```

Expected: verify/doctor tests pass.

- [ ] **Step 9: Task 5 결과 보고**

Report failure/warning ids and sample outputs.

---

### Task 6: Compound promotion guard 유지

**Files:**
- Modify: `harness/lifecycle/learning-classifier.js`
- Modify: `harness/lifecycle/lifecycle.js`
- Modify: `harness/templates/task/learning-capture.md`
- Modify: `harness/templates/task/compound-review.md`
- Modify: `tests/contracts/test-learning-classifier.ps1`
- Modify: `tests/contracts/test-verify-doctor.ps1`

- [ ] **Step 1: learning classifier 입력을 event-free로 변경**

Input:

```js
classifyLearningCandidates({
  verificationText,
  acceptanceText,
  failures,
})
```

No `events` input.

- [ ] **Step 2: solution promotion guard 정의**

Long-term solution writes under `harness/docs/solutions/**` are allowed only when `compound-review.md` contains:

```text
결정: promote
반영할 장기 문서:
사용자 승인 근거:
```

If these are missing, verify fails with:

```text
compound_review_required_for_solution_write
```

- [ ] **Step 3: startup/hot context 제외 규칙 유지**

Rules must state:

```text
Compound docs are not startup context.
Read compound docs only when the current gate is compound_lookup, compound_capture, compound_review, or the user explicitly asks for recurrence prevention.
```

- [ ] **Step 4: tests 실행**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-learning-classifier.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-verify-doctor.ps1
```

Expected: both pass.

- [ ] **Step 5: Task 6 결과 보고**

Report promotion guard behavior and hot context rule.

---

### Task 7: AGENTS/README/rules 한글 설명 정리

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `CONTEXT.md`
- Modify: `harness/rules/rules.md`
- Modify: `harness/rules/workflow.md`
- Modify: `harness/rules/module-types.md`
- Modify: `harness/state/planning.md`
- Modify: `tests/contracts/test-workflow-rules.ps1`
- Modify: `tests/contracts/test-agents-readme.ps1`

- [ ] **Step 1: live 설명 표면에서 원장 권위 문구 제거**

Run:

```powershell
rg -n "events\.jsonl|gate-ledger|artifact_read|artifact_written|event_hash|canonical event|canonical log|ledger is the source" AGENTS.md README.md CONTEXT.md harness/rules harness/state
```

Expected: 제거할 live 문구가 출력된다. Legacy/archive 문맥이 아니면 제거한다.

- [ ] **Step 2: Required Reads를 hot-read 중심으로 정리**

Required reads:

```text
1. AGENTS.md
2. harness/rules/workflow.md
3. active task task.yaml, if one exists
4. active task planning/00-current-planning-context.md, if one exists
5. current gate artifact only when needed
```

- [ ] **Step 3: README 초보자 설명 작성**

README must explain:

```text
task.yaml: 현재 작업 상태표
planning/00-current-planning-context.md: 새 채팅용 짧은 요약
implementation-approval.md: 구현 전 승인 범위
verification.md: 검증 결과
handoff.md: 다음 채팅 인계
```

README must not say:

```text
events.jsonl은 승인 기록 원본
gate-ledger.md는 승인 기록
```

- [ ] **Step 4: 사용자 언어 규칙 명시**

Rules:

```text
Human-facing task documents use the user's language.
For Korean users, planning/*.md, implementation-approval.md, verification.md, handoff.md are Korean by default.
Machine-readable keys in task.yaml stay stable English.
```

- [ ] **Step 5: tests 실행**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-workflow-rules.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/test-agents-readme.ps1
```

Expected: both pass.

- [ ] **Step 6: Task 7 결과 보고**

Report docs changed and remaining live ledger references.

---

### Task 8: fresh install + existing update + create-task smoke

**Files:**
- No planned source edits unless smoke tests expose a concrete bug.

- [ ] **Step 1: 전체 계약 테스트 실행**

Run:

```powershell
npm.cmd run test:contracts
```

Expected:

```text
All contract tests passed.
```

- [ ] **Step 2: fresh install smoke**

Run:

```powershell
$root = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-ledgerless-smoke-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root | Out-Null
node bin/jjamppong.js install --target $root --template .
node (Join-Path $root 'harness\verify\verify.js') --root $root
node (Join-Path $root 'harness\doctor\doctor.js') --root $root
```

Expected:

```text
verify passed for
doctor found no P0 issues for
```

- [ ] **Step 3: create-task smoke**

Run:

```powershell
node (Join-Path $root 'harness\lifecycle\lifecycle.js') create-task --root $root --slug 'sample-task' --task-type 'product_feature'
Test-Path -LiteralPath (Join-Path $root 'harness\docs\tasks\active\sample-task\task.yaml')
Test-Path -LiteralPath (Join-Path $root 'harness\docs\tasks\active\sample-task\events.jsonl')
Test-Path -LiteralPath (Join-Path $root 'harness\docs\tasks\active\sample-task\gate-ledger.md')
```

Expected:

```text
True
False
False
```

- [ ] **Step 4: existing update smoke**

Run:

```powershell
$legacyRoot = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-legacy-update-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $legacyRoot | Out-Null
node bin/jjamppong.js install --target $legacyRoot --template .
New-Item -ItemType File -Path (Join-Path $legacyRoot 'harness\contracts\ledger-event.schema.yaml') -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $legacyRoot 'harness\templates\task\events.jsonl.template') -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $legacyRoot 'harness\templates\task\gate-ledger.md') -Force | Out-Null
node bin/jjamppong.js install --target $legacyRoot --template .
Test-Path -LiteralPath (Join-Path $legacyRoot 'harness\contracts\ledger-event.schema.yaml')
Test-Path -LiteralPath (Join-Path $legacyRoot 'harness\templates\task\events.jsonl.template')
Test-Path -LiteralPath (Join-Path $legacyRoot 'harness\templates\task\gate-ledger.md')
```

Expected:

```text
False
False
False
```

- [ ] **Step 5: cleanup**

Run:

```powershell
Remove-Item -LiteralPath $root -Recurse -Force
Remove-Item -LiteralPath $legacyRoot -Recurse -Force
```

- [ ] **Step 6: final live surface scan**

Run:

```powershell
rg -n "events\.jsonl|gate-ledger|artifact_read|artifact_written|event_hash|ledger-event|canonical_event_log" AGENTS.md README.md CONTEXT.md harness module-template tests
```

Expected: no required/canonical ledger dependency remains. Legacy warning strings are acceptable only when explicitly describing ignored legacy artifacts.

- [ ] **Step 7: final status report**

Run:

```powershell
git status --short --branch
```

Report:

```text
changed files
test results
smoke results
commit not performed unless user explicitly approved
```

---

## Self-Review

Spec coverage:

- `events.jsonl`, `gate-ledger.md`, artifact receipts, hash chain 제거: Task 1, 2, 3, 5, 8
- workflow adherence matrix: Task 0, Task 5, Task 8
- `task.yaml + planning context + approval + verification + handoff` 중심: Task 2, 3, 4, 5, 7
- hot-read 제한: Task 5, 7
- implementation approval 필수 구조: Task 3, 4, 5
- read/research 권한과 dangerous capability 분리: Task 4
- Compound Engineering 유지, startup 제외, promotion guard: Task 6
- legacy task warning 정책: Task 5, 8
- existing update smoke: Task 3, 8

Placeholder scan:

- 이 계획에는 미정 항목, 추후 작성 항목, 비어 있는 구현 지시를 두지 않는다.
- 각 task는 수정 파일, 실행 명령, 기대 결과, 보고 단계를 포함한다.
- Commit/push는 계획 내부에서 실행하지 않는다. 사용자가 그 시점에 명시 승인할 때만 별도 수행한다.

Type consistency:

- `implementation-approval.md`는 현재 채팅 승인에서 파생된 사람용 승인 요약이다.
- `task.yaml approval_summary`는 machine-readable 승인 cache다.
- `task.yaml`은 과거 히스토리를 담지 않는다.
- `events.jsonl`과 `gate-ledger.md`는 새 active task에서 생성되지 않는다.
- 기존 active task의 legacy ledger files는 warning이고, 새 생성/라이브 코어 의존은 failure다.
- Historical docs는 ledger 제거 검사 대상이 아니다.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-09-ledgerless-workflow-core.md`. Two execution options:

1. **Subagent-Driven (recommended)** - task별 fresh subagent를 띄우고, 각 task 완료 후 리뷰한다.
2. **Inline Execution** - 이 세션에서 `superpowers:executing-plans`로 순서대로 실행한다.

권장 방식은 1번이다. 변경 범위가 크고 `contracts/tests`, `lifecycle`, `permission`, `verify/doctor`, `docs`가 서로 충돌할 수 있어서 task별 리뷰가 필요하다.
