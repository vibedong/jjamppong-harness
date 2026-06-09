param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$verify = Join-Path $RepoRoot 'harness\verify\verify.js'
$doctor = Join-Path $RepoRoot 'harness\doctor\doctor.js'

$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Check {
  param([bool]$Condition, [string]$Message)
  $script:checks += 1
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

function Copy-IfExists {
  param([string]$RelativePath, [string]$Root)
  $source = Join-Path $RepoRoot $RelativePath
  if (Test-Path -LiteralPath $source) {
    $target = Join-Path $Root $RelativePath
    New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
  }
}

function New-FixtureRoot {
  $root = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-verify-test-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $root | Out-Null
  foreach ($file in @('AGENTS.md', 'README.md', 'CONTEXT.md', 'handoff.md')) {
    Set-Content -LiteralPath (Join-Path $root $file) -Value "$file fixture" -Encoding UTF8
  }
  foreach ($dir in @('harness', 'modules', 'module-template', 'proposals', 'harness\docs\tasks\active', 'harness\docs\tasks\archive')) {
    New-Item -ItemType Directory -Path (Join-Path $root $dir) -Force | Out-Null
  }
  Copy-IfExists -RelativePath 'harness\contracts' -Root $root
  Copy-IfExists -RelativePath 'harness\templates' -Root $root
  Copy-IfExists -RelativePath 'harness\rules' -Root $root
  Set-Content -LiteralPath (Join-Path $root 'harness.lock.yaml') -Value @(
    'harness:',
    '  name: jjamppong-harness',
    '  version: 0.1.0',
    'installer:',
    '  package: "jjamppong-harness"',
    '  version: 0.1.0',
    'installed_at: "2026-06-08T00:00:00+09:00"',
    'installed_from: test-fixture',
    'planning_started: false',
    'github_repo_created: false',
    'commit_created: false',
    'push_performed: false',
    'managed_files: []'
  ) -Encoding UTF8
  return $root
}

function Invoke-VerifyJson {
  param([string]$Root)
  $output = & node $verify --root $Root --json
  return ($output -join "`n") | ConvertFrom-Json
}

function Invoke-DoctorJson {
  param([string]$Root, [switch]$Proposal)
  $args = @($doctor, '--root', $Root, '--json')
  if ($Proposal) { $args += '--proposal' }
  $output = & node @args
  return ($output -join "`n") | ConvertFrom-Json
}

function New-ActiveTask {
  param(
    [string]$Root,
    [string]$Slug = 'task-one',
    [string]$Gate = 'intake',
    [string[]]$ExtraTaskYaml = @()
  )

  $taskDir = Join-Path $Root "harness\docs\tasks\active\$Slug"
  New-Item -ItemType Directory -Path (Join-Path $taskDir 'planning') -Force | Out-Null
  $lines = @(
    "task_id: $Slug",
    'task_type: product_feature',
    'status: active',
    "current_gate: $Gate",
    'approval_summary:',
    '  implementation: locked',
    '  allowed_capabilities: []',
    '  allowed_paths: []',
    '  package_install: false',
    '  network_live_target: false',
    '  git_commit: false',
    '  git_push: false'
  ) + $ExtraTaskYaml
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value $lines -Encoding UTF8
  return $taskDir
}

function Assert-HasIssueId {
  param([object]$Result, [string]$Id, [string]$Message, [string]$Kind = 'failure')
  $script:checks += 1
  $items = if ($Kind -eq 'warning') { @($Result.warnings) } else { @($Result.failures) }
  if (@($items | Where-Object { $_.id -eq $Id }).Count -lt 1) {
    $script:failures.Add($Message)
  }
}

$passRoot = New-FixtureRoot
try {
  $pass = Invoke-VerifyJson -Root $passRoot
  Assert-Check ($pass.ok -eq $true) "verify should pass a minimal ledgerless install fixture: $($pass.failures | ConvertTo-Json -Compress)"
}
finally {
  Remove-Item -LiteralPath $passRoot -Recurse -Force
}

$nestedRoot = New-FixtureRoot
try {
  New-Item -ItemType Directory -Path (Join-Path $nestedRoot 'jjamppong-harness') | Out-Null
  Set-Content -LiteralPath (Join-Path $nestedRoot 'jjamppong-harness\AGENTS.md') -Value 'nested' -Encoding UTF8
  $nested = Invoke-VerifyJson -Root $nestedRoot
  Assert-Check ($nested.ok -eq $false) 'verify should fail forbidden nested harness folder.'
  Assert-HasIssueId -Result $nested -Id 'nested_harness_folder' -Message 'nested harness failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $nestedRoot -Recurse -Force
}

$activeRoot = New-FixtureRoot
try {
  New-ActiveTask -Root $activeRoot -Slug 'task-one' | Out-Null
  New-ActiveTask -Root $activeRoot -Slug 'task-two' | Out-Null
  $active = Invoke-VerifyJson -Root $activeRoot
  Assert-Check ($active.ok -eq $false) 'verify should fail multiple active tasks by default.'
  Assert-HasIssueId -Result $active -Id 'active_task_single_default' -Message 'multiple active tasks failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $activeRoot -Recurse -Force
}

$legacyRoot = New-FixtureRoot
try {
  $taskDir = New-ActiveTask -Root $legacyRoot -Gate 'research'
  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'gate-ledger.md') -Value '# 승인 기록' -Encoding UTF8
  $legacy = Invoke-VerifyJson -Root $legacyRoot
  Assert-HasIssueId -Result $legacy -Id 'legacy_ledger_artifact_present' -Kind 'warning' -Message 'legacy active task ledger files should be warnings, not P0 failures.'
  Assert-Check (@($legacy.failures | Where-Object { $_.id -eq 'projection_without_canonical_event' -or $_.id -eq 'event_hash_chain_broken' }).Count -eq 0) 'legacy ledger files must not trigger canonical event/hash failures.'
}
finally {
  Remove-Item -LiteralPath $legacyRoot -Recurse -Force
}

$unknownGateRoot = New-FixtureRoot
try {
  New-ActiveTask -Root $unknownGateRoot -Gate 'made_up_gate' | Out-Null
  $unknownGate = Invoke-VerifyJson -Root $unknownGateRoot
  Assert-Check ($unknownGate.ok -eq $false) 'verify should fail unknown current_gate.'
  Assert-HasIssueId -Result $unknownGate -Id 'task_gate_unknown' -Message 'unknown gate failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $unknownGateRoot -Recurse -Force
}

$writingPlanMissingRoot = New-FixtureRoot
try {
  New-ActiveTask -Root $writingPlanMissingRoot -Gate 'writing_plan' | Out-Null
  $result = Invoke-VerifyJson -Root $writingPlanMissingRoot
  Assert-Check ($result.ok -eq $false) 'writing_plan should fail without required planning artifacts.'
  Assert-HasIssueId -Result $result -Id 'gate_required_artifact_missing' -Message 'writing_plan should report missing PRD/issues/module structure artifacts.'
}
finally {
  Remove-Item -LiteralPath $writingPlanMissingRoot -Recurse -Force
}

$writingPlanStaleRoot = New-FixtureRoot
try {
  $taskDir = New-ActiveTask -Root $writingPlanStaleRoot -Gate 'writing_plan'
  Set-Content -LiteralPath (Join-Path $taskDir 'planning\03-prd.md') -Value '# PRD' -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'planning\04-issues.md') -Value '# 이슈' -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'planning\05-module-structure.md') -Value '# 모듈 구조' -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'planning\06-writing-plan.md') -Value '# Writing Plan' -Encoding UTF8
  $result = Invoke-VerifyJson -Root $writingPlanStaleRoot
  Assert-Check ($result.ok -eq $false) 'writing_plan should fail when artifacts contain only starter text.'
  Assert-HasIssueId -Result $result -Id 'gate_artifact_content_insufficient' -Message 'writing_plan should report insufficient artifact content.'
}
finally {
  Remove-Item -LiteralPath $writingPlanStaleRoot -Recurse -Force
}

$implementationMissingRoot = New-FixtureRoot
try {
  New-ActiveTask -Root $implementationMissingRoot -Gate 'implementation' | Out-Null
  $result = Invoke-VerifyJson -Root $implementationMissingRoot
  Assert-Check ($result.ok -eq $false) 'implementation gate should fail without implementation-approval.md.'
  Assert-HasIssueId -Result $result -Id 'implementation_approval_missing' -Message 'implementation approval missing failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $implementationMissingRoot -Recurse -Force
}

$solutionWriteBlockedRoot = New-FixtureRoot
try {
  $taskDir = New-ActiveTask -Root $solutionWriteBlockedRoot -Gate 'compound_capture'
  New-Item -ItemType Directory -Path (Join-Path $solutionWriteBlockedRoot 'harness\docs\solutions') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $solutionWriteBlockedRoot 'harness\docs\solutions\harness-drift-patterns.md') -Value 'new long-term rule' -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'learning-capture.md') -Value @(
    '# 배운 점 후보',
    'candidate_count: 1',
    'source_verify_summary: repeated drift',
    'source_user_correction: user corrected harness drift',
    'no_candidate_reason:'
  ) -Encoding UTF8
  $result = Invoke-VerifyJson -Root $solutionWriteBlockedRoot
  Assert-Check ($result.ok -eq $false) 'solution writes should fail without compound_review approval.'
  Assert-HasIssueId -Result $result -Id 'compound_review_required_for_solution_write' -Message 'solution write failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $solutionWriteBlockedRoot -Recurse -Force
}

$hotWarningRoot = New-FixtureRoot
try {
  $taskDir = New-ActiveTask -Root $hotWarningRoot -Gate 'research'
  Set-Content -LiteralPath (Join-Path $taskDir 'planning\00-current-planning-context.md') -Value ('x' * 13000) -Encoding UTF8
  $result = Invoke-VerifyJson -Root $hotWarningRoot
  Assert-HasIssueId -Result $result -Id 'hot_context_large_warning' -Kind 'warning' -Message 'hot context warning id should be reported above 12KB.'
}
finally {
  Remove-Item -LiteralPath $hotWarningRoot -Recurse -Force
}

$hotFailureRoot = New-FixtureRoot
try {
  $taskDir = New-ActiveTask -Root $hotFailureRoot -Gate 'research'
  Set-Content -LiteralPath (Join-Path $taskDir 'planning\00-current-planning-context.md') -Value ('x' * 26000) -Encoding UTF8
  $result = Invoke-VerifyJson -Root $hotFailureRoot
  Assert-Check ($result.ok -eq $false) 'verify should fail when hot context exceeds hard limit.'
  Assert-HasIssueId -Result $result -Id 'hot_context_too_large' -Message 'hot context hard limit failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $hotFailureRoot -Recurse -Force
}

$doctorRoot = New-FixtureRoot
try {
  New-Item -ItemType Directory -Path (Join-Path $doctorRoot 'ourosuper-harness') | Out-Null
  Set-Content -LiteralPath (Join-Path $doctorRoot 'ourosuper-harness\AGENTS.md') -Value 'nested' -Encoding UTF8
  $doctorReadOnly = Invoke-DoctorJson -Root $doctorRoot
  Assert-Check ($doctorReadOnly.ok -eq $false) 'doctor should diagnose verify failures.'
  Assert-Check ([string]::IsNullOrWhiteSpace($doctorReadOnly.proposal_path)) 'doctor default should not create proposal.'
  Assert-Check (-not (Test-Path -LiteralPath (Join-Path $doctorRoot 'proposals\active'))) 'doctor default should not write proposals.'

  $doctorProposal = Invoke-DoctorJson -Root $doctorRoot -Proposal
  Assert-Check (-not [string]::IsNullOrWhiteSpace($doctorProposal.proposal_path)) 'doctor --proposal should report proposal path.'
  Assert-Check (Test-Path -LiteralPath $doctorProposal.proposal_path) 'doctor --proposal should create proposal file.'
}
finally {
  Remove-Item -LiteralPath $doctorRoot -Recurse -Force
}

if ($failures.Count -gt 0) {
  Write-Output "verify/doctor tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "verify/doctor tests passed $checks checks."
