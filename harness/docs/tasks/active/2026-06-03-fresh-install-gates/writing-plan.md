# Fresh Install Gates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make a fresh `jjamppong-harness` install reliably enforce grill routing and module structure approval before product PRD, issues, writing plans, folders, or code.

**Architecture:** Strengthen the template-level instructions and installer verification instead of patching one project folder. The install script must prove that the copied harness includes the current gate rules, and README must explain the expected first product-request behavior in Korean.

**Tech Stack:** Markdown harness rules, PowerShell installer, Git verification commands.

---

## File Structure

- Modify: `AGENTS.md`
  - Add `harness/state/module-structure.md` to required reads for substantive product work.
  - Add a first-product-request rule that stops before `to-prd` when no module structure is approved.
- Modify: `harness/rules/workflow.md`
  - Move Module Structure Gate wording from "before creating folders" to "before product PRD/issues/writing-plan when no approved structure exists".
  - Keep non-module work exempt by requiring `Module Structure Gate: not applicable` in `grill.md`.
- Modify: `harness/rules/rules.md`
  - Mirror the same stop condition so short-context agents see it outside `workflow.md`.
- Modify: `harness/rules/module-types.md`
  - Clarify that module structure is selected before product PRD when the project has no approved structure.
- Modify: `README.md`
  - Add the expected first-run scenario after a clean install.
  - Explain that the first product request should choose module structure before detailed feature planning.
- Modify: `scripts/install-jjamppong-harness.ps1`
  - Add verification that installed `workflow.md`, `rules.md`, and `AGENTS.md` contain the fresh gate labels.
  - Add verification that installed task artifact folders are empty for a new install.
- Create: `harness/docs/tasks/active/2026-06-03-fresh-install-gates/verification.md`
  - Record install smoke commands and results.

---

### Task 1: Strengthen Product-Request Gate Rules

**Files:**
- Modify: `AGENTS.md`
- Modify: `harness/rules/workflow.md`
- Modify: `harness/rules/rules.md`
- Modify: `harness/rules/module-types.md`

- [ ] **Step 1: Update `AGENTS.md` required reads**

Add `harness/state/module-structure.md` to the required reads list and keep `workflow.md` and `rules.md` first.

Expected final list:

```markdown
At the start of a substantive task, read:

1. `harness/rules/workflow.md`
2. `harness/rules/rules.md`
3. `harness/state/module-structure.md`
```

- [ ] **Step 2: Add first product-request hard rule**

Add this rule under `AGENTS.md` Hard Rules:

```markdown
- If a user asks to build a product feature and no module structure is approved, stop before `to-prd`, `to-issues`, `writing-plan`, module folders, or product code. First run the Module Structure Gate and ask the user to approve or revise the project module structure.
```

- [ ] **Step 3: Update `workflow.md` Module Structure Gate position**

Replace the first sentence of `### Module Structure Gate` with:

```markdown
Run this gate before `to-prd`, `to-issues`, `writing-plan`, product module folders, or product code when the request may create or change product module folders or product code.
```

Then replace the first numbered item with:

```markdown
1. Stop before `to-prd`, `to-issues`, `writing-plan`, module folders, or product code.
```

- [ ] **Step 4: Mirror the stop condition in `rules.md`**

In section `## 4. Module Structure Is Not Invented Inline`, replace the sentence beginning `The Module Structure Gate runs before` with:

```markdown
The Module Structure Gate runs before `to-prd`, `to-issues`, `writing-plan`, product module folder creation, product module folder changes, or product code writing when the project has no approved module structure.
```

Replace:

```markdown
If `modules/` is empty, or if `harness/state/module-structure.md` says no project module structure has been approved, Codex must not create product module folders or write product code.
```

with:

```markdown
If `modules/` is empty, or if `harness/state/module-structure.md` says no project module structure has been approved, Codex must not run product `to-prd`, product `to-issues`, product `writing-plan`, create product module folders, or write product code.
```

- [ ] **Step 5: Clarify `module-types.md`**

Add this paragraph after `It is handled by the Module Structure Gate, not by an ad hoc side flow.`:

```markdown
When a project has no approved module structure, the first product request uses the Module Structure Gate before product PRD, issue decomposition, writing plans, module folders, or product code.
```

- [ ] **Step 6: Verify rule text**

Run:

```powershell
rg -n "before `to-prd`|no approved module structure|harness/state/module-structure.md" AGENTS.md harness/rules
```

Expected: matches in `AGENTS.md`, `harness/rules/workflow.md`, `harness/rules/rules.md`, and `harness/rules/module-types.md`.

---

### Task 2: Add Installer Verification For Fresh Gates

**Files:**
- Modify: `scripts/install-jjamppong-harness.ps1`

- [ ] **Step 1: Add file-content verification helper**

Inside `Verify-Install`, after required root item checks and before nested folder checks, add checks equivalent to:

```powershell
$requiredTextChecks = @(
  @{ Path = 'AGENTS.md'; Pattern = 'harness/state/module-structure.md' },
  @{ Path = 'AGENTS.md'; Pattern = 'stop before `to-prd`, `to-issues`, `writing-plan`, module folders, or product code' },
  @{ Path = 'harness/rules/workflow.md'; Pattern = 'Grill Routing And Completion Gate' },
  @{ Path = 'harness/rules/workflow.md'; Pattern = 'Module Structure Gate' },
  @{ Path = 'harness/rules/workflow.md'; Pattern = 'before `to-prd`, `to-issues`, `writing-plan`' },
  @{ Path = 'harness/rules/rules.md'; Pattern = 'must not run product `to-prd`, product `to-issues`, product `writing-plan`' }
)

foreach ($check in $requiredTextChecks) {
  $path = Join-Path $Target $check.Path
  $content = Get-Content -LiteralPath $path -Raw
  if (-not $content.Contains($check.Pattern)) {
    throw "Installed harness is missing required gate text in $($check.Path): $($check.Pattern)"
  }
}
```

- [ ] **Step 2: Verify fresh task directories are empty**

Still inside `Verify-Install`, after nested folder checks, verify `harness/docs/tasks/active` and `harness/docs/tasks/archive` contain no template-maintenance task folders:

```powershell
foreach ($relativePath in @('harness/docs/tasks/active', 'harness/docs/tasks/archive')) {
  $taskDir = Join-Path $Target $relativePath
  $taskItems = @(Get-ChildItem -LiteralPath $taskDir -Force | Where-Object { $_.Name -ne '.gitkeep' })
  if ($taskItems.Count -ne 0) {
    throw "Installed task artifact directory is not empty: $relativePath"
  }
}
```

- [ ] **Step 3: Run script syntax check**

Run:

```powershell
$null = [System.Management.Automation.Language.Parser]::ParseFile(
  'scripts/install-jjamppong-harness.ps1',
  [ref]$null,
  [ref]$null
)
```

Expected: no parser error output.

---

### Task 3: Update Korean README Scenario

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add first product-request scenario**

Under `## 하네스 적용 예상 시나리오`, include a scenario that says a clean project with no approved module structure must ask for module structure before product PRD.

Text to include:

```markdown
### 첫 제품 요청에서 기대되는 흐름

새로 설치한 프로젝트는 `harness/state/module-structure.md`가 미승인 상태로 시작합니다. 이 상태에서 사용자가 "나라장터 크롤러를 만들고 싶어"처럼 제품 기능을 요청하면 Codex는 바로 PRD나 구현 계획으로 가지 않습니다.

먼저 기존 코드와 문서를 확인해 `grill-with-docs` 또는 `grill-me`를 고르고, 핵심 불확실성을 정리한 뒤 Module Structure Gate에서 프로젝트 폴더 구조 선택지를 제안해야 합니다. 사용자가 구조를 승인하면 그 내용을 `harness/state/module-structure.md`에 기록하고, 그 다음에 PRD, 이슈, writing-plan으로 넘어갑니다.
```

- [ ] **Step 2: Add quick failure example**

Text to include:

```markdown
잘못된 흐름은 `intake.md`만 쓰고 바로 `to-prd`나 `writing-plan`으로 넘어가는 것입니다. `modules/`가 비어 있고 승인된 module structure가 없다면, 제품 요청은 반드시 구조 승인 질문에서 멈춰야 합니다.
```

- [ ] **Step 3: Verify README text**

Run:

```powershell
rg -n "첫 제품 요청|Module Structure Gate|잘못된 흐름|writing-plan" README.md
```

Expected: all four phrases appear.

---

### Task 4: Fresh Install Smoke Test

**Files:**
- Create: `harness/docs/tasks/active/2026-06-03-fresh-install-gates/verification.md`

- [ ] **Step 1: Create a disposable clean target**

Run:

```powershell
$target = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-smoke-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $target -Force | Out-Null
```

Expected: `$target` is a new empty directory under `%TEMP%`.

- [ ] **Step 2: Run local template installer**

Run:

```powershell
& .\scripts\install-jjamppong-harness.ps1 . $target -ProjectRepo 'https://github.com/vibedong/jjamppong-smoke.git' -SkipGitHubRepo
```

Expected output includes:

```text
Verified harness root:
Verified project origin: https://github.com/vibedong/jjamppong-smoke.git
Install complete. Commit and push still require explicit user approval.
```

- [ ] **Step 3: Verify root layout**

Run:

```powershell
Test-Path (Join-Path $target 'AGENTS.md')
Test-Path (Join-Path $target 'harness')
Test-Path (Join-Path $target 'modules')
Test-Path (Join-Path $target 'jjamppong-harness')
```

Expected:

```text
True
True
True
False
```

- [ ] **Step 4: Verify installed gate text**

Run:

```powershell
rg -n "Grill Routing And Completion Gate|Module Structure Gate|before `to-prd`|must not run product `to-prd`" $target
```

Expected: matches in installed `AGENTS.md`, `harness/rules/workflow.md`, and `harness/rules/rules.md`.

- [ ] **Step 5: Verify no task artifacts leaked**

Run:

```powershell
Get-ChildItem -LiteralPath (Join-Path $target 'harness/docs/tasks/active') -Force
Get-ChildItem -LiteralPath (Join-Path $target 'harness/docs/tasks/archive') -Force
```

Expected: no files except optional `.gitkeep`.

- [ ] **Step 6: Record verification**

Write `harness/docs/tasks/active/2026-06-03-fresh-install-gates/verification.md` with commands, expected outputs, actual output summary, and unresolved risks.

- [ ] **Step 7: Remove disposable target**

Run after recording proof:

```powershell
Remove-Item -LiteralPath $target -Recurse -Force
```

Expected: temp smoke folder removed.

---

### Task 5: Git Review And Push Readiness

**Files:**
- No new source files beyond previous tasks.

- [ ] **Step 1: Review changed files**

Run:

```powershell
git status --short
git diff --stat
```

Expected changed files:

```text
AGENTS.md
README.md
harness/rules/module-types.md
harness/rules/rules.md
harness/rules/workflow.md
harness/docs/tasks/active/2026-06-03-fresh-install-gates/writing-plan.md
harness/docs/tasks/active/2026-06-03-fresh-install-gates/verification.md
scripts/install-jjamppong-harness.ps1
```

- [ ] **Step 2: Ask for commit and push approval**

Before committing, show the branch, changed files, and verification summary.

Expected branch:

```text
task/readme-required-tools
```

Do not commit or push until the user explicitly approves.

---

## Self-Review

**Spec coverage:** The plan covers the repeated failure mode: fresh project install, stale rules in installed projects, module structure not being selected before product planning, and installer verification that rejects missing gate text.

**Placeholder scan:** No `TBD`, `TODO`, `implement later`, or unspecified test step remains.

**Type consistency:** The same labels are used throughout: `Grill Routing And Completion Gate`, `Module Structure Gate`, `harness/state/module-structure.md`, `to-prd`, `to-issues`, and `writing-plan`.

