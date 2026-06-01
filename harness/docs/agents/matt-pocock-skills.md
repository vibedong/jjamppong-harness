# Matt Pocock Skills

짬뽕하네스 requires these external Matt Pocock skills:

- `setup-matt-pocock-skills`
- `grill-with-docs`
- `to-prd`
- `to-issues`

## Readiness Check

Before the planning gate continues, the agent must verify that the required skills are available in the current Codex skill list or installed skill directories.

Use this readiness command in PowerShell when the visible skill list is unavailable:

```powershell
$required = @(
  'setup-matt-pocock-skills',
  'grill-with-docs',
  'to-prd',
  'to-issues'
)
$roots = @(
  (Join-Path $env:USERPROFILE '.codex/skills'),
  (Join-Path $env:USERPROFILE '.agents/skills')
)
$skillFiles = foreach ($root in $roots) {
  if (Test-Path -LiteralPath $root) {
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'SKILL.md' -ErrorAction SilentlyContinue
  }
}
$missing = foreach ($skill in $required) {
  $found = $skillFiles | Where-Object {
    Select-String -LiteralPath $_.FullName -Pattern "name: $skill" -Quiet
  }
  if (-not $found) { $skill }
}
if ($missing) {
  $missing
  throw "Missing required Matt Pocock planning skills"
}
"OK: all Matt Pocock planning skills available"
```

If any required skill is unavailable, stop and tell the user:

```text
Matt Pocock planning skills are required before this harness can continue.
Install them first, then rerun this task.
```

## Install Reference

Use the official installer when available:

```bash
npx skills@latest add mattpocock/skills
```

Do not vendor-copy the skill files into this repository.
