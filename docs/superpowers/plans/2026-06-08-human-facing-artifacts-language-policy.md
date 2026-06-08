# 수정계획서: Human-Facing Artifacts Language Policy

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Jjamppong Harness explain Gate id, events.jsonl, gate-ledger.md, task.yaml, and handoff behavior in beginner-friendly user-language terms while keeping machine-readable artifacts stable.

**Architecture:** Keep machine-readable canonical files (`events.jsonl`, `task.yaml`, contracts, PermissionDecision outputs) schema-stable. Add a human-facing language policy to rules and README. Static templates may contain Korean starter copy, but agents must write live human-facing artifacts in the current user's language when presenting or updating them. This phase does not add lifecycle-level localization. Handoff restart prompts must be emitted in chat after creating `handoff.md`, not embedded in the handoff file.

**Tech Stack:** Markdown documentation, PowerShell contract tests, existing Node lifecycle/installer tooling.

---

## Plan Artifact Policy

This file is the reviewed revised plan and should be kept in git as planning evidence.

It is not part of the harness release payload. Keep `docs/superpowers/plans/` excluded from `harness/release/CHECKSUMS.sha256`.

---

## File Structure

- Keep `docs/superpowers/plans/2026-06-08-human-facing-artifacts-language-policy.md`: commit this revised plan as planning evidence, but exclude it from release checksums.
- Modify `README.md`: add beginner-friendly sections that explain `Gate id`, `events.jsonl`, `gate-ledger.md`, `task.yaml`, and `handoff.md`.
- Modify `AGENTS.md`: add a short hard rule that human-facing artifacts should use the user's language, while machine-readable artifacts keep stable schema keys.
- Modify `harness/rules/workflow.md`: add the canonical user-language policy and handoff chat-response policy.
- Modify `harness/rules/rules.md`: add enforceable rules for human-facing artifacts and handoff responses.
- Modify `handoff.md`: template-maintenance exception only. Keep the root handoff template as a status-summary file and state that restart prompts are returned in chat, not stored in the file.
- Modify `harness/templates/task/gate-ledger.md`: rewrite as a user-facing Korean template that still points to `events.jsonl` as the canonical source.
- Modify `harness/templates/task/archive-summary.md`: rewrite headings in Korean/user-facing wording.
- Modify `harness/templates/task/verification.md`: rewrite as a Korean/user-facing verification summary template.
- Modify `harness/templates/task/implementation-approval.md`: keep approval evidence tied to `events.jsonl`, but make the visible summary user-language friendly.
- Modify `harness/templates/task/planning-pack.md` and `harness/templates/task/planning/*.md`: make static starter headings Korean and user-facing, while preserving file names and stage roles. Agents must rewrite generated/live copies in the user's language.
- Modify `tests/contracts/test-agents-readme.ps1`: assert README and AGENTS include the new beginner-facing explanations and language policy.
- Modify `tests/contracts/test-workflow-rules.ps1`: assert workflow/rules include machine-vs-human artifact policy and handoff chat prompt policy.
- Modify `tests/contracts/test-lifecycle-templates.ps1`: assert human-facing templates include user-language/Korean wording and still reference canonical `events.jsonl`.
- Modify `harness/release/CHECKSUMS.sha256`: regenerate after all file edits.

---

## Implementation Approval Required

This reviewed plan is not implementation approval. Before executing Task 1, ask for explicit implementation approval in the current chat.

Use this approval request:

```text
Gate id: implementation

승인 범위: README.md, AGENTS.md, handoff.md, harness/rules/workflow.md, harness/rules/rules.md, harness/templates/task/**, tests/contracts/**, harness/release/CHECKSUMS.sha256 수정.
허용: 문서/템플릿/테스트/체크섬 수정 및 계약 테스트 실행.
잠김: package install, live access, npm publish, commit, push.
이 범위로 구현을 시작해도 될까요?
```

If approval is ambiguous, stop before file edits. Commit and push require separate later approvals.

---

### Task 1: Add README Beginner Explanations

**Files:**
- Modify: `README.md`
- Test: `tests/contracts/test-agents-readme.ps1`

- [ ] **Step 1: Write the failing README assertions**

In `tests/contracts/test-agents-readme.ps1`, extend the README token list with these exact strings:

```powershell
'Gate id는 지금 어느 단계의 허락을 받는지 보여주는 이름표입니다',
'events.jsonl은 실제 승인 기록 원본입니다',
'작업이 진행되면 events.jsonl에 새 줄이 추가될 수 있습니다',
'gate-ledger.md는 사람이 읽기 쉽게 정리한 승인 기록입니다',
'task.yaml은 현재 상태를 빠르게 읽는 요약 파일입니다',
'handoff.md는 새 채팅으로 넘길 상태 요약입니다',
'handoff.md를 만든 뒤에는 다음 채팅에 붙여넣을 프롬프트를 채팅 응답으로 출력합니다'
```

Also assert beginner examples for the most common gates without hardcoding a single project scenario:

```powershell
'Gate id: planning',
'Gate id: implementation',
'Gate id: handoff'
```

Keep the existing forbidden tokens for hardcoded install paths and npm commands:

```powershell
'F:/mptech',
'F:mptech',
'<설치할_프로젝트_폴더>',
'npx @vibedong/jjamppong-harness@0.1.0',
'npx github:vibedong/jjamppong-harness'
```

- [ ] **Step 2: Run the targeted failing test**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\test-agents-readme.ps1
```

Expected: FAIL with missing README token messages for the newly added strings.

- [ ] **Step 3: Add README sections**

In `README.md`, keep the current install prompt section. After `## 설치 결과`, add:

```markdown
## 자주 보이는 문구와 파일

`Gate id`는 지금 어느 단계의 허락을 받는지 보여주는 이름표입니다.

예를 들어 `Gate id: implementation`이 보이면 "이제 구현을 시작해도 되는지 묻는 단계"라는 뜻입니다.

자주 보이는 예시는 `Gate id: planning`, `Gate id: implementation`, `Gate id: handoff`입니다.

`events.jsonl`은 실제 승인 기록 원본입니다. 작업이 진행되면 events.jsonl에 새 줄이 추가될 수 있습니다. 이 파일이 바뀌는 것은 정상입니다. 다만 기존 기록을 마음대로 고쳐 쓰면 안 됩니다.

`gate-ledger.md`는 사람이 읽기 쉽게 정리한 승인 기록입니다. AI가 상황 파악용으로 읽을 수는 있지만, 권한 판단의 원본은 `events.jsonl`입니다.

`task.yaml`은 현재 상태를 빠르게 읽는 요약 파일입니다. 이것도 권한 원본은 아닙니다.

`handoff.md`는 새 채팅으로 넘길 상태 요약입니다. handoff.md를 만든 뒤에는 다음 채팅에 붙여넣을 프롬프트를 채팅 응답으로 출력합니다.
```

- [ ] **Step 4: Verify README assertions pass**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\test-agents-readme.ps1
```

Expected: PASS.

---

### Task 2: Add Human-vs-Machine Language Policy To Rules

**Files:**
- Modify: `AGENTS.md`
- Modify: `harness/rules/workflow.md`
- Modify: `harness/rules/rules.md`
- Test: `tests/contracts/test-agents-readme.ps1`
- Test: `tests/contracts/test-workflow-rules.ps1`

- [ ] **Step 1: Write failing rule assertions**

In `tests/contracts/test-agents-readme.ps1`, add AGENTS tokens:

```powershell
'Human-facing artifacts use the user''s language',
'Machine-readable artifacts keep stable schema keys',
'Static templates may use Korean starter copy',
'This phase does not add lifecycle-level localization'
```

In `tests/contracts/test-workflow-rules.ps1`, add workflow/rules tokens:

```powershell
'Human-facing artifacts use the user''s language',
'Machine-readable artifacts keep stable schema keys',
'events.jsonl, task.yaml, contracts, and PermissionDecision outputs keep stable machine-readable keys',
'gate-ledger.md, planning artifacts, archive-summary.md, verification.md, and handoff.md are human-facing',
'Agents write live human-facing artifacts in the current user''s language',
'This phase does not add lifecycle-level localization'
```

- [ ] **Step 2: Run targeted failing tests**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\test-agents-readme.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\test-workflow-rules.ps1
```

Expected: both fail on missing new policy tokens.

- [ ] **Step 3: Update AGENTS.md**

In `AGENTS.md`, under `## User Language`, add:

```markdown
- Human-facing artifacts use the user's language.
- Machine-readable artifacts keep stable schema keys.
- Static templates may use Korean starter copy; agents write live human-facing artifacts in the current user's language when presenting or updating them.
- This phase does not add lifecycle-level localization.
```

- [ ] **Step 4: Update workflow.md**

In `harness/rules/workflow.md`, after `## User-Facing Flow`, add:

```markdown
## Artifact Language Policy

Human-facing artifacts use the user's language.

Human-facing artifacts include `gate-ledger.md`, planning artifacts, `archive-summary.md`, `verification.md`, and `handoff.md`.

Static templates may use Korean starter copy. This phase does not add lifecycle-level localization. When an agent presents or updates live human-facing artifacts, the agent writes them in the current user's language.

Machine-readable artifacts keep stable schema keys.

Machine-readable artifacts include `events.jsonl`, `task.yaml`, contracts, and PermissionDecision outputs. events.jsonl, task.yaml, contracts, and PermissionDecision outputs keep stable machine-readable keys.
```

- [ ] **Step 5: Update rules.md**

In `harness/rules/rules.md`, after `## Hard Defaults`, add:

```markdown
## Artifact Language Policy

Human-facing artifacts use the user's language.

Static templates may use Korean starter copy. This phase does not add lifecycle-level localization. Agents write live human-facing artifacts in the current user's language when presenting or updating them.

Machine-readable artifacts keep stable schema keys.

`events.jsonl`, `task.yaml`, contracts, and PermissionDecision outputs keep stable machine-readable keys.

`gate-ledger.md`, planning artifacts, `archive-summary.md`, `verification.md`, and `handoff.md` are human-facing.
```

- [ ] **Step 6: Verify policy tests pass**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\test-agents-readme.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\test-workflow-rules.ps1
```

Expected: PASS.

---

### Task 3: Add Handoff Chat Response Policy

**Files:**
- Modify: `harness/rules/workflow.md`
- Modify: `harness/rules/rules.md`
- Modify: `handoff.md`
- Test: `tests/contracts/test-workflow-rules.ps1`

- [ ] **Step 1: Write failing handoff assertions**

In `tests/contracts/test-workflow-rules.ps1`, add required tokens for `rules.md`:

```powershell
'When creating handoff.md, do not embed the restart prompt in the file by default',
'After creating handoff.md, return a copy-paste next-chat prompt in the chat response',
'handoff.md 보고 이어서 진행해줘',
'먼저 AGENTS.md, harness/rules/workflow.md, 현재 active task의 task.yaml/events.jsonl을 확인해줘',
'현재 gate 상태를 확인한 뒤, 바로 구현하지 말고 필요한 다음 단계부터 이어서 진행해줘'
```

Add required tokens for `workflow.md`:

```powershell
'handoff.md is a status summary, not the restart prompt container',
'The next-chat prompt is returned in the chat response'
```

Add a negative assertion for root `handoff.md`:

```powershell
$rootHandoff = Get-Content -LiteralPath (Join-Path $RepoRoot 'handoff.md') -Raw
Assert-Check (-not $rootHandoff.Contains('handoff.md 보고 이어서 진행해줘')) 'root handoff.md must not store the restart prompt by default.'
```

- [ ] **Step 2: Run targeted failing test**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\test-workflow-rules.ps1
```

Expected: FAIL with missing handoff policy tokens.

- [ ] **Step 3: Update workflow.md**

At the end of the handoff section in `harness/rules/workflow.md`, replace the single sentence with:

```markdown
`handoff.md` is updated only when the user asks for a new-chat handoff.

handoff.md is a status summary, not the restart prompt container.

The next-chat prompt is returned in the chat response.
```

- [ ] **Step 4: Update rules.md**

At the end of `harness/rules/rules.md`, add:

````markdown
## Handoff Response

Root `handoff.md` is updated only when the user asks for handoff or new-chat transfer.

When creating handoff.md, do not embed the restart prompt in the file by default.

After creating handoff.md, return a copy-paste next-chat prompt in the chat response.

Use this Korean prompt when the user is working in Korean:

```text
handoff.md 보고 이어서 진행해줘.
먼저 AGENTS.md, harness/rules/workflow.md, 현재 active task의 task.yaml/events.jsonl을 확인해줘.
현재 gate 상태를 확인한 뒤, 바로 구현하지 말고 필요한 다음 단계부터 이어서 진행해줘.
```
````

- [ ] **Step 5: Update root handoff.md template**

This is a template-maintenance exception for the root handoff file. Replace `handoff.md` with:

```markdown
# Global Handoff

Root `handoff.md` is the global next-chat/context-transfer file.

Write this file in the user's language when the user requests a handoff.

Include status summary, current decisions, remaining work, risks, and files the next agent should read.

Do not store the next-chat restart prompt here by default. Return that prompt in the chat response after creating the handoff.

Task-specific summaries belong under:

`harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/brief.md`
```

- [ ] **Step 6: Verify handoff policy tests pass**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\test-workflow-rules.ps1
```

Expected: PASS.

---

### Task 4: Convert Human-Facing Templates To User-Language Starter Copy

**Files:**
- Modify: `harness/templates/task/gate-ledger.md`
- Modify: `harness/templates/task/archive-summary.md`
- Modify: `harness/templates/task/verification.md`
- Modify: `harness/templates/task/implementation-approval.md`
- Modify: `harness/templates/task/planning-pack.md`
- Modify: `harness/templates/task/planning/00-current-planning-context.md`
- Modify: `harness/templates/task/planning/01-grill-summary.md`
- Modify: `harness/templates/task/planning/02-research-summary.md`
- Modify: `harness/templates/task/planning/02b-compound-lookup.md`
- Modify: `harness/templates/task/planning/02c-architecture-orientation.md`
- Modify: `harness/templates/task/planning/03-prd.md`
- Modify: `harness/templates/task/planning/04-issues.md`
- Modify: `harness/templates/task/planning/05-module-structure.md`
- Modify: `harness/templates/task/planning/06-writing-plan.md`
- Modify: `harness/templates/task/planning/07-plan-review.md`
- Test: `tests/contracts/test-lifecycle-templates.ps1`

- [ ] **Step 1: Write failing template assertions**

In `tests/contracts/test-lifecycle-templates.ps1`, after existing template existence assertions, add missing planning template existence checks for:

```powershell
'harness/templates/task/planning/02b-compound-lookup.md',
'harness/templates/task/planning/02c-architecture-orientation.md'
```

Then load the template files and assert these tokens:

```powershell
$gateLedgerTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\gate-ledger.md') -Raw
Assert-Check ($gateLedgerTemplate.Contains('승인 기록')) 'gate-ledger template must be user-facing Korean by default.'
Assert-Check ($gateLedgerTemplate.Contains('원본 기록')) 'gate-ledger template must explain canonical source in Korean.'
Assert-Check ($gateLedgerTemplate.Contains('events.jsonl')) 'gate-ledger template must still reference events.jsonl.'
Assert-Check ($gateLedgerTemplate.Contains('이 파일만 보고 권한을 판단하지 마세요')) 'gate-ledger template must warn that it is not the authority.'

$archiveTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\archive-summary.md') -Raw
Assert-Check ($archiveTemplate.Contains('보관 요약')) 'archive summary template must be user-facing Korean by default.'

$verificationTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\verification.md') -Raw
Assert-Check ($verificationTemplate.Contains('검증 기록')) 'verification template must be user-facing Korean by default.'

$approvalTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\implementation-approval.md') -Raw
Assert-Check ($approvalTemplate.Contains('구현 승인 요약')) 'implementation approval template must be user-facing Korean by default.'
Assert-Check ($approvalTemplate.Contains('events.jsonl')) 'implementation approval template must still reference canonical events.'

$planningPackTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\planning-pack.md') -Raw
Assert-Check ($planningPackTemplate.Contains('최종 결정 manifest')) 'planning-pack template must define itself as a final decision manifest.'
Assert-Check ($planningPackTemplate.Contains('raw transcript를 누적하지 않습니다')) 'planning-pack template must reject raw transcript accumulation.'
Assert-Check ($planningPackTemplate.Contains('06-writing-plan.md')) 'planning-pack template must point to writing plan artifact.'

$planningTemplateTokens = @{
  '00-current-planning-context.md' = '현재 기획 맥락'
  '01-grill-summary.md' = '사용자 의도 질문 요약'
  '02-research-summary.md' = '자료조사 요약'
  '02b-compound-lookup.md' = 'Compound 조회'
  '02c-architecture-orientation.md' = '아키텍처 방향'
  '03-prd.md' = 'PRD'
  '04-issues.md' = '이슈'
  '05-module-structure.md' = '모듈 구조'
  '06-writing-plan.md' = 'Writing Plan'
  '07-plan-review.md' = '계획 리뷰'
}
foreach ($entry in $planningTemplateTokens.GetEnumerator()) {
  $content = Get-Content -LiteralPath (Join-Path $RepoRoot "harness\templates\task\planning\$($entry.Key)") -Raw
  Assert-Check ($content.Contains($entry.Value)) "planning template $($entry.Key) must contain unique token $($entry.Value)."
}

$taskYamlTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\task.yaml') -Raw
Assert-Check ($taskYamlTemplate.Contains('cache_projection: task.yaml')) 'task.yaml template must remain machine-readable cache projection.'
$eventsTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\events.jsonl.template') -Raw
Assert-Check ([string]::IsNullOrWhiteSpace($eventsTemplate)) 'events.jsonl template must remain empty canonical event log.'
```

Also extend the existing `create-task` section so it verifies generated task output, not only source templates:

```powershell
$liveGateLedger = Get-Content -LiteralPath (Join-Path $taskRoot 'gate-ledger.md') -Raw
Assert-Check ($liveGateLedger.Contains('승인 기록')) 'generated gate-ledger.md must use human-facing starter copy.'
Assert-Check ($liveGateLedger.Contains('events.jsonl')) 'generated gate-ledger.md must point to canonical events.'

$livePlanningPack = Get-Content -LiteralPath (Join-Path $taskRoot 'planning-pack.md') -Raw
Assert-Check ($livePlanningPack.Contains('최종 결정 manifest')) 'generated planning-pack.md must preserve decision-manifest wording.'
Assert-Check ($livePlanningPack.Contains('raw transcript를 누적하지 않습니다')) 'generated planning-pack.md must reject transcript dumping.'

foreach ($entry in $planningTemplateTokens.GetEnumerator()) {
  $content = Get-Content -LiteralPath (Join-Path $taskRoot "planning\$($entry.Key)") -Raw
  Assert-Check ($content.Contains($entry.Value)) "generated planning file $($entry.Key) must contain unique token $($entry.Value)."
}
```

- [ ] **Step 2: Run targeted failing test**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\test-lifecycle-templates.ps1
```

Expected: FAIL with missing starter-copy and generated-output token messages.

- [ ] **Step 3: Replace gate-ledger.md template**

Replace `harness/templates/task/gate-ledger.md` with:

````markdown
# 승인 기록

이 파일은 사람이 읽기 쉽게 정리한 승인 기록입니다.

원본 기록:

```text
events.jsonl
```

이 파일만 보고 권한을 판단하지 마세요. 실제 권한 판단은 `events.jsonl`, contracts, PermissionDecision을 기준으로 합니다.

## 현재 상태

- 현재 단계:
- 마지막으로 승인된 것:
- 아직 잠긴 것:

## 승인 내역

아직 기록된 승인 내역이 없습니다.
````

- [ ] **Step 4: Replace archive-summary.md template**

Replace `harness/templates/task/archive-summary.md` with:

```markdown
# 보관 요약

active task를 archive로 옮기기 전에 작성하는 사람용 요약입니다.

## 결과

- 상태:
- 사용자 확인:
- 미룬 일:
- 막힌 일:

## 다시 쓸 수 있는 배움

- 아직 없음

## 원본 해시

| 산출물 | 해시 |
| --- | --- |
```

- [ ] **Step 5: Replace verification.md template**

Replace `harness/templates/task/verification.md` with:

```markdown
# 검증 기록

검증 명령, 결과, 남은 위험을 적습니다.

## 실행한 검증

| 명령 | 기대 결과 | 실제 결과 | 통과 여부 |
| --- | --- | --- | --- |

## 남은 위험

- 아직 없음
```

- [ ] **Step 6: Replace implementation-approval.md template**

Replace `harness/templates/task/implementation-approval.md` with:

```markdown
# 구현 승인 요약

이 파일은 사람이 읽기 위한 승인 요약입니다.

실제 승인 근거는 반드시 `events.jsonl`에 있어야 합니다.

## 승인 범위

- 허용된 작업:
- 허용된 경로:
- 아직 잠긴 작업:
```

- [ ] **Step 7: Update planning templates**

Replace `harness/templates/task/planning-pack.md` with:

```markdown
# Planning Pack

이 파일은 최종 결정 manifest입니다. raw transcript를 누적하지 않습니다.

## 현재 결정

- 목표:
- 제외 범위:
- 성공 기준:
- 승인된 다음 단계:

## 읽어야 할 세부 산출물

- planning/00-current-planning-context.md
- planning/01-grill-summary.md
- planning/02-research-summary.md
- planning/02b-compound-lookup.md
- planning/02c-architecture-orientation.md
- planning/03-prd.md
- planning/04-issues.md
- planning/05-module-structure.md
- planning/06-writing-plan.md
- planning/07-plan-review.md
```

Replace each planning template with the exact matching content below. Preserve file names.

`harness/templates/task/planning/00-current-planning-context.md`:

```markdown
# 현재 기획 맥락

writing_plan이 읽을 압축된 현재 맥락입니다.
```

`harness/templates/task/planning/01-grill-summary.md`:

```markdown
# 사용자 의도 질문 요약

사용자가 원하는 결과, 제외 범위, 성공 기준을 정리합니다.
```

`harness/templates/task/planning/02-research-summary.md`:

```markdown
# 자료조사 요약

승인된 자료조사 결과와 근거를 정리합니다.
```

`harness/templates/task/planning/02b-compound-lookup.md`:

```markdown
# Compound 조회

관련 과거 배움이나 패턴을 정리합니다.
```

`harness/templates/task/planning/02c-architecture-orientation.md`:

```markdown
# 아키텍처 방향

필요한 경우 PRD 확정 전에 기술적 모양을 사용자 언어로 설명합니다.
```

`harness/templates/task/planning/03-prd.md`:

```markdown
# PRD

제품 요구사항과 성공 기준을 정리합니다.
```

`harness/templates/task/planning/04-issues.md`:

```markdown
# 이슈

독립적으로 진행 가능한 작업 단위를 정리합니다.
```

`harness/templates/task/planning/05-module-structure.md`:

```markdown
# 모듈 구조

구현을 어디에 둘지 정리합니다. 이 문서는 폴더 생성을 승인하지 않습니다.
```

`harness/templates/task/planning/06-writing-plan.md`:

```markdown
# Writing Plan

구현 계획을 정리합니다. 이 문서는 구현 승인이 아닙니다.
```

`harness/templates/task/planning/07-plan-review.md`:

```markdown
# 계획 리뷰

CEO, 엔지니어링, 준수 관점의 리뷰 결과를 정리합니다.
```

- [ ] **Step 8: Verify lifecycle/template tests pass**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\test-lifecycle-templates.ps1
```

Expected: PASS.

---

### Task 5: Update Release Checksums And Run Full Verification

**Files:**
- Modify: `harness/release/CHECKSUMS.sha256`

- [ ] **Step 1: Regenerate checksums**

Run:

```powershell
$repo = (git rev-parse --show-toplevel).Trim()
$checksumPath = Join-Path $repo 'harness\release\CHECKSUMS.sha256'
$files = Get-ChildItem -LiteralPath $repo -File -Recurse -Force | Where-Object {
  $relative = $_.FullName.Substring($repo.Length + 1).Replace('\','/')
  -not ($relative -match '(^|/)\.git(/|$)') -and
  -not ($relative -match '(^|/)node_modules(/|$)') -and
  -not ($relative -match '(^|/)\.harness-backups(/|$)') -and
  -not ($relative -match '(^|/)source-history(/|$)') -and
  -not ($relative -match '^docs/superpowers/plans/') -and
  -not ($relative -eq 'harness/release/CHECKSUMS.sha256') -and
  -not ($relative -match '^harness/docs/tasks/active/.+')
} | Sort-Object FullName
$lines = foreach ($file in $files) {
  $relative = $file.FullName.Substring($repo.Length + 1).Replace('\','/')
  $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
  "$hash  $relative"
}
Set-Content -LiteralPath $checksumPath -Value $lines -Encoding UTF8
```

Expected: `harness/release/CHECKSUMS.sha256` updates.

- [ ] **Step 2: Run full contract suite**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\contracts\run-all.ps1
```

Expected:

```text
All contract tests passed.
```

- [ ] **Step 3: Confirm no install path placeholders regressed**

Run:

```powershell
rg -n "F:/mptech|F:mptech|<설치할_프로젝트_폴더>|npx @vibedong/jjamppong-harness@0.1.0|npx github:vibedong/jjamppong-harness" README.md
```

Expected: no output.

- [ ] **Step 4: Confirm machine-readable authority files were not changed**

Run:

```powershell
$changed = git diff --name-only
$forbidden = $changed | Where-Object {
  $_ -match '^harness/contracts/' -or
  $_ -match '^harness/permission/' -or
  $_ -eq 'harness/templates/task/task.yaml' -or
  $_ -eq 'harness/templates/task/events.jsonl.template'
}
if ($forbidden) {
  throw "Unexpected machine-readable authority changes: $($forbidden -join ', ')"
}
```

Expected: no exception.

- [ ] **Step 5: Show changed files before any git operation**

Run:

```powershell
git status --short
```

Expected: only the planned implementation files plus this revised plan file are modified. This plan file is committed as planning evidence, but is not part of the release checksum.

- [ ] **Step 6: Commit only after explicit user approval**

Do not commit automatically. If the user explicitly approves commit in the current chat, run:

```powershell
$branch = (git branch --show-current).Trim()
if ($branch -ne 'main') {
  throw "Refusing commit on non-main branch: $branch"
}
$filesToStage = @(
  'README.md',
  'AGENTS.md',
  'handoff.md',
  'harness/rules/workflow.md',
  'harness/rules/rules.md',
  'harness/templates/task/gate-ledger.md',
  'harness/templates/task/archive-summary.md',
  'harness/templates/task/verification.md',
  'harness/templates/task/implementation-approval.md',
  'harness/templates/task/planning-pack.md',
  'harness/templates/task/planning/00-current-planning-context.md',
  'harness/templates/task/planning/01-grill-summary.md',
  'harness/templates/task/planning/02-research-summary.md',
  'harness/templates/task/planning/02b-compound-lookup.md',
  'harness/templates/task/planning/02c-architecture-orientation.md',
  'harness/templates/task/planning/03-prd.md',
  'harness/templates/task/planning/04-issues.md',
  'harness/templates/task/planning/05-module-structure.md',
  'harness/templates/task/planning/06-writing-plan.md',
  'harness/templates/task/planning/07-plan-review.md',
  'tests/contracts/test-agents-readme.ps1',
  'tests/contracts/test-workflow-rules.ps1',
  'tests/contracts/test-lifecycle-templates.ps1',
  'harness/release/CHECKSUMS.sha256',
  'docs/superpowers/plans/2026-06-08-human-facing-artifacts-language-policy.md'
)
git add -- $filesToStage
git commit -m "Document human-facing artifact language policy"
```

Expected: commit succeeds, then verify `git status --short --branch` is clean except possible ahead-of-origin state.

- [ ] **Step 7: Push only after separate explicit user approval**

Do not push automatically. If the user explicitly approves push in the current chat, first confirm branch and remote target:

```powershell
git branch --show-current
git remote -v
git status --short --branch
```

Expected before push: current branch is `main`, remote is the intended GitHub repository, and the branch is ahead of `origin/main` only by the just-approved commit.

Then run:

```powershell
git push origin main
```

Expected: push completes, then verify `git status --short --branch` is clean and `HEAD` equals `origin/main`.

---

## Self-Review

- Spec coverage: Covers user-language human artifacts, stable machine schema, Gate id/events/gate-ledger/task.yaml README explanation, handoff chat prompt policy, template updates, tests, checksums, and no implicit commit.
- Placeholder scan: No `TBD`, `TODO`, or unspecified code steps.
- Scope check: Single subsystem: documentation/rules/templates/tests for human-facing artifact language policy.
- Safety: Plan preserves `events.jsonl` and `task.yaml` machine semantics and does not authorize implementation, package install, live access, commit, or push without explicit approval.
