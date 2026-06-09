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
  param([object[]]$Events, [object[]]$Failures)
  return Invoke-ClassifierPayload -Payload @{ events = $Events; failures = $Failures }
}

$gateCandidate = Invoke-Classifier -Events @() -Failures @(@{ id = 'artifact_forbidden_read'; message = 'grill read project source too early' })
Assert-Check (@($gateCandidate.candidates | Where-Object { $_.category -eq 'gate-order' }).Count -eq 1) 'forbidden early read should classify as gate-order.'

$permissionCandidate = Invoke-Classifier -Events @() -Failures @(@{ id = 'projection_without_canonical_event'; message = 'permission-like projection without approval' })
Assert-Check (@($permissionCandidate.candidates | Where-Object { $_.category -eq 'permission-boundary' }).Count -eq 1) 'permission projection drift should classify as permission-boundary.'

$installCandidate = Invoke-Classifier -Events @() -Failures @(@{ id = 'nested_harness_folder'; message = 'nested jjamppong-harness folder' })
Assert-Check (@($installCandidate.candidates | Where-Object { $_.category -eq 'installer-flow' }).Count -eq 1) 'nested harness folder should classify as installer-flow.'

$noCandidate = Invoke-Classifier -Events @() -Failures @()
Assert-Check (@($noCandidate.candidates).Count -eq 0) 'no structured evidence should produce no learning candidates.'

$rawTranscriptIgnored = Invoke-ClassifierPayload -Payload @{ events = @(); failures = @(); raw_transcript = 'agent skipped grill and then user corrected it'; conversation = 'do not mine this' }
Assert-Check (@($rawTranscriptIgnored.candidates).Count -eq 0) 'raw transcript and conversation fields must not create candidates.'

$correctionCandidate = Invoke-Classifier -Events @(@{ event_id = 'evt-user-correction-1'; event_type = 'user_correction'; payload = @{ category = 'gate-order'; summary = 'Grill happened after docs lookup.'; correction_quote = 'grill me 먼저 해야지'; recurrence_prevention = 'Run grill before docs lookup.'; source_event_id = 'evt-source-1' } }) -Failures @()
Assert-Check (@($correctionCandidate.candidates | Where-Object { $_.category -eq 'gate-order' -and $_.candidate_ref }).Count -eq 1) 'canonical user_correction event should become a candidate with candidate_ref.'

if (Test-Path -LiteralPath $classifier) {
  $text = Get-Content -LiteralPath $classifier -Raw
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
