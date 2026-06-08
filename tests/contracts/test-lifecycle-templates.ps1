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
  'harness/templates/task/planning/03-prd.md',
  'harness/templates/task/planning/04-issues.md',
  'harness/templates/task/planning/05-module-structure.md',
  'harness/templates/task/planning/06-writing-plan.md',
  'harness/templates/task/planning/07-plan-review.md',
  'harness/templates/task/archive-summary.md',
  'harness/templates/module/module-state.md',
  'harness/docs/tasks/index.md',
  'harness/docs/tasks/archive/index.md'
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

$root = New-LifecycleRoot
try {
  $createOutput = & node $lifecycle create-task --root $root --slug 'test-task' --task-type 'product_feature'
  $created = ($createOutput -join "`n") | ConvertFrom-Json
  Assert-Check ($created.ok -eq $true) 'create-task should return ok.'

  $taskRoot = Join-Path $root 'harness\docs\tasks\active\test-task'
  foreach ($file in @('task.yaml', 'events.jsonl', 'gate-ledger.md', 'planning-pack.md', 'planning\00-current-planning-context.md', 'planning\06-writing-plan.md', 'archive-summary.md')) {
    Assert-Check (Test-Path -LiteralPath (Join-Path $taskRoot $file)) "create-task missing $file"
  }
  $events = Get-Content -LiteralPath (Join-Path $taskRoot 'events.jsonl') -Raw
  Assert-Check ([string]::IsNullOrWhiteSpace($events)) 'Live events.jsonl should start empty.'

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
