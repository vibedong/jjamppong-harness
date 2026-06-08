param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$agents = Get-Content -LiteralPath (Join-Path $RepoRoot 'AGENTS.md') -Raw
$readme = Get-Content -LiteralPath (Join-Path $RepoRoot 'README.md') -Raw
$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Check {
  param([bool]$Condition, [string]$Message)
  $script:checks += 1
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

$agentsLines = ($agents -split "`r?`n").Count
Assert-Check ($agentsLines -le 110) "AGENTS.md should stay short; found $agentsLines lines."

foreach ($token in @(
  'harness/contracts/gate-contract-matrix.yaml',
  'harness/contracts/capability-catalog.yaml',
  'harness/contracts/task.schema.yaml',
  'harness/contracts/permission-decision.schema.yaml',
  'harness/rules/workflow.md',
  'active task events.jsonl',
  'active task task.yaml',
  'PermissionDecision result',
  'gate-ledger.md',
  'task.yaml'
)) {
  Assert-Check ($agents.Contains($token)) "AGENTS.md missing source-of-truth token: $token"
}

foreach ($token in @(
  'vowline',
  'Do not start with README or AGENTS',
  'Install requests stop after install and verify',
  'Product planning starts with `grill`',
  '`research` comes after `grill`',
  '`plan_review completed` never unlocks implementation',
  '`module_structure` never creates folders',
  '`folder_skeleton` never creates code',
  'Short approvals approve only',
  'Missing or ambiguous capabilities are denied',
  'Product code belongs under `modules/`',
  'Secrets are deny-by-default',
  'Package install, live target access, commit, and push',
  'Harness-core changes in product tasks must become proposals',
  'Doctor/update/repair are proposal-only',
  'Ask user-facing gate questions in the user''s language',
  'git commit',
  'git push'
)) {
  Assert-Check ($agents.Contains($token)) "AGENTS.md missing hard-rule token: $token"
}

foreach ($forbidden in @(
  'Gate Response Test',
  'New Project Request Trigger',
  'Full Workflow',
  'OuroSuper',
  'ourosuper'
)) {
  Assert-Check (-not $agents.Contains($forbidden)) "AGENTS.md should not carry legacy/verbose token: $forbidden"
}

foreach ($token in @(
  '# 짬뽕하네스',
  'README는 안내서',
  'harness/contracts/',
  'PermissionDecision',
  'npx @vibedong/jjamppong-harness@0.1.0 install --target F:/mptech',
  '설치',
  '핵심 개념',
  '작업 흐름',
  '기획 시작',
  '진짜 작업 승인',
  'plan_review completed != implementation approved',
  '폴더틀',
  '코드',
  '테스트',
  'fixture',
  'live access',
  'package install',
  'commit',
  'push',
  'folder_skeleton',
  '검증',
  '안전 기준'
)) {
  Assert-Check ($readme.Contains($token)) "README.md missing user-guide token: $token"
}

foreach ($forbidden in @(
  '이 저장소는 npm 패키지가 아닙니다',
  'README is the source of truth',
  'README는 기준',
  'plan_review가 끝나면 구현'
)) {
  Assert-Check (-not $readme.Contains($forbidden)) "README.md should not contain outdated token: $forbidden"
}

if ($failures.Count -gt 0) {
  Write-Output "AGENTS/README tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "AGENTS/README tests passed $checks checks."
