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
    '  package: "@donghyeonlee/jjamppong-harness"',
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
