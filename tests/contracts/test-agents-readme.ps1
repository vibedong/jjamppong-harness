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
  'Codex에게 아래 문구를 그대로 보내세요',
  'vibedong/jjamppong-harness.git F:/mptech에 설치해줘',
  'GitHub 공개 저장소를 임시 폴더에 clone',
  'node bin/jjamppong.js install --target F:/mptech --template <임시클론경로>',
  '설치 후 verify까지만 하고 멈춰',
  'planning, PRD, issue, module, code, package install, commit, push는 시작하지 마',
  '대상 프로젝트의 .git과 origin은 보존',
  '`F:/mptech`만 원하는 프로젝트 경로로 바꾸면 됩니다'
)) {
  Assert-Check ($readme.Contains($token)) "README.md missing user-guide token: $token"
}

foreach ($forbidden in @(
  '이 저장소는 npm 패키지가 아닙니다',
  'npx @vibedong/jjamppong-harness@0.1.0',
  'npx github:vibedong/jjamppong-harness',
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
