param(
  [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
  throw 'Node.js is required to run PermissionDecision MVP tests.'
}

$engine = Join-Path $RepoRoot 'harness\permission\permission-decision.js'
if (-not (Test-Path -LiteralPath $engine)) {
  throw "PermissionDecision engine not found: $engine"
}

$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function New-TestTask {
  param(
    [string[]]$TaskYamlLines,
    [string]$ApprovalMarkdown = ''
  )

  $dir = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-perm-test-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $dir | Out-Null
  Set-Content -LiteralPath (Join-Path $dir 'task.yaml') -Value $TaskYamlLines -Encoding UTF8
  if (-not [string]::IsNullOrWhiteSpace($ApprovalMarkdown)) {
    Set-Content -LiteralPath (Join-Path $dir 'implementation-approval.md') -Value $ApprovalMarkdown -Encoding UTF8
  }
  return $dir
}

function Get-BaseTaskYaml {
  param([string]$CurrentGate)
  return @(
    'task_id: test-task',
    'task_type: product_feature',
    'status: active',
    "current_gate: $CurrentGate",
    'approval_summary:',
    '  implementation: locked',
    '  allowed_capabilities: []',
    '  allowed_paths: []',
    '  package_install: false',
    '  network_live_target: false',
    '  git_commit: false',
    '  git_push: false',
    '  approval_source: ""'
  )
}

function Get-ApprovedTaskYaml {
  return @(
    'task_id: test-task',
    'task_type: product_feature',
    'status: active',
    'current_gate: work',
    'approval_summary:',
    '  implementation: approved',
    '  allowed_capabilities:',
    '    - file.write.module',
    '  allowed_paths:',
    '    - modules/sample/**',
    '  package_install: false',
    '  network_live_target: false',
    '  git_commit: false',
    '  git_push: false',
    '  approval_source: "current chat explicit approval"'
  )
}

function Get-ApprovalMarkdown {
  return @'
# 구현 승인

## 승인 질문
modules/sample 아래 파일 쓰기를 허용할까요?

## 사용자 답변 요약
허용.

## 허용 작업
- file.write.module: modules/sample/**

## 금지 작업
- git.commit
- git.push
- package.install
- network.live_target

## 파일 범위
- modules/sample/**

## 테스트 범위
- contract tests

## Capability 허용 여부
- file.write.module: 허용

## 승인 만료 또는 철회 조건
- 사용자가 취소하면 철회
'@
}

function Invoke-PermissionDecision {
  param(
    [string[]]$TaskYamlLines,
    [string]$Capability,
    [string]$Path = '',
    [string]$Action = 'file_write',
    [string]$ApprovalMarkdown = ''
  )

  $taskDir = New-TestTask -TaskYamlLines $TaskYamlLines -ApprovalMarkdown $ApprovalMarkdown
  try {
    $args = @(
      $engine,
      '--repo-root', $RepoRoot,
      '--task-yaml', (Join-Path $taskDir 'task.yaml'),
      '--task-root', $taskDir,
      '--capability', $Capability,
      '--action', $Action
    )
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
      $args += @('--path', $Path)
    }

    $oldErrorActionPreference = $ErrorActionPreference
    $nativePreference = Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue
    $oldNativePreference = if ($null -ne $nativePreference) { $nativePreference.Value } else { $null }
    try {
      $ErrorActionPreference = 'Continue'
      if ($null -ne $nativePreference) {
        $PSNativeCommandUseErrorActionPreference = $false
      }
      $output = & node @args 2>&1
      $exitCode = $LASTEXITCODE
    }
    finally {
      $ErrorActionPreference = $oldErrorActionPreference
      if ($null -ne $nativePreference) {
        $PSNativeCommandUseErrorActionPreference = $oldNativePreference
      }
    }

    $jsonText = $output -join "`n"
    try {
      $json = $jsonText | ConvertFrom-Json
      if ($json -is [array]) {
        return $json[0]
      }
      return $json
    }
    catch {
      return [pscustomobject]@{
        decision = 'error'
        reason = "PermissionDecision did not return JSON. exit=$exitCode output=$jsonText"
      }
    }
  }
  finally {
    Remove-Item -LiteralPath $taskDir -Recurse -Force
  }
}

function Assert-Decision {
  param(
    [string]$Name,
    [string]$Expected,
    [object]$Actual,
    [string]$ReasonContains = ''
  )

  $script:checks += 1
  if ($Actual.decision -ne $Expected) {
    $script:failures.Add("$Name expected '$Expected' but got '$($Actual.decision)': $($Actual.reason)")
    return
  }
  if (-not [string]::IsNullOrWhiteSpace($ReasonContains)) {
    $script:checks += 1
    if (-not ([string]$Actual.reason).Contains($ReasonContains)) {
      $script:failures.Add("$Name reason should contain '$ReasonContains' but was '$($Actual.reason)'")
    }
  }
}

Assert-Decision 'project read denied before research gate' 'deny' (
  Invoke-PermissionDecision -TaskYamlLines (Get-BaseTaskYaml -CurrentGate 'intake') -Capability 'file.read.project' -Path 'README.md' -Action 'file_read'
)

Assert-Decision 'project read allowed during research gate' 'allow' (
  Invoke-PermissionDecision -TaskYamlLines (Get-BaseTaskYaml -CurrentGate 'research') -Capability 'file.read.project' -Path 'README.md' -Action 'file_read'
)

Assert-Decision 'web research allowed only during research gate' 'allow' (
  Invoke-PermissionDecision -TaskYamlLines (Get-BaseTaskYaml -CurrentGate 'research') -Capability 'network.web_research' -Action 'network_access'
)

Assert-Decision 'web research denied outside research gate' 'deny' (
  Invoke-PermissionDecision -TaskYamlLines (Get-BaseTaskYaml -CurrentGate 'writing_plan') -Capability 'network.web_research' -Action 'network_access'
)

Assert-Decision 'research gate does not unlock module write' 'deny' (
  Invoke-PermissionDecision -TaskYamlLines (Get-BaseTaskYaml -CurrentGate 'research') -Capability 'file.write.module' -Path 'modules/sample/app.js'
)

Assert-Decision 'approved module write allows approved path' 'allow' (
  Invoke-PermissionDecision -TaskYamlLines (Get-ApprovedTaskYaml) -ApprovalMarkdown (Get-ApprovalMarkdown) -Capability 'file.write.module' -Path 'modules/sample/app.js'
) 'Allowed by task.yaml approval_summary'

Assert-Decision 'approved module write denies unapproved path' 'deny' (
  Invoke-PermissionDecision -TaskYamlLines (Get-ApprovedTaskYaml) -ApprovalMarkdown (Get-ApprovalMarkdown) -Capability 'file.write.module' -Path 'modules/other/app.js'
)

Assert-Decision 'approved module write still denies git commit' 'deny' (
  Invoke-PermissionDecision -TaskYamlLines (Get-ApprovedTaskYaml) -ApprovalMarkdown (Get-ApprovalMarkdown) -Capability 'git.commit' -Action 'git_operation'
)

Assert-Decision 'approved module write still denies package install' 'deny' (
  Invoke-PermissionDecision -TaskYamlLines (Get-ApprovedTaskYaml) -ApprovalMarkdown (Get-ApprovalMarkdown) -Capability 'package.install' -Action 'package_install'
)

Assert-Decision 'dangerous write requires implementation approval markdown' 'deny' (
  Invoke-PermissionDecision -TaskYamlLines (Get-ApprovedTaskYaml) -Capability 'file.write.module' -Path 'modules/sample/app.js'
) 'Implementation approval summary is missing'

Assert-Decision 'secret read denied' 'deny' (
  Invoke-PermissionDecision -TaskYamlLines (Get-BaseTaskYaml -CurrentGate 'research') -Capability 'file.read.secret' -Path '.env' -Action 'file_read'
)

Assert-Decision 'harness core write in product task requires proposal' 'proposal_required' (
  Invoke-PermissionDecision -TaskYamlLines (Get-ApprovedTaskYaml) -ApprovalMarkdown (Get-ApprovalMarkdown) -Capability 'file.write.harness_core' -Path 'harness/rules/workflow.md'
)

if ($failures.Count -gt 0) {
  Write-Output "PermissionDecision MVP failed $($failures.Count) of $checks checks:"
  foreach ($failure in $failures) {
    Write-Output "FAIL $failure"
  }
  exit 1
}

Write-Output "PermissionDecision MVP passed $checks checks."
