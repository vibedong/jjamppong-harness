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

$activeRoot = Join-Path $RepoRoot 'harness\docs\tasks\active'
Assert-Check (Test-Path -LiteralPath $activeRoot) 'active task root must exist.'
$activeEntries = @(Get-ChildItem -LiteralPath $activeRoot -Force)
$unexpectedActive = @($activeEntries | Where-Object { $_.Name -ne '.gitkeep' })
$unexpectedActiveNames = @($unexpectedActive | ForEach-Object { $_.Name })
Assert-Check ($unexpectedActive.Count -eq 0) "active task root must be empty except .gitkeep; found $($unexpectedActiveNames -join ', ')."

Assert-Check (-not (Test-Path -LiteralPath (Join-Path $RepoRoot 'intent-packet.md'))) 'intent-packet.md must not exist at root.'
Assert-Check (-not (Test-Path -LiteralPath (Join-Path $RepoRoot 'harness\docs\tasks\active\intent-packet.md'))) 'intent-packet.md must not exist in active tasks.'

$workflow = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\rules\workflow.md') -Raw
$rules = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\rules\rules.md') -Raw
$manifest = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\release\SOURCE-MANIFEST.md') -Raw
$notes = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\release\RELEASE-NOTES.md') -Raw

Assert-Check ($workflow.Contains('`research` is canonical. `evidence_check` is a legacy alias only.')) 'workflow.md must document evidence_check as legacy alias.'
Assert-Check ($rules.Contains('`evidence_check` is a legacy alias for `research` only.')) 'rules.md must document evidence_check as legacy alias.'
Assert-Check ($manifest.Contains('source-history') -and $manifest.Contains('audit trail only')) 'source manifest must isolate source-history as audit trail.'
Assert-Check ($manifest.Contains('OuroSuper') -and $manifest.Contains('never as an active route')) 'source manifest must remove OuroSuper active route.'
Assert-Check ($manifest.Contains('harness/contracts/artifact-registry.yaml')) 'source manifest must name artifact-registry.yaml.'
Assert-Check ($manifest.Contains('harness/contracts/skill-artifact-map.yaml')) 'source manifest must name skill-artifact-map.yaml.'
Assert-Check ($manifest.Contains('harness/lifecycle/learning-classifier.js')) 'source manifest must name the structured learning classifier.'
Assert-Check ($manifest.Contains('harness/docs/solutions/')) 'source manifest must name compound solution docs.'
Assert-Check ($notes.Contains('0.1.0 Release Candidate')) 'release notes must name the release candidate.'
Assert-Check ($notes.Contains('OuroSuper as an active workflow')) 'release notes must reject OuroSuper as active workflow.'
Assert-Check ($notes.Contains('Structured compound learning classifier')) 'release notes must mention structured compound learning classification.'
Assert-Check ($notes.Contains('Structured user correction summaries')) 'release notes must mention structured user correction summaries.'
Assert-Check ($notes.Contains('Fresh task creation does not create legacy ledger artifacts')) 'release notes must document ledgerless task creation.'
Assert-Check ($notes.Contains('compound_capture')) 'release notes must document compound_capture behavior.'

$checksumPath = Join-Path $RepoRoot 'harness\release\CHECKSUMS.sha256'
Assert-Check (Test-Path -LiteralPath $checksumPath) 'CHECKSUMS.sha256 must exist.'
if (Test-Path -LiteralPath $checksumPath) {
  $checksumText = Get-Content -LiteralPath $checksumPath -Raw
  foreach ($token in @(
    'AGENTS.md',
    'README.md',
    'harness/contracts/gate-contract-matrix.yaml',
    'harness/contracts/artifact-registry.yaml',
    'harness/contracts/skill-artifact-map.yaml',
    'harness/contracts/installer-contract.yaml',
    'harness/contracts/permission-decision.schema.yaml',
    'harness/contracts/task.schema.yaml',
    'harness/lifecycle/learning-classifier.js',
    'harness/lifecycle/lifecycle.js',
    'harness/permission/permission-decision.js',
    'harness/verify/verify.js',
    'harness/installer/install.js',
    'harness/templates/task/task.yaml',
    'harness/templates/task/learning-capture.md',
    'harness/templates/task/compound-review.md',
    'harness/docs/solutions/index.md',
    'harness/release/SOURCE-MANIFEST.md',
    'harness/release/RELEASE-NOTES.md',
    'tests/contracts/test-artifact-routing-contracts.ps1',
    'tests/contracts/test-learning-classifier.ps1',
    'tests/fixtures/contracts/required-p0-regressions.txt',
    'tests/contracts/run-all.ps1'
  )) {
    Assert-Check ($checksumText.Contains($token)) "CHECKSUMS.sha256 missing release surface: $token"
  }
  Assert-Check (-not $checksumText.Contains('harness/release/CHECKSUMS.sha256')) 'CHECKSUMS.sha256 must not hash itself.'
  Assert-Check (-not $checksumText.Contains('harness/contracts/ledger-event.schema.yaml')) 'CHECKSUMS.sha256 must not include removed ledger-event schema.'
  Assert-Check (-not $checksumText.Contains('harness/templates/task/events.jsonl.template')) 'CHECKSUMS.sha256 must not include removed events template.'
  Assert-Check (-not $checksumText.Contains('harness/templates/task/gate-ledger.md')) 'CHECKSUMS.sha256 must not include removed gate ledger template.'
  Assert-Check (-not $checksumText.Contains('harness/docs/tasks/active/2026-')) 'CHECKSUMS.sha256 must not include old active task artifacts.'
  Assert-Check (-not $checksumText.Contains('source-history/')) 'CHECKSUMS.sha256 must not include isolated source-history.'
}

if ($failures.Count -gt 0) {
  Write-Output "release candidate tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "release candidate tests passed $checks checks."
