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

function Normalize-TemplateSource {
  param([string]$Source)

  $text = $Source.Trim()
  if (Test-Path -LiteralPath $text) {
    return (Resolve-Path -LiteralPath $text).Path
  }
  if ($text -match '^[^/:\\]+/[^/:\\]+(\.git)?$') {
    $repo = $text
    if (-not $repo.EndsWith('.git')) {
      $repo += '.git'
    }
    return "https://github.com/$repo"
  }
  return $text
}

function Get-GitHubRepoId {
  param([string]$Value)

  $text = $Value.Trim()
  if ($text -match 'github\.com[:/](?<owner>[^/]+)/(?<repo>[^/.]+)(?:\.git)?/?$') {
    return "$($matches.owner)/$($matches.repo)"
  }
  if ($text -match '^(?<owner>[^/:\\]+)/(?!/)(?<repo>[^/:\\]+?)(?:\.git)?$') {
    return "$($matches.owner)/$($matches.repo)"
  }
  return $null
}

function Get-RepoKey {
  param([string]$Value)

  $repoId = Get-GitHubRepoId $Value
  if ($repoId) {
    return $repoId.ToLowerInvariant()
  }
  return $Value.Trim().TrimEnd('/').ToLowerInvariant()
}

function Test-SameRepo {
  param([string]$A, [string]$B)

  return (Get-RepoKey $A) -eq (Get-RepoKey $B)
}

function Get-ExistingOrigin {
  param([string]$Target)

  if (-not (Test-Path -LiteralPath $Target)) {
    return $null
  }

  $oldErrorAction = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    $origin = git -C $Target remote get-url origin 2>$null
    $originExit = $LASTEXITCODE
  }
  finally {
    $ErrorActionPreference = $oldErrorAction
  }

  if ($originExit -eq 0 -and -not [string]::IsNullOrWhiteSpace($origin)) {
    return $origin.Trim()
  }

  return $null
}

function Test-TemplateSourceOrigin {
  param(
    [string]$Origin,
    [string]$Template
  )

  if (Test-SameRepo $Origin $Template) {
    return $true
  }

  if (Test-Path -LiteralPath $Template) {
    $templateOrigin = Get-ExistingOrigin -Target $Template
    if ($templateOrigin -and (Test-SameRepo $Origin $templateOrigin)) {
      return $true
    }
  }

  return $false
}

function Get-ProjectRepoUrl {
  param(
    [string]$Template,
    [string]$Target,
    [string]$ExplicitRepo,
    [string]$ExplicitOwner
  )

  if (-not [string]::IsNullOrWhiteSpace($ExplicitRepo)) {
    $repo = $ExplicitRepo.Trim()
    if ($repo -match '^[^/:\\]+/[^/:\\]+(\.git)?$') {
      if (-not $repo.EndsWith('.git')) {
        $repo += '.git'
      }
      return "https://github.com/$repo"
    }
    return $repo
  }

  $projectSlug = Split-Path -Leaf $Target.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
  if ([string]::IsNullOrWhiteSpace($projectSlug)) {
    throw 'Could not derive project slug from target path.'
  }

  $ownerName = $ExplicitOwner
  if ([string]::IsNullOrWhiteSpace($ownerName)) {
    $repoId = Get-GitHubRepoId $Template
    if ($repoId) {
      $ownerName = $repoId.Split('/')[0]
    }
  }
  if ([string]::IsNullOrWhiteSpace($ownerName)) {
    throw 'Could not derive GitHub owner. Pass -Owner or -ProjectRepo.'
  }

  return "https://github.com/$ownerName/$projectSlug.git"
}

function Ensure-GitHubRepo {
  param(
    [string]$RepoUrl,
    [switch]$Skip
  )

  if ($Skip) {
    return
  }

  $repoId = Get-GitHubRepoId $RepoUrl
  if (-not $repoId) {
    Write-Output "Skipping GitHub repo check for non-GitHub origin: $RepoUrl"
    return
  }
  if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Output "GitHub CLI not found; leaving origin as $RepoUrl without creating remote repo."
    return
  }

  $oldErrorAction = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    gh repo view $repoId *> $null
    $viewExit = $LASTEXITCODE
  }
  finally {
    $ErrorActionPreference = $oldErrorAction
  }

  if ($viewExit -eq 0) {
    Write-Output "Verified GitHub project repo: $repoId"
    return
  }

  gh repo create $repoId --private
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to create GitHub project repo: $repoId"
  }
  Write-Output "Created GitHub project repo: $repoId"
}

function Get-GitTopLevel {
  param([string]$Target)

  $oldErrorAction = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    $top = git -C $Target rev-parse --show-toplevel 2>$null
    $gitExit = $LASTEXITCODE
  }
  finally {
    $ErrorActionPreference = $oldErrorAction
  }

  if ($gitExit -ne 0 -or [string]::IsNullOrWhiteSpace($top)) {
    return $null
  }
  return [IO.Path]::GetFullPath($top.Trim())
}

function Set-ProjectOrigin {
  param(
    [string]$Target,
    [string]$Template,
    [string]$Project
  )

  $gitTop = Get-GitTopLevel $Target
  if ($gitTop) {
    if ($gitTop -ne $Target) {
      throw "Target is inside another git repository. Open or install at the project root: $gitTop"
    }
  }
  else {
    git -C $Target init | Out-Null
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to initialize git repository at $Target"
    }
  }

  $oldErrorAction = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    $origin = git -C $Target remote get-url origin 2>$null
    $originExit = $LASTEXITCODE
  }
  finally {
    $ErrorActionPreference = $oldErrorAction
  }

  if ($originExit -ne 0 -or [string]::IsNullOrWhiteSpace($origin)) {
    git -C $Target remote add origin $Project
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to add project origin: $Project"
    }
    Write-Output "Added project origin: $Project"
    return
  }

  if (Test-TemplateSourceOrigin -Origin $origin -Template $Template) {
    git -C $Target remote set-url origin $Project
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to replace template origin with project origin."
    }
    Write-Output "Replaced template origin with project origin: $Project"
    return
  }

  Write-Output "Preserved existing project origin: $origin"
}

function Copy-TemplateRoot {
  param(
    [string]$Source,
    [string]$Target,
    [switch]$Overwrite
  )

  $collisions = @()
  $items = @(Get-ChildItem -LiteralPath $Source -Force | Where-Object { $_.Name -ne '.git' })

  foreach ($item in $items) {
    $destination = Join-Path $Target $item.Name
    if (Test-Path -LiteralPath $destination) {
      $collisions += $destination
    }
  }

  if ($collisions -and -not $Overwrite) {
    $collisions | ForEach-Object { Write-Output "Collision: $_" }
    throw 'Destination collisions found. Re-run with -AllowOverwrite only after approving those paths.'
  }

  foreach ($item in $items) {
    Copy-Item -LiteralPath $item.FullName -Destination $Target -Recurse -Force
  }
}

function Clear-InstalledTaskArtifacts {
  param([string]$Target)

  $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
  foreach ($relativePath in @('harness/docs/tasks/active', 'harness/docs/tasks/archive')) {
    $taskDir = Join-Path $resolvedTarget $relativePath
    if (-not (Test-Path -LiteralPath $taskDir)) {
      New-Item -ItemType Directory -Path $taskDir -Force | Out-Null
      continue
    }

    $resolvedTaskDir = (Resolve-Path -LiteralPath $taskDir).Path
    $expectedPrefix = $resolvedTarget + [IO.Path]::DirectorySeparatorChar
    if (-not $resolvedTaskDir.StartsWith($expectedPrefix, [StringComparison]::OrdinalIgnoreCase)) {
      throw "Refusing to clean task artifacts outside target root: $resolvedTaskDir"
    }

    Get-ChildItem -LiteralPath $resolvedTaskDir -Force | Remove-Item -Recurse -Force
  }
}

function Backup-TargetTaskArtifacts {
  param(
    [string]$Target,
    [string]$BackupRoot
  )

  $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
  foreach ($relativePath in @('harness/docs/tasks/active', 'harness/docs/tasks/archive')) {
    $taskDir = Join-Path $resolvedTarget $relativePath
    if (-not (Test-Path -LiteralPath $taskDir)) {
      continue
    }

    $resolvedTaskDir = (Resolve-Path -LiteralPath $taskDir).Path
    $expectedPrefix = $resolvedTarget + [IO.Path]::DirectorySeparatorChar
    if (-not $resolvedTaskDir.StartsWith($expectedPrefix, [StringComparison]::OrdinalIgnoreCase)) {
      throw "Refusing to back up task artifacts outside target root: $resolvedTaskDir"
    }

    $backupDir = Join-Path $BackupRoot $relativePath
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    foreach ($item in @(Get-ChildItem -LiteralPath $resolvedTaskDir -Force)) {
      Copy-Item -LiteralPath $item.FullName -Destination $backupDir -Recurse -Force
    }
  }
}

function Restore-TargetTaskArtifacts {
  param(
    [string]$Target,
    [string]$BackupRoot
  )

  if (-not (Test-Path -LiteralPath $BackupRoot)) {
    return
  }

  $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
  foreach ($relativePath in @('harness/docs/tasks/active', 'harness/docs/tasks/archive')) {
    $backupDir = Join-Path $BackupRoot $relativePath
    if (-not (Test-Path -LiteralPath $backupDir)) {
      continue
    }

    $taskDir = Join-Path $resolvedTarget $relativePath
    New-Item -ItemType Directory -Path $taskDir -Force | Out-Null
    foreach ($item in @(Get-ChildItem -LiteralPath $backupDir -Force)) {
      Copy-Item -LiteralPath $item.FullName -Destination $taskDir -Recurse -Force
    }
  }
}

function Verify-Install {
  param(
    [string]$Target,
    [string]$Template
  )

  foreach ($required in @('AGENTS.md', 'README.md', 'CONTEXT.md', 'handoff.md', 'harness', 'modules', 'module-template', 'proposals')) {
    if (-not (Test-Path -LiteralPath (Join-Path $Target $required))) {
      throw "Missing required root item: $required"
    }
  }

  foreach ($nestedName in @('jjamppong-harness', 'ourosuper-harness')) {
    if (Test-Path -LiteralPath (Join-Path $Target $nestedName)) {
      throw "Nested template folder was created: $nestedName"
    }
  }

  $origin = git -C $Target remote get-url origin
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($origin)) {
    throw 'Installed project root has no origin.'
  }
  if (Test-TemplateSourceOrigin -Origin $origin -Template $Template) {
    throw "Installed project origin still points at template source: $origin"
  }

  Write-Output "Verified harness root: $Target"
  Write-Output "Verified project origin: $origin"
}

$normalizedTemplate = Normalize-TemplateSource $TemplateSource
$target = Normalize-TargetPath $TargetPath

Write-Output "Template source: $normalizedTemplate"
Write-Output "Target project root: $target"

New-Item -ItemType Directory -Path $target -Force | Out-Null
$gitTop = Get-GitTopLevel $target
if ($gitTop -and $gitTop -ne $target) {
  throw "Target is inside another git repository. Open or install at the project root: $gitTop"
}
$existingOrigin = Get-ExistingOrigin -Target $target
$hasExistingProjectOrigin = $existingOrigin -and -not (Test-TemplateSourceOrigin -Origin $existingOrigin -Template $normalizedTemplate)
if ($hasExistingProjectOrigin) {
  $projectRepoUrl = $existingOrigin
}
else {
  $projectRepoUrl = Get-ProjectRepoUrl -Template $normalizedTemplate -Target $target -ExplicitRepo $ProjectRepo -ExplicitOwner $Owner
}

Write-Output "Project origin candidate: $projectRepoUrl"

$tempBase = (Resolve-Path -LiteralPath ([IO.Path]::GetTempPath())).Path.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$tempRoot = Join-Path $tempBase ('jjamppong-harness-' + [guid]::NewGuid().ToString('N'))
$sourceRoot = $null
$createdTempClone = $false
$taskArtifactBackupRoot = Join-Path $tempBase ('jjamppong-task-artifacts-' + [guid]::NewGuid().ToString('N'))
$hadTargetTaskArtifacts = $false
$installCompleted = $false

try {
  if (Test-Path -LiteralPath $normalizedTemplate) {
    $sourceRoot = (Resolve-Path -LiteralPath $normalizedTemplate).Path
  }
  else {
    git clone $normalizedTemplate $tempRoot
    if ($LASTEXITCODE -ne 0) {
      throw "Template clone failed: $normalizedTemplate"
    }
    $sourceRoot = (Resolve-Path -LiteralPath $tempRoot).Path
    $createdTempClone = $true
  }

  $hadTargetTaskArtifacts = Test-Path -LiteralPath (Join-Path $target 'harness/docs/tasks')
  if ($hadTargetTaskArtifacts) {
    Backup-TargetTaskArtifacts -Target $target -BackupRoot $taskArtifactBackupRoot
  }
  Copy-TemplateRoot -Source $sourceRoot -Target $target -Overwrite:$AllowOverwrite
  Clear-InstalledTaskArtifacts -Target $target
  if ($hadTargetTaskArtifacts) {
    Restore-TargetTaskArtifacts -Target $target -BackupRoot $taskArtifactBackupRoot
  }
  Set-ProjectOrigin -Target $target -Template $normalizedTemplate -Project $projectRepoUrl
  $installedOrigin = git -C $target remote get-url origin
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($installedOrigin)) {
    throw 'Installed project root has no origin after origin setup.'
  }
  if (-not $hasExistingProjectOrigin) {
    Ensure-GitHubRepo -RepoUrl $installedOrigin -Skip:$SkipGitHubRepo
  }
  Verify-Install -Target $target -Template $normalizedTemplate
  $installCompleted = $true
}
finally {
  if ($createdTempClone -and (Test-Path -LiteralPath $tempRoot)) {
    $resolvedTemp = (Resolve-Path -LiteralPath $tempRoot).Path
    $expectedPrefix = $tempBase + [IO.Path]::DirectorySeparatorChar
    if (-not $resolvedTemp.StartsWith($expectedPrefix, [StringComparison]::OrdinalIgnoreCase) -or -not (Split-Path -Leaf $resolvedTemp).StartsWith('jjamppong-harness-')) {
      throw "Refusing to remove unexpected temp path: $resolvedTemp"
    }
    Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
  }
  if (Test-Path -LiteralPath $taskArtifactBackupRoot) {
    $resolvedBackup = (Resolve-Path -LiteralPath $taskArtifactBackupRoot).Path
    $expectedPrefix = $tempBase + [IO.Path]::DirectorySeparatorChar
    if (-not $resolvedBackup.StartsWith($expectedPrefix, [StringComparison]::OrdinalIgnoreCase) -or -not (Split-Path -Leaf $resolvedBackup).StartsWith('jjamppong-task-artifacts-')) {
      throw "Refusing to remove unexpected task artifact backup: $resolvedBackup"
    }
    if ($installCompleted) {
      Remove-Item -LiteralPath $resolvedBackup -Recurse -Force
    }
    else {
      Write-Output "Preserved task artifact backup after failed install: $resolvedBackup"
    }
  }
}

Write-Output 'Install complete. Commit and push still require explicit user approval.'
