param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$classifier = Join-Path $RepoRoot 'harness\lifecycle\learning-classifier.js'
$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Check {
  param([bool]$Condition, [string]$Message)
  $script:checks += 1
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

function Invoke-ClassifierPayload {
  param([hashtable]$Payload)
  $jsonPayload = $Payload | ConvertTo-Json -Depth 8 -Compress
  $output = $jsonPayload | node $classifier --stdin --json
  return ($output -join "`n") | ConvertFrom-Json
}

function Invoke-Classifier {
  param([object[]]$Failures, [string]$VerificationText = '', [string]$AcceptanceText = '')
  return Invoke-ClassifierPayload -Payload @{
    failures = $Failures
    verificationText = $VerificationText
    acceptanceText = $AcceptanceText
  }
}

$gateCandidate = Invoke-Classifier -Failures @(@{ id = 'gate_required_artifact_missing'; message = 'writing_plan missing PRD' })
Assert-Check (@($gateCandidate.candidates | Where-Object { $_.category -eq 'artifact-routing' }).Count -eq 1) 'missing gate artifact should classify as artifact-routing.'

$contentCandidate = Invoke-Classifier -Failures @(@{ id = 'gate_artifact_content_insufficient'; message = 'writing_plan only has starter heading' })
Assert-Check (@($contentCandidate.candidates | Where-Object { $_.category -eq 'artifact-routing' }).Count -eq 1) 'thin gate artifact should classify as artifact-routing.'

$permissionCandidate = Invoke-Classifier -Failures @(@{ id = 'implementation_approval_missing'; message = 'implementation approval missing' })
Assert-Check (@($permissionCandidate.candidates | Where-Object { $_.category -eq 'permission-boundary' }).Count -eq 1) 'missing implementation approval should classify as permission-boundary.'

$installCandidate = Invoke-Classifier -Failures @(@{ id = 'nested_harness_folder'; message = 'nested jjamppong-harness folder' })
Assert-Check (@($installCandidate.candidates | Where-Object { $_.category -eq 'installer-flow' }).Count -eq 1) 'nested harness folder should classify as installer-flow.'

$hotContextCandidate = Invoke-Classifier -Failures @(@{ id = 'hot_context_too_large'; message = 'hot context above hard limit' })
Assert-Check (@($hotContextCandidate.candidates | Where-Object { $_.category -eq 'harness-drift' }).Count -eq 1) 'hot context hard limit should classify as harness-drift.'

$noCandidate = Invoke-Classifier -Failures @()
Assert-Check (@($noCandidate.candidates).Count -eq 0) 'no structured evidence should produce no learning candidates.'

$rawTranscriptIgnored = Invoke-ClassifierPayload -Payload @{ failures = @(); verificationText = ''; acceptanceText = ''; raw_transcript = 'agent skipped grill and then user corrected it'; conversation = 'do not mine this' }
Assert-Check (@($rawTranscriptIgnored.candidates).Count -eq 0) 'raw transcript and conversation fields must not create candidates.'

$correctionCandidate = Invoke-Classifier -Failures @() -AcceptanceText @'
# 사용자 확인

source_user_correction: grill me 먼저 해야지
source_user_correction_category: gate-order
source_user_correction_prevention: Run grill before docs lookup.
'@
Assert-Check (@($correctionCandidate.candidates | Where-Object { $_.category -eq 'gate-order' -and $_.candidate_ref }).Count -eq 1) 'structured user correction in acceptance text should become a candidate with candidate_ref.'

if (Test-Path -LiteralPath $classifier) {
  $text = Get-Content -LiteralPath $classifier -Raw
  Assert-Check (-not $text.Contains('artifact_read_receipt_missing')) 'classifier must not depend on artifact_read receipt failure ids.'
  Assert-Check (-not $text.Contains('artifact_required_write_missing')) 'classifier must not depend on artifact_written failure ids.'
  Assert-Check (-not $text.Contains('projection_without_canonical_event')) 'classifier must not depend on event-log projection failure ids.'
  Assert-Check (-not $text.Contains('input.events')) 'classifier must not read event arrays.'
  Assert-Check (-not $text.Contains('raw transcript')) 'classifier must not depend on raw transcript text.'
  Assert-Check (-not $text.Contains('conversation')) 'classifier must not parse whole conversation text.'
}

if ($failures.Count -gt 0) {
  Write-Output "learning classifier tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "learning classifier tests passed $checks checks."
