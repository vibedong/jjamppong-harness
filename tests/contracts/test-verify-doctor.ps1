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

function New-FixtureRoot {
  $root = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-verify-test-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $root | Out-Null
  foreach ($file in @('AGENTS.md', 'README.md', 'CONTEXT.md', 'handoff.md')) {
    Set-Content -LiteralPath (Join-Path $root $file) -Value "$file fixture" -Encoding UTF8
  }
  foreach ($dir in @('harness', 'modules', 'module-template', 'proposals', 'harness\docs\tasks\active', 'harness\docs\tasks\archive')) {
    New-Item -ItemType Directory -Path (Join-Path $root $dir) -Force | Out-Null
  }
  Copy-Item -LiteralPath (Join-Path $RepoRoot 'harness\contracts') -Destination (Join-Path $root 'harness\contracts') -Recurse
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

function New-Event {
  param(
    [string]$TaskId,
    [string]$EventId,
    [string]$EventType,
    [string]$PreviousHash,
    [string]$EventHash,
    [object]$Payload
  )
  return [ordered]@{
    event_id = $EventId
    schema_version = '0.1.0'
    task_id = $TaskId
    event_type = $EventType
    created_at = '2026-06-09T00:00:00+09:00'
    actor_type = 'assistant'
    previous_hash = $PreviousHash
    event_hash = $EventHash
    payload = $Payload
  } | ConvertTo-Json -Compress
}

function Write-Events {
  param([string]$Path, [string[]]$Events)
  Set-Content -LiteralPath $Path -Value ($Events -join "`n") -Encoding UTF8
}

function Get-TestFileSha256 {
  param([string]$Path)
  $stream = [System.IO.File]::OpenRead($Path)
  try {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
      $hash = $sha.ComputeHash($stream)
      return "sha256:$(([System.BitConverter]::ToString($hash) -replace '-', '').ToLowerInvariant())"
    }
    finally {
      $sha.Dispose()
    }
  }
  finally {
    $stream.Dispose()
  }
}

$passRoot = New-FixtureRoot
try {
  $pass = Invoke-VerifyJson -Root $passRoot
  Assert-Check ($pass.ok -eq $true) "verify should pass a minimal install fixture: $($pass.failures | ConvertTo-Json -Compress)"
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
  Assert-Check (@($nested.failures | Where-Object { $_.id -eq 'nested_harness_folder' }).Count -eq 1) 'nested harness failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $nestedRoot -Recurse -Force
}

$activeRoot = New-FixtureRoot
try {
  New-Item -ItemType Directory -Path (Join-Path $activeRoot 'harness\docs\tasks\active\task-one') | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $activeRoot 'harness\docs\tasks\active\task-two') | Out-Null
  $active = Invoke-VerifyJson -Root $activeRoot
  Assert-Check ($active.ok -eq $false) 'verify should fail multiple active tasks by default.'
  Assert-Check (@($active.failures | Where-Object { $_.id -eq 'active_task_single_default' }).Count -eq 1) 'multiple active tasks failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $activeRoot -Recurse -Force
}

$projectionRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $projectionRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @('task_id: task-one', 'approved: true', 'capability: file.write.module') -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
  $projection = Invoke-VerifyJson -Root $projectionRoot
  Assert-Check ($projection.ok -eq $false) 'verify should fail task.yaml permission without canonical event.'
  Assert-Check (@($projection.failures | Where-Object { $_.id -eq 'projection_without_canonical_event' }).Count -eq 1) 'projection drift failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $projectionRoot -Recurse -Force
}

$writingPlanMissingReceiptRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $writingPlanMissingReceiptRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: product_feature',
    'status: active',
    'current_gate: writing_plan'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
  $result = Invoke-VerifyJson -Root $writingPlanMissingReceiptRoot
  Assert-Check ($result.ok -eq $false) 'writing_plan should fail without required artifact read receipts.'
  Assert-Check (@($result.failures | Where-Object { $_.id -eq 'artifact_read_receipt_missing' }).Count -ge 3) 'writing_plan should report missing PRD, issues, and module structure receipts.'
}
finally {
  Remove-Item -LiteralPath $writingPlanMissingReceiptRoot -Recurse -Force
}

$writingPlanReceiptRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $writingPlanReceiptRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path (Join-Path $taskDir 'planning') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: product_feature',
    'status: active',
    'current_gate: writing_plan'
  ) -Encoding UTF8
  $contextPath = Join-Path $taskDir 'planning\00-current-planning-context.md'
  $prdPath = Join-Path $taskDir 'planning\03-prd.md'
  $issuesPath = Join-Path $taskDir 'planning\04-issues.md'
  $modulePath = Join-Path $taskDir 'planning\05-module-structure.md'
  $writingPath = Join-Path $taskDir 'planning\06-writing-plan.md'
  $contextRel = 'harness/docs/tasks/active/task-one/planning/00-current-planning-context.md'
  $prdRel = 'harness/docs/tasks/active/task-one/planning/03-prd.md'
  $issuesRel = 'harness/docs/tasks/active/task-one/planning/04-issues.md'
  $moduleRel = 'harness/docs/tasks/active/task-one/planning/05-module-structure.md'
  $writingRel = 'harness/docs/tasks/active/task-one/planning/06-writing-plan.md'
  Set-Content -LiteralPath $contextPath -Value 'context' -Encoding UTF8
  Set-Content -LiteralPath $prdPath -Value 'prd' -Encoding UTF8
  Set-Content -LiteralPath $issuesPath -Value 'issues' -Encoding UTF8
  Set-Content -LiteralPath $modulePath -Value 'module' -Encoding UTF8
  Set-Content -LiteralPath $writingPath -Value 'writing plan' -Encoding UTF8
  $eventsPath = Join-Path $taskDir 'events.jsonl'
  $events = @(
    (New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'artifact_read' -PreviousHash '' -EventHash 'h1' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_current_context'; path = $contextRel; hash = (Get-TestFileSha256 -Path $contextPath); proof_type = 'file_sha256' }),
    (New-Event -TaskId 'task-one' -EventId 'evt-2' -EventType 'artifact_read' -PreviousHash 'h1' -EventHash 'h2' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_prd'; path = $prdRel; hash = (Get-TestFileSha256 -Path $prdPath); proof_type = 'file_sha256' }),
    (New-Event -TaskId 'task-one' -EventId 'evt-3' -EventType 'artifact_read' -PreviousHash 'h2' -EventHash 'h3' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_issues'; path = $issuesRel; hash = (Get-TestFileSha256 -Path $issuesPath); proof_type = 'file_sha256' }),
    (New-Event -TaskId 'task-one' -EventId 'evt-4' -EventType 'artifact_read' -PreviousHash 'h3' -EventHash 'h4' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_module_structure'; path = $moduleRel; hash = (Get-TestFileSha256 -Path $modulePath); proof_type = 'file_sha256' }),
    (New-Event -TaskId 'task-one' -EventId 'evt-5' -EventType 'artifact_written' -PreviousHash 'h4' -EventHash 'h5' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_writing_plan'; path = $writingRel; hash = (Get-TestFileSha256 -Path $writingPath) })
  )
  Write-Events -Path $eventsPath -Events $events
  $result = Invoke-VerifyJson -Root $writingPlanReceiptRoot
  Assert-Check ($result.ok -eq $true) "writing_plan should pass when required receipts exist: $($result.failures | ConvertTo-Json -Compress)"
}
finally {
  Remove-Item -LiteralPath $writingPlanReceiptRoot -Recurse -Force
}

$compoundLookupMissingRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $compoundLookupMissingRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: product_feature',
    'status: active',
    'current_gate: compound_lookup'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
  $result = Invoke-VerifyJson -Root $compoundLookupMissingRoot
  Assert-Check ($result.ok -eq $false) 'compound_lookup should fail without compound_state and solutions_index receipts.'
  Assert-Check (@($result.failures | Where-Object { $_.id -eq 'artifact_read_receipt_missing' }).Count -ge 2) 'compound_lookup should report missing compound receipts.'
}
finally {
  Remove-Item -LiteralPath $compoundLookupMissingRoot -Recurse -Force
}

$solutionWriteBlockedRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $solutionWriteBlockedRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: knowledge_maintenance',
    'status: active',
    'current_gate: compound_capture'
  ) -Encoding UTF8
  $eventsPath = Join-Path $taskDir 'events.jsonl'
  $events = @(
    (New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'artifact_written' -PreviousHash '' -EventHash 'h1' -Payload @{ path = 'harness/docs/solutions/harness-drift-patterns.md' })
  )
  Write-Events -Path $eventsPath -Events $events
  $result = Invoke-VerifyJson -Root $solutionWriteBlockedRoot
  Assert-Check ($result.ok -eq $false) 'solution writes should fail without compound_review approval.'
  Assert-Check (@($result.failures | Where-Object { $_.id -eq 'compound_review_required_for_solution_write' }).Count -eq 1) 'solution write failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $solutionWriteBlockedRoot -Recurse -Force
}

$staleLearningCaptureRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $staleLearningCaptureRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: knowledge_maintenance',
    'status: active',
    'current_gate: compound_capture'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'learning-capture.md') -Value @(
    '# 배운 점 후보',
    '',
    '아직 기록된 후보가 없습니다.'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
  $result = Invoke-VerifyJson -Root $staleLearningCaptureRoot
  Assert-Check ($result.ok -eq $false) 'compound_capture should fail with untouched learning-capture starter text.'
  Assert-Check (@($result.failures | Where-Object { $_.id -eq 'learning_capture_stale_template' }).Count -eq 1) 'stale learning capture failure id should be reported.'
}
finally {
  Remove-Item -LiteralPath $staleLearningCaptureRoot -Recurse -Force
}

$wrongTaskReceiptRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $wrongTaskReceiptRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path (Join-Path $taskDir 'planning') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: product_feature',
    'status: active',
    'current_gate: writing_plan'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'planning\03-prd.md') -Value 'prd' -Encoding UTF8
  $events = @(
    (New-Event -TaskId 'other-task' -EventId 'evt-1' -EventType 'artifact_read' -PreviousHash '' -EventHash 'h1' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_prd'; path = 'harness/docs/tasks/active/task-one/planning/03-prd.md'; hash = 'sha256:fake'; proof_type = 'file_sha256' })
  )
  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
  $result = Invoke-VerifyJson -Root $wrongTaskReceiptRoot
  Assert-Check ($result.ok -eq $false) 'artifact_read from a different task_id must not satisfy required reads.'
}
finally {
  Remove-Item -LiteralPath $wrongTaskReceiptRoot -Recurse -Force
}

$staleHashRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $staleHashRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path (Join-Path $taskDir 'planning') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: product_feature',
    'status: active',
    'current_gate: writing_plan'
  ) -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $taskDir 'planning\03-prd.md') -Value 'changed content' -Encoding UTF8
  $events = @(
    (New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'artifact_read' -PreviousHash '' -EventHash 'h1' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_prd'; path = 'harness/docs/tasks/active/task-one/planning/03-prd.md'; hash = 'sha256:stale'; proof_type = 'file_sha256' })
  )
  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
  $result = Invoke-VerifyJson -Root $staleHashRoot
  Assert-Check ($result.ok -eq $false) 'stale artifact_read hash must not satisfy required reads.'
}
finally {
  Remove-Item -LiteralPath $staleHashRoot -Recurse -Force
}

$solutionWriteScopedRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $solutionWriteScopedRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: knowledge_maintenance',
    'status: active',
    'current_gate: compound_review'
  ) -Encoding UTF8
  $events = @(
    (New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'compound_review_decision' -PreviousHash '' -EventHash 'h1' -Payload @{ candidate_ref = 'cand-1'; decision = 'promote'; reason = 'repeated violation'; target_solution_path = 'harness/docs/solutions/installer-flow-patterns.md'; user_approval_event_id = 'evt-user-1' }),
    (New-Event -TaskId 'task-one' -EventId 'evt-2' -EventType 'artifact_written' -PreviousHash 'h1' -EventHash 'h2' -Payload @{ gate_id = 'compound_review'; artifact_id = 'selected_relevant_solutions'; path = 'harness/docs/solutions/harness-drift-patterns.md'; hash = 'sha256:dummy'; candidate_ref = 'cand-1' })
  )
  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
  $result = Invoke-VerifyJson -Root $solutionWriteScopedRoot
  Assert-Check ($result.ok -eq $false) 'solution write must fail when compound_review target path does not match.'
}
finally {
  Remove-Item -LiteralPath $solutionWriteScopedRoot -Recurse -Force
}

$solutionWriteWrongCandidateRoot = New-FixtureRoot
try {
  $taskDir = Join-Path $solutionWriteWrongCandidateRoot 'harness\docs\tasks\active\task-one'
  New-Item -ItemType Directory -Path $taskDir | Out-Null
  Set-Content -LiteralPath (Join-Path $taskDir 'task.yaml') -Value @(
    'task_id: task-one',
    'task_type: knowledge_maintenance',
    'status: active',
    'current_gate: compound_review'
  ) -Encoding UTF8
  $events = @(
    (New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'compound_review_decision' -PreviousHash '' -EventHash 'h1' -Payload @{ candidate_ref = 'cand-1'; decision = 'promote'; reason = 'repeated violation'; target_solution_path = 'harness/docs/solutions/harness-drift-patterns.md'; user_approval_event_id = 'evt-user-1' }),
    (New-Event -TaskId 'task-one' -EventId 'evt-2' -EventType 'artifact_written' -PreviousHash 'h1' -EventHash 'h2' -Payload @{ gate_id = 'compound_review'; artifact_id = 'selected_relevant_solutions'; path = 'harness/docs/solutions/harness-drift-patterns.md'; hash = 'sha256:dummy'; candidate_ref = 'cand-2' })
  )
  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
  $result = Invoke-VerifyJson -Root $solutionWriteWrongCandidateRoot
  Assert-Check ($result.ok -eq $false) 'solution write must fail when compound_review candidate_ref does not match artifact_written candidate_ref.'
}
finally {
  Remove-Item -LiteralPath $solutionWriteWrongCandidateRoot -Recurse -Force
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
