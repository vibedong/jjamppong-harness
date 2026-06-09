param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$lifecycle = Join-Path $RepoRoot 'harness\lifecycle\lifecycle.js'
$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Check {
  param([bool]$Condition, [string]$Message)
  $script:checks += 1
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

function New-LifecycleRoot {
  $root = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-lifecycle-test-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $root | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $root 'harness') | Out-Null
  Copy-Item -LiteralPath (Join-Path $RepoRoot 'harness\templates') -Destination (Join-Path $root 'harness\templates') -Recurse
  New-Item -ItemType Directory -Path (Join-Path $root 'harness\docs\tasks\active') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $root 'harness\docs\tasks\archive') -Force | Out-Null
  return $root
}

foreach ($file in @(
  'harness/templates/task/task.yaml',
  'harness/templates/task/events.jsonl.template',
  'harness/templates/task/gate-ledger.md',
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
  'harness/templates/task/learning-capture.md',
  'harness/templates/task/compound-review.md',
  'harness/templates/task/archive-summary.md',
  'harness/templates/module/module-state.md',
  'harness/docs/tasks/index.md',
  'harness/docs/tasks/archive/index.md',
  'harness/docs/solutions/index.md',
  'harness/docs/solutions/harness-drift-patterns.md',
  'harness/docs/solutions/installer-flow-patterns.md',
  'harness/docs/solutions/planning-gate-patterns.md',
  'harness/docs/solutions/permission-boundary-patterns.md'
)) {
  Assert-Check (Test-Path -LiteralPath (Join-Path $RepoRoot $file)) "Missing lifecycle/template file: $file"
}

$planningState = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\state\planning.md') -Raw
Assert-Check ($planningState.Contains('events.jsonl')) 'Planning state must point at events.jsonl.'
Assert-Check ($planningState.Contains('gate-ledger.md') -and $planningState.Contains('projection')) 'Planning state must treat gate-ledger.md as projection.'
Assert-Check ($planningState.Contains('task.yaml') -and $planningState.Contains('cache')) 'Planning state must treat task.yaml as cache.'

$context = Get-Content -LiteralPath (Join-Path $RepoRoot 'CONTEXT.md') -Raw
Assert-Check ($context.Contains('Event log')) 'CONTEXT.md must define Event log.'
Assert-Check ($context.Contains('Archive summary')) 'CONTEXT.md must define Archive summary.'

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
Assert-Check ($eventsTemplate.Contains('template_only')) 'events.jsonl template must remain a template-only marker, not live approval evidence.'

$root = New-LifecycleRoot
try {
  $createOutput = & node $lifecycle create-task --root $root --slug 'test-task' --task-type 'product_feature'
  $created = ($createOutput -join "`n") | ConvertFrom-Json
  Assert-Check ($created.ok -eq $true) 'create-task should return ok.'

  $taskRoot = Join-Path $root 'harness\docs\tasks\active\test-task'
  foreach ($file in @('task.yaml', 'events.jsonl', 'gate-ledger.md', 'planning-pack.md', 'planning\00-current-planning-context.md', 'planning\06-writing-plan.md', 'learning-capture.md', 'compound-review.md', 'archive-summary.md')) {
    Assert-Check (Test-Path -LiteralPath (Join-Path $taskRoot $file)) "create-task missing $file"
  }
  $events = Get-Content -LiteralPath (Join-Path $taskRoot 'events.jsonl') -Raw
  Assert-Check ([string]::IsNullOrWhiteSpace($events)) 'Live events.jsonl should start empty.'
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

  $oldErrorActionPreference = $ErrorActionPreference
  $nativePreference = Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue
  $oldNativePreference = if ($null -ne $nativePreference) { $nativePreference.Value } else { $null }
  try {
    $ErrorActionPreference = 'Continue'
    if ($null -ne $nativePreference) {
      $PSNativeCommandUseErrorActionPreference = $false
    }
    $secondOutput = & node $lifecycle create-task --root $root --slug 'second-task' --task-type 'product_feature' 2>&1
    $secondExitCode = $LASTEXITCODE
  }
  finally {
    $ErrorActionPreference = $oldErrorActionPreference
    if ($null -ne $nativePreference) {
      $PSNativeCommandUseErrorActionPreference = $oldNativePreference
    }
  }
  Assert-Check ($secondExitCode -ne 0) 'create-task should reject a second active task by default.'
  Assert-Check (($secondOutput -join "`n").Contains('Active task default is one')) 'second active task rejection should explain active default one.'

  $archiveOutput = & node $lifecycle archive-task --root $root --slug 'test-task'
  $archived = ($archiveOutput -join "`n") | ConvertFrom-Json
  Assert-Check ($archived.ok -eq $true) 'archive-task should return ok.'
  Assert-Check (-not (Test-Path -LiteralPath $taskRoot)) 'archive-task should move task out of active.'
  Assert-Check (Test-Path -LiteralPath $archived.archive_root) 'archive-task should create archive root.'
  Assert-Check (Test-Path -LiteralPath (Join-Path $archived.archive_root 'archive-summary.md')) 'archive-summary.md should move with archived task.'
}
finally {
  Remove-Item -LiteralPath $root -Recurse -Force
}

if ($failures.Count -gt 0) {
  Write-Output "lifecycle/template tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "lifecycle/template tests passed $checks checks."
