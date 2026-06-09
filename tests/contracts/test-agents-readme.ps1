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
  'harness/contracts/artifact-registry.yaml',
  'harness/contracts/skill-artifact-map.yaml',
  'harness/contracts/capability-catalog.yaml',
  'harness/contracts/task.schema.yaml',
  'harness/contracts/permission-decision.schema.yaml',
  'harness/rules/workflow.md',
  'active task task.yaml',
  'planning/00-current-planning-context.md',
  'implementation-approval.md',
  'PermissionDecision result',
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
  'Human-facing artifacts use the user''s language',
  'Machine-readable artifacts keep stable schema keys',
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
  'ourosuper',
  'active task events.jsonl',
  'gate-ledger.md',
  'artifact_read',
  'canonical events'
)) {
  Assert-Check (-not $agents.Contains($forbidden)) "AGENTS.md should not carry legacy/verbose token: $forbidden"
}

foreach ($token in @(
  '# 짬뽕하네스',
  'AI가 바로 코드를 만들지 않고',
  '프로젝트 폴더에 하네스를 설치하면',
  'Codex에게 설치시키기',
  'Codex에게 아래처럼 말하면 됩니다',
  'npm에 공개된 패키지로 설치할 수 있습니다',
  'jjamppong-harness@latest를 설치해줘',
  'npx jjamppong-harness@latest install --target 원하는-프로젝트-폴더',
  'GitHub 저장소 방식도 계속 사용할 수 있습니다',
  'vibedong/jjamppong-harness.git 설치해줘',
  '설치 후 verify까지만 하고 멈춰',
  '기존 .git과 origin은 보존',
  '설치 결과',
  '프로젝트 폴더/',
  'harness.lock.yaml',
  '잘못된 설치',
  '하네스가 막는 것',
  '실제 작업 흐름',
  'Gate id는 지금 어느 단계의 허락을 받는지 보여주는 이름표입니다',
  'task.yaml은 현재 작업 상태표입니다',
  'planning/00-current-planning-context.md는 새 채팅이 먼저 읽는 짧은 요약입니다',
  'implementation-approval.md는 구현 전 승인 범위입니다',
  'verification.md는 검증 결과입니다',
  'handoff.md는 새 채팅으로 넘길 상태 요약입니다',
  'handoff.md를 만든 뒤에는 다음 채팅에 붙여넣을 프롬프트를 채팅 응답으로 출력합니다',
  '자동으로 배운 점을 남기는 방식',
  'learning-capture.md',
  'compound-review.md',
  'harness/docs/solutions/',
  '필요한 문서를 확인하는 방식',
  'Gate id: planning',
  'Gate id: implementation',
  'Gate id: handoff',
  '좋은 문서가 아니라, AI가 통과해야 하는 문을 만든다'
)) {
  Assert-Check ($readme.Contains($token)) "README.md missing user-guide token: $token"
}

foreach ($forbidden in @(
  '이 저장소는 npm 패키지가 아닙니다',
  'F:/mptech',
  'F:mptech',
  '<설치할_프로젝트_폴더>',
  'npx @vibedong/jjamppong-harness@0.1.0',
  'npx github:vibedong/jjamppong-harness',
  'README is the source of truth',
  'README는 기준',
  'plan_review가 끝나면 구현',
  'events.jsonl은 실제 승인 기록 원본입니다',
  'gate-ledger.md',
  'artifact_read',
  '실제 읽은 흔적'
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
