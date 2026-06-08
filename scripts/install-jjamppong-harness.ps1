param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$TemplateSource,

  [Parameter(Mandatory = $true, Position = 1)]
  [string]$TargetPath,

  [string]$ProjectRepo,
  [string]$Owner,
  [switch]$AllowOverwrite,
  [switch]$SkipGitHubRepo
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Normalize-TargetPath {
  param([string]$PathText)

  $text = $PathText.Trim()
  if ($text -match '^[A-Za-z]:[^\\/].+') {
    $text = $text.Substring(0, 2) + [IO.Path]::DirectorySeparatorChar + $text.Substring(2)
  }
  return [IO.Path]::GetFullPath($text)
}

$target = Normalize-TargetPath $TargetPath
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$templateRoot = (Resolve-Path -LiteralPath (Join-Path $scriptRoot '..')).Path

if ($TemplateSource -and (Test-Path -LiteralPath $TemplateSource)) {
  $templateRoot = (Resolve-Path -LiteralPath $TemplateSource).Path
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  throw 'Node.js is required for the Jjamppong Harness installer.'
}

if (-not $SkipGitHubRepo) {
  Write-Output 'GitHub repo creation is disabled by default. This wrapper will not create remotes, commits, or pushes.'
}

if ($ProjectRepo) {
  Write-Output "ProjectRepo argument was received but not applied by install-only wrapper: $ProjectRepo"
}
if ($Owner) {
  Write-Output "Owner argument was received but not used because GitHub repo creation is disabled: $Owner"
}
if ($AllowOverwrite) {
  Write-Output 'Existing managed files are backed up before overwrite; install still stops after verification.'
}

$cli = Join-Path $templateRoot 'bin\jjamppong.js'
if (-not (Test-Path -LiteralPath $cli)) {
  throw "Jjamppong CLI not found at $cli"
}

Write-Output "Installing Jjamppong Harness into $target"
& node $cli install --target $target --template $templateRoot
if ($LASTEXITCODE -ne 0) {
  throw "Jjamppong Harness install failed with exit code $LASTEXITCODE"
}
