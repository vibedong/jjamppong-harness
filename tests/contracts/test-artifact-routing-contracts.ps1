param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Check {
  param([bool]$Condition, [string]$Message)
  $script:checks += 1
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

function Read-RequiredText {
  param([string]$RelativePath)
  $path = Join-Path $RepoRoot $RelativePath
  Assert-Check (Test-Path -LiteralPath $path) "Missing required artifact routing surface: $RelativePath"
  if (Test-Path -LiteralPath $path) {
    return Get-Content -LiteralPath $path -Raw
  }
  return ''
}

function Get-YamlTopLevelKeys {
  param([string]$Text, [string]$Parent)
  $lines = $Text -split "`r?`n"
  $inside = $false
  $keys = New-Object System.Collections.Generic.HashSet[string]
  foreach ($line in $lines) {
    if ($line -match "^$Parent`:") {
      $inside = $true
      continue
    }
    if ($inside -and $line -match '^[a-zA-Z0-9_-]+:') {
      break
    }
    if ($inside -and $line -match '^  ([a-zA-Z0-9_-]+):') {
      [void]$keys.Add($Matches[1])
    }
  }
  return $keys
}

$registry = Read-RequiredText 'harness/contracts/artifact-registry.yaml'
$skillMap = Read-RequiredText 'harness/contracts/skill-artifact-map.yaml'
$gateMatrix = Read-RequiredText 'harness/contracts/gate-contract-matrix.yaml'
$workflow = Read-RequiredText 'harness/rules/workflow.md'
$rules = Read-RequiredText 'harness/rules/rules.md'
$coverage = Read-RequiredText 'tests/contracts/verify-coverage-map.yaml'
$catalog = Read-RequiredText 'tests/contracts/regression-catalog.yaml'

foreach ($artifactId in @('events_log:', 'active_task_events:', 'gate_ledger:')) {
  Assert-Check (-not $registry.Contains($artifactId)) "artifact-registry.yaml must not define legacy ledger artifact id: $artifactId"
  Assert-Check (-not $skillMap.Contains($artifactId.TrimEnd(':'))) "skill-artifact-map.yaml must not reference legacy ledger artifact id: $artifactId"
}

foreach ($token in @(
  'planning_prd:',
  'planning_issues:',
  'planning_module_structure:',
  'planning_writing_plan:',
  'implementation_approval:',
  'learning_capture:',
  'compound_review:',
  'compound_state:',
  'solutions_index:',
  'audience: human',
  'language: user'
)) {
  Assert-Check ($registry.Contains($token)) "artifact-registry.yaml missing ledgerless token: $token"
}

foreach ($forbidden in @(
  'read_receipt_required: true',
  'artifact_read',
  'artifact_written',
  'events.jsonl',
  'gate-ledger.md'
)) {
  Assert-Check (-not $registry.Contains($forbidden)) "artifact-registry.yaml must not require ledger behavior: $forbidden"
  Assert-Check (-not $skillMap.Contains($forbidden)) "skill-artifact-map.yaml must not require ledger behavior: $forbidden"
}

foreach ($token in @(
  'writing_plan:',
  'planning_current_context',
  'planning_prd',
  'planning_issues',
  'planning_module_structure',
  'implementation:',
  'implementation_approval',
  'task_yaml',
  'compound_lookup:',
  'compound_state',
  'solutions_index',
  'compound_capture:',
  'learning_capture',
  'compound_review:'
)) {
  Assert-Check ($skillMap.Contains($token)) "skill-artifact-map.yaml missing ledgerless token: $token"
}

foreach ($token in @(
  'Artifact Routing',
  'current gate artifact',
  'Do not rely on memory for required artifacts',
  'Do not promote learning candidates into harness/docs/solutions without compound_review'
)) {
  Assert-Check (($workflow.Contains($token) -or $rules.Contains($token))) "rules/workflow missing artifact routing token: $token"
}

foreach ($forbidden in @(
  'Record artifact_read events for required artifact reads',
  'artifact_read_receipts',
  'canonical event',
  'canonical log',
  'events.jsonl is the source'
)) {
  Assert-Check (-not $workflow.Contains($forbidden)) "workflow.md must not contain ledger authority wording: $forbidden"
  Assert-Check (-not $rules.Contains($forbidden)) "rules.md must not contain ledger authority wording: $forbidden"
}

foreach ($token in @('T041', 'T042', 'T043', 'T044')) {
  Assert-Check ($catalog.Contains($token)) "regression catalog missing $token"
}

foreach ($token in @(
  'artifact_routing_contract',
  'compound_review_promotion_gate'
)) {
  Assert-Check ($coverage.Contains($token)) "verify coverage map missing token: $token"
}
Assert-Check (-not $coverage.Contains('artifact_read_receipts')) 'verify coverage map must not require artifact_read_receipts.'

$artifactIds = Get-YamlTopLevelKeys -Text $registry -Parent 'artifacts'
$gateIds = Get-YamlTopLevelKeys -Text $skillMap -Parent 'gates'
$matrixGateIds = Get-YamlTopLevelKeys -Text $gateMatrix -Parent 'gates'

foreach ($gateId in $gateIds) {
  Assert-Check ($matrixGateIds.Contains($gateId)) "skill-artifact-map gate is missing from gate-contract-matrix: $gateId"
}
foreach ($gateId in $matrixGateIds) {
  Assert-Check ($gateIds.Contains($gateId)) "gate-contract-matrix gate is missing from skill-artifact-map: $gateId"
}

$artifactRefs = [regex]::Matches($skillMap, '^\s{6}-\s+([a-zA-Z0-9_-]+)\s*$', 'Multiline') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
foreach ($artifactRef in $artifactRefs) {
  Assert-Check ($artifactIds.Contains($artifactRef)) "skill-artifact-map references unknown artifact id: $artifactRef"
}

foreach ($forbiddenCapability in @('file.write.module', 'git.push', 'network.live_target', 'package.install')) {
  Assert-Check (-not $skillMap.Contains($forbiddenCapability)) "skill-artifact-map must not grant capability: $forbiddenCapability"
}

if ($failures.Count -gt 0) {
  Write-Output "artifact routing contract tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "artifact routing contract tests passed $checks checks."
