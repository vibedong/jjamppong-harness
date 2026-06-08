param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
  throw 'Node.js is required to run PermissionDecision MVP tests.'
}

$engine = Join-Path $RepoRoot 'harness\permission\permission-decision.js'
if (-not (Test-Path -LiteralPath $engine)) {
  throw "PermissionDecision engine not found: $engine"
}

$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function New-TestTask {
  param(
    [string]$TaskType,
    [array]$Events
  )

  $dir = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-perm-test-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $dir | Out-Null
  Set-Content -LiteralPath (Join-Path $dir 'task.yaml') -Value @("task_id: test-task", "task_type: $TaskType") -Encoding UTF8
  $jsonl = foreach ($event in $Events) {
    $event | ConvertTo-Json -Depth 20 -Compress
  }
  Set-Content -LiteralPath (Join-Path $dir 'events.jsonl') -Value $jsonl -Encoding UTF8
  return $dir
}

function New-ApprovalEvent {
  param(
    [string]$EventId,
    [string]$Capability,
    [string[]]$AllowedPaths = @()
  )

  return [ordered]@{
    event_id = $EventId
    schema_version = '0.1.0'
    task_id = 'test-task'
    event_type = 'approval_decision'
    created_at = '2026-06-08T00:00:00+09:00'
    actor_type = 'verifier'
    previous_hash = 'prev'
    event_hash = $EventId
    payload = [ordered]@{
      gate_id = 'implementation'
      status = 'approved'
      capabilities = @($Capability)
      effects = [ordered]@{ $Capability = $true }
      target_paths = [ordered]@{ allowed = @($AllowedPaths) }
      invalidates_on = @('target_path_changed')
    }
  }
}

function New-GateStatusEvent {
  param(
    [string]$GateId,
    [string]$Status
  )

  return [ordered]@{
    event_id = "evt-$GateId-$Status"
    schema_version = '0.1.0'
    task_id = 'test-task'
    event_type = 'gate_status_change'
    created_at = '2026-06-08T00:00:00+09:00'
    actor_type = 'verifier'
    previous_hash = 'prev'
    event_hash = "hash-$GateId-$Status"
    payload = [ordered]@{
      gate_id = $GateId
      status = $Status
    }
  }
}

function New-InvalidationEvent {
  param([string]$ApprovalEventId)

  return [ordered]@{
    event_id = "invalidates-$ApprovalEventId"
    schema_version = '0.1.0'
    task_id = 'test-task'
    event_type = 'invalidation'
    created_at = '2026-06-08T00:00:00+09:00'
    actor_type = 'verifier'
    previous_hash = 'prev'
    event_hash = "hash-invalidates-$ApprovalEventId"
    payload = [ordered]@{
      approval_event_id = $ApprovalEventId
      reason = 'writing_plan_hash_changed'
    }
  }
}

function Invoke-PermissionDecision {
  param(
    [string]$TaskType,
    [array]$Events,
    [string]$Capability,
    [string]$Path = '',
    [string]$Action = 'file_write'
  )

  $taskDir = New-TestTask -TaskType $TaskType -Events $Events
  try {
    $args = @(
      $engine,
      '--repo-root', $RepoRoot,
      '--events', (Join-Path $taskDir 'events.jsonl'),
      '--task-yaml', (Join-Path $taskDir 'task.yaml'),
      '--capability', $Capability,
      '--action', $Action
    )
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
      $args += @('--path', $Path)
    }
    $output = & node @args
    $json = ($output -join "`n") | ConvertFrom-Json
    return $json
  }
  finally {
    Remove-Item -LiteralPath $taskDir -Recurse -Force
  }
}

function Assert-Decision {
  param(
    [string]$Name,
    [string]$Expected,
    [object]$Actual
  )

  $script:checks += 1
  if ($Actual.decision -ne $Expected) {
    $script:failures.Add("$Name expected '$Expected' but got '$($Actual.decision)': $($Actual.reason)")
  }
}

$moduleApproval = New-ApprovalEvent -EventId 'approval-module-src' -Capability 'file.write.module' -AllowedPaths @('modules/g2b/src/**')
$folderApproval = New-ApprovalEvent -EventId 'approval-folder' -Capability 'file.write.folder_skeleton' -AllowedPaths @('modules/g2b/**')
$outsideApproval = New-ApprovalEvent -EventId 'approval-package-json' -Capability 'file.write.outside_modules' -AllowedPaths @('package.json')
$liveApproval = New-ApprovalEvent -EventId 'approval-live' -Capability 'network.live_target'

Assert-Decision 'plan_review alone does not unlock module write' 'deny' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @((New-GateStatusEvent -GateId 'plan_review' -Status 'completed')) -Capability 'file.write.module' -Path 'modules/g2b/src/parser.js'
)

Assert-Decision 'exact module approval allows approved module path' 'allow' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @($moduleApproval) -Capability 'file.write.module' -Path 'modules/g2b/src/parser.js'
)

Assert-Decision 'module approval does not allow unapproved tests path' 'deny' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @($moduleApproval) -Capability 'file.write.module' -Path 'modules/g2b/tests/parser.test.js'
)

Assert-Decision 'folder skeleton approval allows placeholder markdown' 'allow' (
  Invoke-PermissionDecision -TaskType 'module_bootstrap' -Events @($folderApproval) -Capability 'file.write.folder_skeleton' -Path 'modules/g2b/README.md'
)

Assert-Decision 'folder skeleton cannot create executable files' 'deny' (
  Invoke-PermissionDecision -TaskType 'module_bootstrap' -Events @($folderApproval) -Capability 'file.write.folder_skeleton' -Path 'modules/g2b/index.js'
)

Assert-Decision 'live target denied without approval' 'deny' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @() -Capability 'network.live_target' -Action 'network_access'
)

Assert-Decision 'live target approval allows live capability' 'allow' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @($liveApproval) -Capability 'network.live_target' -Action 'network_access'
)

Assert-Decision 'web research allowed only during research gate' 'allow' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @((New-GateStatusEvent -GateId 'research' -Status 'open')) -Capability 'network.web_research' -Action 'network_access'
)

Assert-Decision 'project read denied before research gate' 'deny' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @() -Capability 'file.read.project' -Path 'README.md' -Action 'file_read'
)

Assert-Decision 'project read allowed during research gate' 'allow' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @((New-GateStatusEvent -GateId 'research' -Status 'open')) -Capability 'file.read.project' -Path 'README.md' -Action 'file_read'
)

Assert-Decision 'package install denied without approval' 'deny' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @() -Capability 'package.install' -Action 'package_install'
)

Assert-Decision 'git commit denied without approval' 'deny' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @() -Capability 'git.commit' -Action 'git_operation'
)

Assert-Decision 'git push denied without approval' 'deny' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @() -Capability 'git.push' -Action 'git_operation'
)

Assert-Decision 'secret read denied' 'deny' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @() -Capability 'file.read.secret' -Path '.env' -Action 'file_read'
)

Assert-Decision 'outside modules write denied without approval' 'deny' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @() -Capability 'file.write.outside_modules' -Path 'package.json'
)

Assert-Decision 'outside modules write requires exact approval' 'allow' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @($outsideApproval) -Capability 'file.write.outside_modules' -Path 'package.json'
)

Assert-Decision 'harness core write in product task requires proposal' 'proposal_required' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @() -Capability 'file.write.harness_core' -Path 'harness/rules/workflow.md'
)

Assert-Decision 'approval invalidation denies previous approval' 'deny' (
  Invoke-PermissionDecision -TaskType 'product_feature' -Events @($moduleApproval, (New-InvalidationEvent -ApprovalEventId 'approval-module-src')) -Capability 'file.write.module' -Path 'modules/g2b/src/parser.js'
)

if ($failures.Count -gt 0) {
  Write-Output "PermissionDecision MVP failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "PermissionDecision MVP passed $checks checks."
