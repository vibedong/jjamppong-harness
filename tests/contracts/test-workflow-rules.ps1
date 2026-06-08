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
  'events.jsonl',
  'gate-ledger.md',
  'task.yaml',
  'Human-facing artifacts use the user''s language',
  'Machine-readable artifacts keep stable schema keys',
  'events.jsonl, task.yaml, contracts, and PermissionDecision outputs keep stable machine-readable keys',
  'gate-ledger.md, planning artifacts, archive-summary.md, verification.md, and handoff.md are human-facing',
  'Agents write live human-facing artifacts in the current user''s language',
  'This phase does not add lifecycle-level localization',
  'handoff.md is a status summary, not the restart prompt container',
  'The next-chat prompt is returned in the chat response',
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
  'active task events.jsonl',
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
  'events.jsonl, task.yaml, contracts, and PermissionDecision outputs keep stable machine-readable keys',
  'gate-ledger.md, planning artifacts, archive-summary.md, verification.md, and handoff.md are human-facing',
  'Static templates may use Korean starter copy',
  'This phase does not add lifecycle-level localization',
  'When creating handoff.md, do not embed the restart prompt in the file by default',
  'After creating handoff.md, return a copy-paste next-chat prompt in the chat response',
  'handoff.md 보고 이어서 진행해줘',
  '먼저 AGENTS.md, harness/rules/workflow.md, 현재 active task의 task.yaml/events.jsonl을 확인해줘',
  '현재 gate 상태를 확인한 뒤, 바로 구현하지 말고 필요한 다음 단계부터 이어서 진행해줘',
  'module_structure does not create folders',
  'folder_skeleton does not create executable files',
  'plan_review does not unlock implementation',
  'doctor --proposal'
)) {
  Assert-Check ($rules.Contains($token)) "rules.md missing required token: $token"
}

Assert-Check (-not ($rules -match 'implementation\s*\|\s*`Gate id: plan_review`')) 'rules.md must not use plan_review as implementation unlock table entry.'
Assert-Check (-not ($rules -match 'ledger is the source of truth')) 'rules.md must not say ledger is the source of truth.'
Assert-Check (-not ($workflow -match 'ledger is the source of truth')) 'workflow.md must not say ledger is the source of truth.'
Assert-Check (-not $rootHandoff.Contains('handoff.md 보고 이어서 진행해줘')) 'root handoff.md must not store the restart prompt by default.'

if ($failures.Count -gt 0) {
  Write-Output "workflow/rules tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "workflow/rules tests passed $checks checks."
