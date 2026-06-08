param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$cli = Join-Path $RepoRoot 'bin\jjamppong.js'
$wrapper = Join-Path $RepoRoot 'scripts\install-jjamppong-harness.ps1'
$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Check {
  param([bool]$Condition, [string]$Message)
  $script:checks += 1
  if (-not $Condition) {
    $script:failures.Add($Message)
  }
}

function Invoke-JsonCommand {
  param([string[]]$CommandArgs)
  $output = & node @CommandArgs
  $jsonText = $output -join "`n"
  $jsonObject = $jsonText | ConvertFrom-Json
  if ($jsonObject -is [array]) {
    return $jsonObject[0]
  }
  return $jsonObject
}

function Select-ResultObject {
  param([object]$Value)
  $items = @($Value)
  foreach ($item in $items) {
    if ($null -ne $item -and $item.PSObject.Properties.Name -contains 'ok') {
      return $item
    }
  }
  return $Value
}

function New-TargetRoot {
  $root = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-install-test-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $root | Out-Null
  return $root
}

function Assert-InstalledRoot {
  param([string]$Target)

  foreach ($item in @('AGENTS.md', 'README.md', 'CONTEXT.md', 'handoff.md', 'harness', 'modules', 'module-template', 'proposals', 'harness.lock.yaml')) {
    Assert-Check (Test-Path -LiteralPath (Join-Path $Target $item)) "Installed root missing $item"
  }
  Assert-Check (-not (Test-Path -LiteralPath (Join-Path $Target 'jjamppong-harness\AGENTS.md'))) 'Install must not leave nested jjamppong-harness folder.'
  Assert-Check (-not (Test-Path -LiteralPath (Join-Path $Target 'ourosuper-harness\AGENTS.md'))) 'Install must not leave nested ourosuper-harness folder.'
  $activeDirs = @(Get-ChildItem -LiteralPath (Join-Path $Target 'harness\docs\tasks\active') -Directory -ErrorAction SilentlyContinue)
  Assert-Check ($activeDirs.Count -eq 0) 'Install must not create active product tasks.'
  $lock = Get-Content -LiteralPath (Join-Path $Target 'harness.lock.yaml') -Raw
  foreach ($line in @('planning_started: false', 'github_repo_created: false', 'commit_created: false', 'push_performed: false', 'managed_files:')) {
    Assert-Check ($lock.Contains($line)) "harness.lock.yaml missing install-only receipt line: $line"
  }
}

Assert-Check (Test-Path -LiteralPath (Join-Path $RepoRoot 'package.json')) 'package.json must exist for npm/npx CLI.'
Assert-Check (Test-Path -LiteralPath $cli) 'bin/jjamppong.js must exist.'
Assert-Check (Test-Path -LiteralPath $wrapper) 'PowerShell wrapper must exist.'

$help = & node $cli --help
Assert-Check (($help -join "`n").Contains('jjamppong install --target')) 'CLI help must expose install command.'

$target = New-TargetRoot
try {
  $result = Select-ResultObject (Invoke-JsonCommand -CommandArgs @($cli, 'install', '--target', $target, '--template', $RepoRoot))
  Assert-Check ($result.ok -eq $true) "CLI install should verify successfully: $($result | ConvertTo-Json -Depth 8 -Compress)"
  Assert-Check ($result.stopped_after_install -eq $true) 'CLI install must stop after install.'
  Assert-Check ($result.planning_started -eq $false) 'CLI install must not start planning.'
  Assert-Check ($result.github_repo_created -eq $false) 'CLI install must not create GitHub repo.'
  Assert-Check ($result.commit_created -eq $false) 'CLI install must not commit.'
  Assert-Check ($result.push_performed -eq $false) 'CLI install must not push.'
  Assert-InstalledRoot -Target $target

  $verify = Select-ResultObject (Invoke-JsonCommand -CommandArgs @($cli, 'verify', '--target', $target, '--json'))
  Assert-Check ($verify.ok -eq $true) "CLI verify should pass installed root: $($verify | ConvertTo-Json -Depth 8 -Compress)"

  $second = Select-ResultObject (Invoke-JsonCommand -CommandArgs @($cli, 'install', '--target', $target, '--template', $RepoRoot))
  Assert-Check ($second.ok -eq $true) 'Second install should remain idempotent enough to verify.'
  Assert-InstalledRoot -Target $target
}
finally {
  Remove-Item -LiteralPath $target -Recurse -Force
}

$wrapperTarget = New-TargetRoot
try {
  $wrapperOutput = & powershell -NoProfile -ExecutionPolicy Bypass -File $wrapper $RepoRoot $wrapperTarget -SkipGitHubRepo
  $joined = $wrapperOutput -join "`n"
  Assert-Check ($joined.Contains('Installing Jjamppong Harness')) 'PowerShell wrapper should call install-only path.'
  Assert-InstalledRoot -Target $wrapperTarget
}
finally {
  Remove-Item -LiteralPath $wrapperTarget -Recurse -Force
}

if ($failures.Count -gt 0) {
  Write-Output "installer/package tests failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "installer/package tests passed $checks checks."
