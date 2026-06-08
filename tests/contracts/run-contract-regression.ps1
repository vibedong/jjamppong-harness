param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Contract {
  param(
    [bool]$Condition,
    [string]$Message
  )

  $script:checks += 1
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

function Read-Text {
  param([string]$RelativePath)
  $path = Join-Path $RepoRoot $RelativePath
  Assert-Contract (Test-Path -LiteralPath $path) "Missing required file: $RelativePath"
  if (Test-Path -LiteralPath $path) {
    return Get-Content -LiteralPath $path -Raw
  }
  return ''
}

function Get-RegressionRecords {
  param([string]$CatalogText)

  $records = @()
  $matches = [regex]::Matches($CatalogText, '(?ms)^\s*-\s+id:\s+(?<id>T\d{3})(?<body>.*?)(?=^\s*-\s+id:\s+T\d{3}|\z)')
  foreach ($match in $matches) {
    $body = $match.Groups['body'].Value
    $priority = [regex]::Match($body, '^\s+priority:\s+(?<value>P\d)', 'Multiline').Groups['value'].Value
    $title = [regex]::Match($body, '^\s+title:\s+(?<value>.+)$', 'Multiline').Groups['value'].Value.Trim()
    $expected = [regex]::Match($body, '^\s+expected:\s+(?<value>\S+)', 'Multiline').Groups['value'].Value
    $records += [pscustomobject]@{
      Id = $match.Groups['id'].Value
      Priority = $priority
      Title = $title
      Expected = $expected
    }
  }
  return $records
}

$requiredFiles = @(
  'harness/contracts/capability-catalog.yaml',
  'harness/contracts/gate-contract-matrix.yaml',
  'harness/contracts/ledger-event.schema.yaml',
  'harness/contracts/permission-decision.schema.yaml',
  'harness/contracts/path-policy.schema.yaml',
  'harness/contracts/task.schema.yaml',
  'harness/contracts/installer-contract.yaml',
  'tests/contracts/regression-catalog.yaml',
  'tests/contracts/verify-coverage-map.yaml'
)

foreach ($file in $requiredFiles) {
  Assert-Contract (Test-Path -LiteralPath (Join-Path $RepoRoot $file)) "Missing Phase 1 contract/test file: $file"
}

$catalog = Read-Text 'tests/contracts/regression-catalog.yaml'
$coverage = Read-Text 'tests/contracts/verify-coverage-map.yaml'
$capabilities = Read-Text 'harness/contracts/capability-catalog.yaml'
$gates = Read-Text 'harness/contracts/gate-contract-matrix.yaml'
$ledgerSchema = Read-Text 'harness/contracts/ledger-event.schema.yaml'
$permissionSchema = Read-Text 'harness/contracts/permission-decision.schema.yaml'
$pathPolicy = Read-Text 'harness/contracts/path-policy.schema.yaml'
$taskSchema = Read-Text 'harness/contracts/task.schema.yaml'
$installerContract = Read-Text 'harness/contracts/installer-contract.yaml'

$records = Get-RegressionRecords $catalog
Assert-Contract ($records.Count -ge 40) "Expected at least 40 regression records, found $($records.Count)"

$duplicateIds = @($records | Group-Object Id | Where-Object { $_.Count -gt 1 })
$duplicateNames = if ($duplicateIds.Count -gt 0) { $duplicateIds.Name -join ', ' } else { '' }
Assert-Contract ($duplicateIds.Count -eq 0) "Regression ids must be unique: $duplicateNames"

$requiredP0Path = Join-Path $RepoRoot 'tests/fixtures/contracts/required-p0-regressions.txt'
Assert-Contract (Test-Path -LiteralPath $requiredP0Path) 'Missing required P0 regression fixture.'
$requiredP0 = @()
if (Test-Path -LiteralPath $requiredP0Path) {
  $requiredP0 = Get-Content -LiteralPath $requiredP0Path | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}

$ids = @($records | ForEach-Object { $_.Id })
foreach ($id in $requiredP0) {
  Assert-Contract ($ids -contains $id) "Missing required P0 regression id: $id"
}

$coveredIds = @([regex]::Matches($coverage, 'T\d{3}') | ForEach-Object { $_.Value } | Select-Object -Unique)
foreach ($id in $requiredP0) {
  Assert-Contract ($coveredIds -contains $id) "P0 regression id is not covered by verify-coverage-map.yaml: $id"
}

$p0Records = @($records | Where-Object { $_.Priority -eq 'P0' })
foreach ($record in $p0Records) {
  Assert-Contract (-not [string]::IsNullOrWhiteSpace($record.Expected)) "P0 regression $($record.Id) has no expected outcome."
  Assert-Contract ($record.Expected -match '^(allow|deny|fail|verify_fail|proposal|required|warn|require)') "P0 regression $($record.Id) expected outcome must start with allow/deny/fail/proposal/required/warn/require, got '$($record.Expected)'."
}

$requiredCapabilityTokens = @(
  'file.read.project',
  'file.read.secret',
  'file.write.module',
  'file.write.outside_modules',
  'file.write.harness_core',
  'exec.test',
  'network.web_research',
  'network.live_target',
  'package.install',
  'git.commit',
  'git.push',
  'installer.install',
  'parallel.write'
)
foreach ($token in $requiredCapabilityTokens) {
  Assert-Contract ($capabilities.Contains($token)) "Capability catalog missing token: $token"
}

$requiredGateTokens = @(
  'install:',
  'grill:',
  'research:',
  'prd:',
  'module_structure:',
  'plan_review:',
  'folder_skeleton:',
  'implementation:',
  'work:',
  'verification:',
  'archive:'
)
foreach ($token in $requiredGateTokens) {
  Assert-Contract ($gates.Contains($token)) "Gate contract matrix missing gate token: $token"
}

Assert-Contract ($ledgerSchema.Contains('canonical_log: events.jsonl')) 'Ledger schema must make events.jsonl canonical.'
Assert-Contract ($ledgerSchema.Contains('append_only: true')) 'Ledger schema must be append-only.'
Assert-Contract ($taskSchema.Contains('human_projection: gate-ledger.md')) 'task schema must define gate-ledger.md as projection.'
Assert-Contract ($taskSchema.Contains('cache_projection: task.yaml')) 'task schema must define task.yaml as cache projection.'
Assert-Contract ($permissionSchema.Contains('requested_action_fields')) 'Permission decision schema must model requested actions.'
Assert-Contract ($permissionSchema.Contains('path_policy_result')) 'Permission decision schema must include path policy result.'
Assert-Contract ($pathPolicy.Contains('detect_symlink')) 'Path policy must model symlink detection.'
Assert-Contract ($pathPolicy.Contains('detect_junction')) 'Path policy must model junction detection.'
Assert-Contract ($pathPolicy.Contains('containment:') -and $pathPolicy.Contains('project_root:')) 'Path policy must model project-root containment.'
Assert-Contract ($installerContract.Contains('install_verify_stop') -and $installerContract.Contains('start_planning')) 'Installer contract must model install-only behavior.'
Assert-Contract ($installerContract.Contains('harness.lock.yaml')) 'Installer contract must require harness.lock.yaml.'
Assert-Contract ($coverage.Contains('plan_review_not_implementation')) 'Coverage map must include plan_review_not_implementation.'
Assert-Contract ($coverage.Contains('live_access_not_web_research')) 'Coverage map must distinguish web research from live access.'
Assert-Contract ($coverage.Contains('doctor_proposal_only')) 'Coverage map must include doctor proposal-only behavior.'

if ($failures.Count -gt 0) {
  Write-Output "Contract regression skeleton failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "Contract regression skeleton passed $checks checks."
