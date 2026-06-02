# Grill Routing And Module Structure Gates Verification

## Commands

### Governance Text Check

```powershell
rg -n "Grill Routing And Completion Gate|Grill Result Record|Module Structure Gate|grill-me|grill-with-docs|HITL/AFK|grill.md" AGENTS.md README.md harness/rules/workflow.md harness/rules/rules.md harness/rules/module-types.md
```

Expected: matches in all intended governance surfaces.

Actual: passed. Matches appeared in `AGENTS.md`, `README.md`, `harness/rules/workflow.md`, `harness/rules/rules.md`, and `harness/rules/module-types.md`.

### README Expected Scenario Check

```powershell
rg -n "Expected Harness Scenario|dailynara|If the existing code is spaghetti|Bad behavior this harness is meant to prevent|Do not start coding|Ask only the remaining decision questions" README.md
```

Expected: README explains the expected flow after applying the harness, including the 나라장터/dailynara scenario, spaghetti-code handling, and bad behavior to prevent.

Actual: passed.

### Stale Shortcut Check

```powershell
$stale = Select-String -LiteralPath 'AGENTS.md','README.md','harness/rules/workflow.md','harness/rules/rules.md','harness/rules/module-types.md' -Pattern '^\s*3\.\s+grill-with-docs\s*$','setup-matt-pocock-skills readiness check, grill-with-docs, to-prd','-> grill-with-docs','gh repo create .*--template','git -C ''F:/mptech'' push'
if ($stale) {
  $stale
  throw 'Stale planning, installer, or push shortcut remains'
}
Write-Output 'No stale planning, installer, or push shortcut'
```

Expected: no stale planning shortcut, no direct GitHub template clone install command, and no direct push recovery command.

Actual: passed with `No stale planning, installer, or push shortcut`.

### Proposal Removal Check

```powershell
Test-Path -LiteralPath 'proposals/2026-06-02-grill-module-gates.md'
```

Expected: `False`.

Actual: `False`.

### Scope Expansion Approval Check

Expected: task artifacts record why the final branch touches files beyond the initial proposal's file list.

Actual: passed. `writing-plan.md` and `reviews.md` record that the user approved expanded live-harness changes with: "전체다 변경해도돼. 지금 하네스안쓰고있어."

### Module Structure Default Check

```powershell
Get-Content -LiteralPath 'harness/state/module-structure.md'
```

Expected: default conservative state remains and references Module Structure Gate.

Actual: passed. The file still says no project module structure has been approved and now clarifies that module types and folder standards are approved through the Module Structure Gate in the Full Workflow.

### Install Smoke Test

```powershell
$tempBase = (Resolve-Path -LiteralPath ([IO.Path]::GetTempPath())).Path.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$target = Join-Path $tempBase ('jjamppong-grill-gate-smoke-' + [guid]::NewGuid().ToString('N'))
try {
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-jjamppong-harness.ps1 'F:\Folder\ourosuper-harness' $target -ProjectRepo 'https://github.com/vibedong/install-test-project.git' -SkipGitHubRepo
  if ($LASTEXITCODE -ne 0) { throw "installer exited with $LASTEXITCODE" }
  foreach ($required in @('AGENTS.md','README.md','harness','modules','module-template','proposals')) {
    if (-not (Test-Path -LiteralPath (Join-Path $target $required))) { throw "Missing $required" }
  }
  rg -n "Grill Routing And Completion Gate|Grill Result Record|Module Structure Gate|grill-me|grill-with-docs|grill.md" (Join-Path $target 'AGENTS.md') (Join-Path $target 'README.md') (Join-Path $target 'harness/rules/workflow.md') (Join-Path $target 'harness/rules/rules.md') (Join-Path $target 'harness/rules/module-types.md')
  if ($LASTEXITCODE -ne 0) { throw 'Installed copy is missing grill/module gate text' }
  $stale = Select-String -LiteralPath (Join-Path $target 'README.md'),(Join-Path $target 'harness/rules/workflow.md'),(Join-Path $target 'AGENTS.md'),(Join-Path $target 'harness/rules/module-types.md') -Pattern '^\s*3\.\s+grill-with-docs\s*$','setup-matt-pocock-skills readiness check, grill-with-docs, to-prd','-> grill-with-docs','gh repo create .*--template'
  if ($stale) { throw 'Installed copy still has stale planning or installer shortcut' }
  foreach ($taskArtifactDir in @((Join-Path $target 'harness/docs/tasks/active'), (Join-Path $target 'harness/docs/tasks/archive'))) {
    $taskArtifacts = @(Get-ChildItem -LiteralPath $taskArtifactDir -Force)
    if ($taskArtifacts.Count -ne 0) { throw "Installed task artifact directory is not empty: $taskArtifactDir" }
  }
  Write-Output 'Install smoke passed'
}
finally {
  if (Test-Path -LiteralPath $target) {
    $resolved = (Resolve-Path -LiteralPath $target).Path
    if (-not $resolved.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or -not (Split-Path -Leaf $resolved).StartsWith('jjamppong-grill-gate-smoke-')) {
      throw "Refusing to remove unexpected temp target: $resolved"
    }
    Remove-Item -LiteralPath $resolved -Recurse -Force
  }
}
```

Expected:

- Installer completes.
- Required root files exist.
- Installed copy contains the new grill/module gate text, including `module-types.md`.
- Installed copy has no stale planning shortcut.
- Installed copy has no direct GitHub template clone install command.
- Installed task artifact directories start empty.
- Temporary target is removed.

Actual: passed. Output ended with `Install smoke passed`.

### Install Task Artifact Preservation Check

```powershell
$tempBase = (Resolve-Path -LiteralPath ([IO.Path]::GetTempPath())).Path.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$target = Join-Path $tempBase ('jjamppong-grill-gate-preserve-' + [guid]::NewGuid().ToString('N'))
try {
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-jjamppong-harness.ps1 'F:\Folder\ourosuper-harness' $target -ProjectRepo 'https://github.com/vibedong/install-test-project.git' -SkipGitHubRepo
  if ($LASTEXITCODE -ne 0) { throw "initial installer exited with $LASTEXITCODE" }
  $keepFile = Join-Path $target 'harness/docs/tasks/active/keep.md'
  Set-Content -LiteralPath $keepFile -Value 'existing task artifact'
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-jjamppong-harness.ps1 'F:\Folder\ourosuper-harness' $target -ProjectRepo 'https://github.com/vibedong/install-test-project.git' -SkipGitHubRepo -AllowOverwrite
  if ($LASTEXITCODE -ne 0) { throw "overwrite installer exited with $LASTEXITCODE" }
  if (-not (Test-Path -LiteralPath $keepFile)) { throw 'Existing task artifact was deleted' }
  $templateArtifact = Join-Path $target 'harness/docs/tasks/active/2026-06-02-grill-module-gates'
  if (Test-Path -LiteralPath $templateArtifact) { throw 'Template maintenance task artifact leaked into existing target' }
  Write-Output 'Task artifact preservation passed'
}
finally {
  if (Test-Path -LiteralPath $target) {
    $resolved = (Resolve-Path -LiteralPath $target).Path
    if (-not $resolved.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or -not (Split-Path -Leaf $resolved).StartsWith('jjamppong-grill-gate-preserve-')) {
      throw "Refusing to remove unexpected temp target: $resolved"
    }
    Remove-Item -LiteralPath $resolved -Recurse -Force
  }
}
```

Expected: an existing target task artifact survives an `-AllowOverwrite` reinstall and template-maintenance task artifacts do not leak into the target.

Actual: passed. Output ended with `Task artifact preservation passed`.

### Existing Origin Preservation Check

Expected: installing into an existing git repo with a non-template `origin` preserves that origin and does not leak template-maintenance task artifacts.

Actual: passed. Output ended with `Existing origin preservation passed`.

### Template Origin Replacement Check

Expected: if the target `origin` points at the template source, even when the template source is a local path, installer replaces it with the project repo origin.

Actual: passed. Output ended with `Template origin replacement passed`.

### Nested Git Root Rejection Check

Expected: if target path is inside another git repository, installer rejects before copying `AGENTS.md`, `harness/`, or `modules/`.

Actual: passed. Output ended with `Nested git root rejection passed`.

### Full Installer Regression Check

Expected: one combined run covers fresh install, task artifact preservation on overwrite, existing non-template origin preservation, template origin replacement, nested git root rejection before mutation, stale shortcut absence, and temp cleanup.

Actual: passed. Output ended with `Full installer regression passed`.

### Backup Fail-Safe Check

Expected: when a target has existing task artifacts, installer keeps a temp backup until the install completes. On failure, the backup is not removed in `finally`.

Actual: passed by code inspection and regression coverage. `scripts/install-jjamppong-harness.ps1` now sets `$installCompleted = $true` only after `Verify-Install`; the task artifact backup is removed only when `$installCompleted` is true. Otherwise the script prints `Preserved task artifact backup after failed install: ...`.

### Diff And Status Check

```powershell
git diff --check
git status --short --branch --untracked-files=all
```

Expected:

- `git diff --check` exits 0.
- `git status` shows the intended live governance/state changes and task artifacts.
- Untracked task artifacts are included in intended commit scope if the user later approves commit/push.

Actual:

- `git diff --check` passed. Git printed LF-to-CRLF warnings for edited tracked files, but no whitespace errors.
- `git status --short --branch --untracked-files=all` showed branch `task/grill-module-gates`, modified governance/state files, and these intended task artifacts:
  - `harness/docs/tasks/active/2026-06-02-grill-module-gates/grill.md`
  - `harness/docs/tasks/active/2026-06-02-grill-module-gates/reviews.md`
  - `harness/docs/tasks/active/2026-06-02-grill-module-gates/verification.md`
  - `harness/docs/tasks/active/2026-06-02-grill-module-gates/writing-plan.md`

## Unresolved Risk

No verification blocker remains. The remaining risk is behavioral: future agents must actually follow the new gate text. The installer smoke test proves the new rules are installed into a fresh target.
