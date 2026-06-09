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

$artifactRegistryPath = Join-Path $RepoRoot 'harness\contracts\artifact-registry.yaml'
$skillMapPath = Join-Path $RepoRoot 'harness\contracts\skill-artifact-map.yaml'
$learningTemplatePath = Join-Path $RepoRoot 'harness\templates\task\learning-capture.md'
$compoundReviewTemplatePath = Join-Path $RepoRoot 'harness\templates\task\compound-review.md'
$solutionsIndexPath = Join-Path $RepoRoot 'harness\docs\solutions\index.md'
$workflowPath = Join-Path $RepoRoot 'harness\rules\workflow.md'
$rulesPath = Join-Path $RepoRoot 'harness\rules\rules.md'
$catalogPath = Join-Path $RepoRoot 'tests\contracts\regression-catalog.yaml'
$coveragePath = Join-Path $RepoRoot 'tests\contracts\verify-coverage-map.yaml'
$gateMatrixPath = Join-Path $RepoRoot 'harness\contracts\gate-contract-matrix.yaml'

foreach ($path in @(
  $artifactRegistryPath,
  $skillMapPath,
  $learningTemplatePath,
  $compoundReviewTemplatePath,
  $solutionsIndexPath
)) {
  Assert-Check (Test-Path -LiteralPath $path) "Missing required artifact routing surface: $path"
}

if (Test-Path -LiteralPath $artifactRegistryPath) {
  $registry = Get-Content -LiteralPath $artifactRegistryPath -Raw
  foreach ($token in @(
    'planning_prd:',
    'planning_issues:',
    'planning_module_structure:',
    'planning_writing_plan:',
    'learning_capture:',
    'compound_review:',
    'compound_state:',
    'solutions_index:',
    'audience: human',
    'language: user',
    'canonical: true',
    'read_receipt_required: true'
  )) {
    Assert-Check ($registry.Contains($token)) "artifact-registry.yaml missing token: $token"
  }
}

if (Test-Path -LiteralPath $skillMapPath) {
  $skillMap = Get-Content -LiteralPath $skillMapPath -Raw
  foreach ($token in @(
    'writing_plan:',
    'planning_current_context',
    'planning_prd',
    'planning_issues',
    'planning_module_structure',
    'compound_lookup:',
    'compound_state',
    'solutions_index',
    'compound_capture:',
    'learning_capture',
    'compound_review:'
  )) {
    Assert-Check ($skillMap.Contains($token)) "skill-artifact-map.yaml missing token: $token"
  }
}

foreach ($solutionFile in @(
  'harness\docs\solutions\harness-drift-patterns.md',
  'harness\docs\solutions\installer-flow-patterns.md',
  'harness\docs\solutions\planning-gate-patterns.md',
  'harness\docs\solutions\permission-boundary-patterns.md'
)) {
  Assert-Check (Test-Path -LiteralPath (Join-Path $RepoRoot $solutionFile)) "Missing solution category file: $solutionFile"
}

if (Test-Path -LiteralPath $workflowPath) {
  $workflow = Get-Content -LiteralPath $workflowPath -Raw
  foreach ($token in @(
    'Artifact Routing',
    'Read receipts',
    'compound_lookup reads solution indexes before detailed solution files',
    'compound_capture records candidates',
    'compound_review decides long-term promotion'
  )) {
    Assert-Check ($workflow.Contains($token)) "workflow.md missing artifact routing token: $token"
  }
}

if (Test-Path -LiteralPath $rulesPath) {
  $rules = Get-Content -LiteralPath $rulesPath -Raw
  foreach ($token in @(
    'Before a gate or skill starts, check harness/contracts/skill-artifact-map.yaml',
    'Do not rely on memory for required artifacts',
    'Record artifact_read events for required artifact reads',
    'Do not promote learning candidates into harness/docs/solutions without compound_review'
  )) {
    Assert-Check ($rules.Contains($token)) "rules.md missing artifact routing token: $token"
  }
}

$catalog = Get-Content -LiteralPath $catalogPath -Raw
foreach ($token in @('T041', 'T042', 'T043', 'T044')) {
  Assert-Check ($catalog.Contains($token)) "regression catalog missing $token"
}

$coverage = Get-Content -LiteralPath $coveragePath -Raw
foreach ($token in @(
  'artifact_routing_contract',
  'artifact_read_receipts',
  'compound_review_promotion_gate'
)) {
  Assert-Check ($coverage.Contains($token)) "verify coverage map missing token: $token"
}

if ((Test-Path -LiteralPath $artifactRegistryPath) -and (Test-Path -LiteralPath $skillMapPath) -and (Test-Path -LiteralPath $gateMatrixPath)) {
  $registry = Get-Content -LiteralPath $artifactRegistryPath -Raw
  $skillMap = Get-Content -LiteralPath $skillMapPath -Raw
  $gateMatrix = Get-Content -LiteralPath $gateMatrixPath -Raw

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

  foreach ($forbiddenToken in @('file.write.module', 'git.push', 'network.live_target', 'package.install')) {
    Assert-Check (-not $skillMap.Contains($forbiddenToken)) "skill-artifact-map must not grant capability: $forbiddenToken"
  }
}

if ($failures.Count -gt 0) {
  Write-Output "artifact routing contract tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "artifact routing contract tests passed $checks checks."
