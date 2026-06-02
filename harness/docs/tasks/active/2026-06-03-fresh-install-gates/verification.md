# Verification: Fresh Install Gates

Date: 2026-06-03

## Commands Run

### Rule text check

```powershell
rg -n 'before `to-prd`|no approved module structure|harness/state/module-structure.md|must not run product `to-prd`' AGENTS.md harness/rules
```

Result: passed. Matches were found in:

- `AGENTS.md`
- `harness/rules/workflow.md`
- `harness/rules/rules.md`
- `harness/rules/module-types.md`

### README scenario check

```powershell
rg -n '첫 제품 요청|Module Structure Gate|잘못된 흐름|writing-plan' README.md
```

Result: passed. README now explains that the first product request in a fresh project stops at Module Structure Gate before PRD, issues, writing-plan, module folders, or product code.

### PowerShell parser check

```powershell
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
  'F:\Folder\ourosuper-harness\scripts\install-jjamppong-harness.ps1',
  [ref]$tokens,
  [ref]$errors
) | Out-Null
$errors.Count
```

Result: passed. Parser output reported no errors.

### Fresh install smoke

```powershell
$target = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-smoke-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $target -Force | Out-Null
& .\scripts\install-jjamppong-harness.ps1 . $target -ProjectRepo 'https://github.com/vibedong/jjamppong-smoke.git' -SkipGitHubRepo
```

Result: passed. The installer reported:

```text
Verified harness root: C:\Users\gkdkd\AppData\Local\Temp\jjamppong-smoke-e05535ab1bde4e27aafeb48cbe215347
Verified project origin: https://github.com/vibedong/jjamppong-smoke.git
Install complete. Commit and push still require explicit user approval.
```

### Fresh install root layout

```powershell
Test-Path (Join-Path $target 'AGENTS.md')
Test-Path (Join-Path $target 'harness')
Test-Path (Join-Path $target 'modules')
Test-Path (Join-Path $target 'jjamppong-harness')
```

Result:

```text
AGENTS=True
HARNESS=True
MODULES=True
NESTED=False
```

### Installed gate text

```powershell
rg -n 'Grill Routing And Completion Gate|Module Structure Gate|before `to-prd`|must not run product `to-prd`|before product PRD' $target
```

Result: passed. Matches were found in the installed copies of:

- `AGENTS.md`
- `harness/rules/workflow.md`
- `harness/rules/rules.md`
- `harness/rules/module-types.md`
- `README.md`
- `scripts/install-jjamppong-harness.ps1`

### Task artifact leak check

```powershell
$active = @(Get-ChildItem -LiteralPath (Join-Path $target 'harness/docs/tasks/active') -Force | Where-Object { $_.Name -ne '.gitkeep' })
$archive = @(Get-ChildItem -LiteralPath (Join-Path $target 'harness/docs/tasks/archive') -Force | Where-Object { $_.Name -ne '.gitkeep' })
$active.Count
$archive.Count
```

Result:

```text
ACTIVE_COUNT=0
ARCHIVE_COUNT=0
```

### Cleanup

```powershell
Remove-Item -LiteralPath $target -Recurse -Force
```

Result:

```text
REMOVED=True
```

## Remaining Risk

This verifies the template files and installer output. It does not simulate a full new Codex chat with a live model response. The expected live behavior is now strongly encoded in installed `AGENTS.md`, `workflow.md`, `rules.md`, and README, and the installer will fail if those gate labels are missing.

