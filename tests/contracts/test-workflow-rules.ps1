param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$workflow = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\rules\workflow.md') -Raw
$rules = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\rules\rules.md') -Raw
$rootHandoff = Get-Content -LiteralPath (Join-Path $RepoRoot 'handoff.md') -Raw
$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Check {
  param([bool]$Condition, [string]$Message)
  $script:checks += 1
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

foreach ($token in @(
  'harness/contracts/gate-contract-matrix.yaml',
  'install',
  'grill',
  'research',
  'plan_review completed != implementation approved',
  'folder_skeleton',
  'PermissionDecision',
  'task.yaml',
  'planning/00-current-planning-context.md',
  'implementation-approval.md',
  'Human-facing artifacts use the user''s language',
  'Machine-readable artifacts keep stable schema keys',
  'Agents write live human-facing artifacts in the current user''s language',
  'handoff.md is a status summary, not the restart prompt container',
  'The next-chat prompt is returned in the chat response',
  'Artifact Routing',
  'current gate artifact',
  'compound_lookup reads solution indexes before detailed solution files',
  'compound_capture records candidates in `learning-capture.md`',
  'compound_review decides long-term promotion',
  'learning-capture.md',
  'compound-review.md',
  'network.live_target',
  'package.install',
  'git.commit',
  'git.push',
  'file.write.outside_modules'
)) {
  Assert-Check ($workflow.Contains($token)) "workflow.md missing required token: $token"
}

foreach ($token in @(
  'FINAL-PLAN.md',
  'harness/contracts/*.yaml',
  'active task task.yaml',
  'planning/00-current-planning-context.md',
  'Missing capability: deny',
  'Short approval expansion: deny',
  'secret',
  'live target access',
  'package install',
  'git commit/push',
  'Harness-core writes in product tasks',
  'Gate Question Format',
  'Human-facing artifacts use the user''s language',
  'Machine-readable artifacts keep stable schema keys',
  'Static templates may use Korean starter copy',
  'When creating handoff.md, do not embed the restart prompt in the file by default',
  'After creating handoff.md, return a copy-paste next-chat prompt in the chat response',
  'handoff.md 보고 이어서 진행해줘',
  '먼저 AGENTS.md, harness/rules/workflow.md, 현재 active task의 task.yaml과 planning/00-current-planning-context.md를 확인해줘',
  '현재 gate 상태를 확인한 뒤, 바로 구현하지 말고 필요한 다음 단계부터 이어서 진행해줘',
  'module_structure does not create folders',
  'folder_skeleton does not create executable files',
  'plan_review does not unlock implementation',
  'doctor --proposal',
  'Before a gate or skill starts, check `harness/contracts/skill-artifact-map.yaml`',
  'Do not rely on memory for required artifacts',
  'Use the current gate artifact list',
  'Do not promote learning candidates into `harness/docs/solutions/` without `compound_review`',
  'compound_capture',
  'compound_review'
)) {
  Assert-Check ($rules.Contains($token)) "rules.md missing required token: $token"
}

foreach ($forbidden in @(
  'events.jsonl is the source',
  'canonical event',
  'Record `artifact_read` events',
  'gate-ledger.md = human-readable projection',
  'task.yaml/events.jsonl'
)) {
  Assert-Check (-not $rules.Contains($forbidden)) "rules.md must not contain legacy token: $forbidden"
  Assert-Check (-not $workflow.Contains($forbidden)) "workflow.md must not contain legacy token: $forbidden"
}

Assert-Check (-not ($rules -match 'implementation\s*\|\s*`Gate id: plan_review`')) 'rules.md must not use plan_review as implementation unlock table entry.'
Assert-Check (-not $rootHandoff.Contains('handoff.md 보고 이어서 진행해줘')) 'root handoff.md must not store the restart prompt by default.'

if ($failures.Count -gt 0) {
  Write-Output "workflow/rules tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "workflow/rules tests passed $checks checks."
