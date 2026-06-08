param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scripts = @(
  'run-contract-regression.ps1',
  'test-permission-decision.ps1',
  'test-verify-doctor.ps1',
  'test-installer-package.ps1',
  'test-lifecycle-templates.ps1',
  'test-workflow-rules.ps1',
  'test-agents-readme.ps1',
  'test-release-candidate.ps1'
)

foreach ($script in $scripts) {
  & (Join-Path $PSScriptRoot $script) -RepoRoot $RepoRoot
  if (-not $?) {
    throw "$script failed"
  }
}

Write-Output 'All contract tests passed.'
