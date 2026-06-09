README.md:69:events.jsonl은 실제 승인 기록 원본입니다. 쉽게 말하면 작업 블랙박스입니다. 작업이 진행되면 events.jsonl에 새 줄이 추가될 수 있습니다. 이 파일이 바뀌는 것은 정상입니다. 다만 기존 기록을 마음대로 고쳐 쓰면 안 됩니다.
README.md:71:중요한 점은, AI가 평소에 events.jsonl 전체를 읽으면 안 된다는 것입니다. 이 파일은 보통 verify, doctor, debug, 승인 근거 확인처럼 원장 검사가 필요할 때만 읽습니다.
README.md:73:gate-ledger.md는 사람이 읽기 쉽게 정리한 승인 기록입니다. 권한 판단의 원본은 `events.jsonl`이며, gate-ledger.md도 AI의 필수 시작 읽기 파일은 아닙니다.
README.md:97:AI가 이 문서들을 읽으면 `events.jsonl`에 `artifact_read` 기록이 남습니다.
README.md:101:즉, AI가 "읽은 것 같다"고 말하는 게 아니라 실제 읽은 흔적을 남기게 하는 구조입니다. 다만 이 흔적을 남긴다고 해서 매번 events.jsonl 전체를 읽어야 한다는 뜻은 아닙니다.
CONTEXT.md:16:The append-only canonical task record at `harness/docs/tasks/active/<slug>/events.jsonl`.
CONTEXT.md:20:The human-readable projection at `harness/docs/tasks/active/<slug>/gate-ledger.md`.
CONTEXT.md:25:If it disagrees with `events.jsonl`, verification fails and `events.jsonl` wins.
CONTEXT.md:45:- `gate-ledger.md`, `task.yaml`, and `planning-pack.md` are projections or manifests derived from approved state.
AGENTS.md:28:Do not read the full active task `events.jsonl` for ordinary orientation or startup context.
AGENTS.md:30:Treat `events.jsonl` as a cold canonical log. Read it only for verify/doctor/debug, PermissionDecision, approval proof, event repair, archive/audit work, or when a gate explicitly needs canonical event evidence.
AGENTS.md:38:active task events.jsonl
AGENTS.md:42:`gate-ledger.md` is a human-readable projection.
AGENTS.md:65:- Before running a gate or skill, check `harness/contracts/skill-artifact-map.yaml` for required artifacts and record valid `artifact_read` events for file-backed reads.
AGENTS.md:66:- For normal task orientation, prefer `task.yaml` and compact planning context over raw logs. Never hot-load full `events.jsonl`.
harness\doctor\doctor.js:37:    projection_without_canonical_event: 'Regenerate projections from events.jsonl or ask the user for explicit approval again.',
harness\doctor\doctor.js:38:    event_hash_chain_broken: 'Stop using this task state until the event log is audited; do not invent missing approvals.',
harness\doctor\doctor.js:43:    artifact_read_receipt_missing: 'Read the required artifact, resolve its registry path, compute SHA-256 for file-backed artifacts, and append artifact_read with gate_id, artifact_id, path, hash, and proof_type.',
harness\doctor\doctor.js:45:    artifact_required_write_missing: 'Create the required gate output artifact and append artifact_written with gate_id, artifact_id, repo-relative path, and file hash, or move the task back to the previous gate.',
harness\verify\verify.js:23:  'harness/contracts/ledger-event.schema.yaml',
harness\verify\verify.js:203:    if (event.event_type !== 'artifact_read') return false;
harness\verify\verify.js:221:    if (event.event_type !== 'artifact_written') return false;
harness\verify\verify.js:235:  return event.event_type === 'artifact_written'
harness\verify\verify.js:271:    if (!event.event_id || !event.event_type || !event.event_hash) {
harness\verify\verify.js:275:        message: `Task ${taskName} has an event missing event_id/event_type/event_hash.`,
harness\verify\verify.js:278:    if (i > 0 && event.previous_hash !== events[i - 1].event_hash) {
harness\verify\verify.js:280:        id: 'event_hash_chain_broken',
harness\verify\verify.js:348:        id: 'artifact_read_receipt_missing',
harness\verify\verify.js:350:        message: `Task ${taskName} gate ${gateId} is missing a valid artifact_read receipt for ${artifactId}.`,
harness\verify\verify.js:359:        && event.event_type === 'artifact_read'
harness\verify\verify.js:381:        message: `Task ${taskName} gate ${gateId} is missing a valid artifact_written event for ${artifactId}.`,
harness\verify\verify.js:439:    return event.event_type === 'approval_decision' && payload.status === 'approved';
harness\verify\verify.js:458:    const eventsPath = path.join(taskDir, 'events.jsonl');
harness\verify\verify.js:470:          message: `Task ${task} has task.yaml permission-like state without approval_decision in events.jsonl.`,
tests\contracts\run-contract-regression.ps1:56:  'harness/contracts/ledger-event.schema.yaml',
tests\contracts\run-contract-regression.ps1:73:$ledgerSchema = Read-Text 'harness/contracts/ledger-event.schema.yaml'
tests\contracts\run-contract-regression.ps1:145:Assert-Contract ($ledgerSchema.Contains('canonical_log: events.jsonl')) 'Ledger schema must make events.jsonl canonical.'
tests\contracts\run-contract-regression.ps1:147:Assert-Contract ($taskSchema.Contains('human_projection: gate-ledger.md')) 'task schema must define gate-ledger.md as projection.'
tests\contracts\regression-catalog.yaml:168:    expected: verify_fail_without_required_artifact_read_receipts
tests\contracts\test-agents-readme.ps1:33:  'Do not read the full active task `events.jsonl` for ordinary orientation or startup context',
tests\contracts\test-agents-readme.ps1:34:  'Treat `events.jsonl` as a cold canonical log',
tests\contracts\test-agents-readme.ps1:36:  'gate-ledger.md',
tests\contracts\test-agents-readme.ps1:65:  'artifact_read'
tests\contracts\test-agents-readme.ps1:103:  'events.jsonl은 실제 승인 기록 원본입니다',
tests\contracts\test-agents-readme.ps1:105:  '작업이 진행되면 events.jsonl에 새 줄이 추가될 수 있습니다',
tests\contracts\test-agents-readme.ps1:106:  'AI가 평소에 events.jsonl 전체를 읽으면 안 된다는 것입니다',
tests\contracts\test-agents-readme.ps1:108:  'gate-ledger.md는 사람이 읽기 쉽게 정리한 승인 기록입니다',
tests\contracts\test-agents-readme.ps1:109:  'gate-ledger.md도 AI의 필수 시작 읽기 파일은 아닙니다',
tests\contracts\test-agents-readme.ps1:119:  'artifact_read',
tests\contracts\test-agents-readme.ps1:147:  Assert-Check (-not $requiredReads.Contains('active task events.jsonl')) 'AGENTS.md Required Reads must not hot-load active task events.jsonl.'
harness\release\RELEASE-NOTES.md:13:- Task templates based on `events.jsonl` as canonical state.
tests\contracts\test-artifact-routing-contracts.ps1:126:    'Record artifact_read events for required artifact reads',
tests\contracts\test-artifact-routing-contracts.ps1:141:  'artifact_read_receipts',
harness\release\CHECKSUMS.sha256:14:0becf15f9cd47f516be8182666440abcb31b111fb88b522e0a038fd6da02929c  harness/contracts/ledger-event.schema.yaml
harness\release\CHECKSUMS.sha256:51:5249985ede496c7aa57c4d7a84f9982a279cbf18ed2b12bf6738a8cba3e55d66  harness/templates/task/events.jsonl.template
harness\release\CHECKSUMS.sha256:52:0fcfef0b70e77153bfd88703df66c549841eae85018bd3c40c85444fbfa62f05  harness/templates/task/gate-ledger.md
harness\lifecycle\lifecycle.js:46:      if (entry.name === 'events.jsonl.template') {
harness\lifecycle\lifecycle.js:47:        fs.writeFileSync(path.join(targetRoot, 'events.jsonl'), '', 'utf8');
harness\lifecycle\lifecycle.js:79:  const previousHash = events.length > 0 ? events[events.length - 1].event_hash : '';
harness\lifecycle\lifecycle.js:90:  event.event_hash = sha256Text(JSON.stringify(event));
harness\lifecycle\lifecycle.js:148:  const eventsPath = path.join(taskRoot, 'events.jsonl');
harness\lifecycle\lifecycle.js:198:  appendLifecycleEvent(eventsPath, slug, 'artifact_written', {
harness\contracts\gate-contract-matrix.yaml:24:    required_artifacts: [task.yaml, events.jsonl]
harness\contracts\gate-contract-matrix.yaml:33:    writes: [planning/01-grill-summary.md, events.jsonl]
harness\contracts\gate-contract-matrix.yaml:44:    writes: [planning/02-research-summary.md, events.jsonl]
harness\contracts\gate-contract-matrix.yaml:126:    writes: [implementation-approval.md, events.jsonl]
harness\contracts\gate-contract-matrix.yaml:171:    writes: [compound-review.md, events.jsonl]
harness\contracts\artifact-registry.yaml:29:    path: events.jsonl
harness\contracts\artifact-registry.yaml:38:    path: events.jsonl
harness\contracts\artifact-registry.yaml:56:    path: gate-ledger.md
harness\contracts\ledger-event.schema.yaml:2:name: ledger-event-schema
harness\contracts\ledger-event.schema.yaml:3:canonical_log: events.jsonl
harness\contracts\ledger-event.schema.yaml:15:  - event_hash
harness\contracts\ledger-event.schema.yaml:26:      - approval_decision
harness\contracts\ledger-event.schema.yaml:27:      - artifact_read
harness\contracts\ledger-event.schema.yaml:29:      - artifact_written
harness\contracts\ledger-event.schema.yaml:44:  event_hash: {type: string}
harness\contracts\ledger-event.schema.yaml:62:  approval_decision:
harness\contracts\ledger-event.schema.yaml:73:  artifact_read:
harness\contracts\ledger-event.schema.yaml:81:  artifact_written:
harness\permission\permission-decision.js:171:    if (event.event_type === 'approval_decision' && payload.gate_id === gateId) {
harness\permission\permission-decision.js:226:    if (event.event_type !== 'approval_decision') return false;
harness\permission\permission-decision.js:250:  const eventsPath = input.eventsPath || (taskDir ? path.join(taskDir, 'events.jsonl') : null);
harness\contracts\installer-contract.yaml:29:    examples: [task.yaml, gate-ledger.md projection, index files]
harness\contracts\installer-contract.yaml:32:    examples: [events.jsonl]
harness\lifecycle\learning-classifier.js:7:    artifact_read_receipt_missing: 'artifact-routing',
harness\contracts\permission-decision.schema.yaml:48:    - canonical_event_log_hash
harness\contracts\permission-decision.schema.yaml:53:    canonical_event_log_hash: string
tests\contracts\test-lifecycle-templates.ps1:32:  'harness/templates/task/events.jsonl.template',
tests\contracts\test-lifecycle-templates.ps1:33:  'harness/templates/task/gate-ledger.md',
tests\contracts\test-lifecycle-templates.ps1:61:Assert-Check ($planningState.Contains('events.jsonl')) 'Planning state must point at events.jsonl.'
tests\contracts\test-lifecycle-templates.ps1:62:Assert-Check ($planningState.Contains('gate-ledger.md') -and $planningState.Contains('projection')) 'Planning state must treat gate-ledger.md as projection.'
tests\contracts\test-lifecycle-templates.ps1:69:$gateLedgerTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\gate-ledger.md') -Raw
tests\contracts\test-lifecycle-templates.ps1:70:Assert-Check ($gateLedgerTemplate.Contains('승인 기록')) 'gate-ledger template must be user-facing Korean by default.'
tests\contracts\test-lifecycle-templates.ps1:71:Assert-Check ($gateLedgerTemplate.Contains('원본 기록')) 'gate-ledger template must explain canonical source in Korean.'
tests\contracts\test-lifecycle-templates.ps1:72:Assert-Check ($gateLedgerTemplate.Contains('events.jsonl')) 'gate-ledger template must still reference events.jsonl.'
tests\contracts\test-lifecycle-templates.ps1:73:Assert-Check ($gateLedgerTemplate.Contains('이 파일만 보고 권한을 판단하지 마세요')) 'gate-ledger template must warn that it is not the authority.'
tests\contracts\test-lifecycle-templates.ps1:83:Assert-Check ($approvalTemplate.Contains('events.jsonl')) 'implementation approval template must still reference canonical events.'
tests\contracts\test-lifecycle-templates.ps1:126:$eventsTemplate = Get-Content -LiteralPath (Join-Path $RepoRoot 'harness\templates\task\events.jsonl.template') -Raw
tests\contracts\test-lifecycle-templates.ps1:127:Assert-Check ($eventsTemplate.Contains('template_only')) 'events.jsonl template must remain a template-only marker, not live approval evidence.'
tests\contracts\test-lifecycle-templates.ps1:136:  foreach ($file in @('task.yaml', 'events.jsonl', 'gate-ledger.md', 'planning-pack.md', 'planning\00-current-planning-context.md', 'planning\06-writing-plan.md', 'learning-capture.md', 'compound-review.md', 'archive-summary.md')) {
tests\contracts\test-lifecycle-templates.ps1:139:  $events = Get-Content -LiteralPath (Join-Path $taskRoot 'events.jsonl') -Raw
tests\contracts\test-lifecycle-templates.ps1:140:  Assert-Check ([string]::IsNullOrWhiteSpace($events)) 'Live events.jsonl should start empty.'
tests\contracts\test-lifecycle-templates.ps1:141:  $liveGateLedger = Get-Content -LiteralPath (Join-Path $taskRoot 'gate-ledger.md') -Raw
tests\contracts\test-lifecycle-templates.ps1:142:  Assert-Check ($liveGateLedger.Contains('승인 기록')) 'generated gate-ledger.md must use human-facing starter copy.'
tests\contracts\test-lifecycle-templates.ps1:143:  Assert-Check ($liveGateLedger.Contains('events.jsonl')) 'generated gate-ledger.md must point to canonical events.'
harness\rules\rules.md:10:3. active task events.jsonl
harness\rules\rules.md:14:`AGENTS.md`, this file, `workflow.md`, `gate-ledger.md`, and `task.yaml` may restrict behavior further, but they must not grant permission beyond the contracts and canonical events.
harness\rules\rules.md:16:`events.jsonl` is a cold canonical log. It is authoritative, but it is not startup context.
harness\rules\rules.md:38:`events.jsonl`, `task.yaml`, contracts, and PermissionDecision outputs keep stable machine-readable keys.
harness\rules\rules.md:40:events.jsonl, task.yaml, contracts, and PermissionDecision outputs keep stable machine-readable keys.
harness\rules\rules.md:42:`gate-ledger.md`, planning artifacts, `archive-summary.md`, `verification.md`, and `handoff.md` are human-facing.
harness\rules\rules.md:44:gate-ledger.md, planning artifacts, archive-summary.md, verification.md, and handoff.md are human-facing.
harness\rules\rules.md:62:Do not read full active task `events.jsonl` just to understand the task. Read it only for verify/doctor/debug, PermissionDecision, approval proof, event repair, archive/audit work, or an explicit gate requirement for canonical event evidence.
harness\rules\rules.md:74:Record artifact_read events for required artifact reads.
harness\rules\rules.md:76:Record `artifact_read` events for required artifact reads.
harness\rules\rules.md:78:The `artifact_read` event payload must include:
harness\rules\rules.md:150:harness/docs/tasks/active/<slug>/events.jsonl
harness\rules\rules.md:156:gate-ledger.md = human-readable projection
harness\rules\rules.md:161:If `task.yaml` or `gate-ledger.md` says something is approved but `events.jsonl` does not contain the approval, verification fails and the gate stays locked.
harness\rules\rules.md:261:events.jsonl은 verify/doctor/debug나 승인 근거 확인이 필요할 때만 읽어줘.
harness\rules\workflow.md:34:Human-facing artifacts include `gate-ledger.md`, planning artifacts, `archive-summary.md`, `verification.md`, and `handoff.md`.
harness\rules\workflow.md:36:gate-ledger.md, planning artifacts, archive-summary.md, verification.md, and handoff.md are human-facing.
harness\rules\workflow.md:44:Machine-readable artifacts include `events.jsonl`, `task.yaml`, contracts, and PermissionDecision outputs. events.jsonl, task.yaml, contracts, and PermissionDecision outputs keep stable machine-readable keys.
harness\rules\workflow.md:48:`events.jsonl` is the cold canonical log.
harness\rules\workflow.md:50:Do not read full `events.jsonl` for ordinary orientation, startup, handoff continuation, or grill question context.
harness\rules\workflow.md:60:Read `events.jsonl` only for verify/doctor/debug, PermissionDecision, approval proof, event repair, archive/audit work, or an explicit gate requirement for canonical event evidence.
harness\rules\workflow.md:62:`gate-ledger.md` is human-facing and optional for orientation. It is not authority and should not be used as a substitute for canonical event proof.
harness\rules\workflow.md:156:Read receipts are recorded as `artifact_read` events in `events.jsonl`.
harness\rules\workflow.md:242:events.jsonl
harness\rules\workflow.md:245:`gate-ledger.md` is only a human-readable projection.
harness\rules\workflow.md:249:If projections disagree with `events.jsonl`, verification fails and `events.jsonl` wins.
harness\rules\workflow.md:271:Task type must be explicit in `task.yaml` and `events.jsonl`.
harness\contracts\task.schema.yaml:4:canonical_event_log: events.jsonl
harness\contracts\task.schema.yaml:5:human_projection: gate-ledger.md
tests\contracts\test-permission-decision.ps1:33:  Set-Content -LiteralPath (Join-Path $dir 'events.jsonl') -Value $jsonl -Encoding UTF8
tests\contracts\test-permission-decision.ps1:48:    event_type = 'approval_decision'
tests\contracts\test-permission-decision.ps1:52:    event_hash = $EventId
tests\contracts\test-permission-decision.ps1:78:    event_hash = "hash-$GateId-$Status"
tests\contracts\test-permission-decision.ps1:97:    event_hash = "hash-invalidates-$ApprovalEventId"
tests\contracts\test-permission-decision.ps1:119:      '--events', (Join-Path $taskDir 'events.jsonl'),
harness\state\planning.md:15:Task-specific gate approvals belong in `harness/docs/tasks/active/<slug>/events.jsonl`.
harness\state\planning.md:17:`gate-ledger.md` is a human-readable projection.
tests\contracts\test-verify-doctor.ps1:81:    event_hash = $EventHash
tests\contracts\test-verify-doctor.ps1:147:  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
tests\contracts\test-verify-doctor.ps1:166:  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
tests\contracts\test-verify-doctor.ps1:169:  Assert-Check (@($result.failures | Where-Object { $_.id -eq 'artifact_read_receipt_missing' }).Count -ge 3) 'writing_plan should report missing PRD, issues, and module structure receipts.'
tests\contracts\test-verify-doctor.ps1:200:  $eventsPath = Join-Path $taskDir 'events.jsonl'
tests\contracts\test-verify-doctor.ps1:202:    (New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'artifact_read' -PreviousHash '' -EventHash 'h1' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_current_context'; path = $contextRel; hash = (Get-TestFileSha256 -Path $contextPath); proof_type = 'file_sha256' }),
tests\contracts\test-verify-doctor.ps1:203:    (New-Event -TaskId 'task-one' -EventId 'evt-2' -EventType 'artifact_read' -PreviousHash 'h1' -EventHash 'h2' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_prd'; path = $prdRel; hash = (Get-TestFileSha256 -Path $prdPath); proof_type = 'file_sha256' }),
tests\contracts\test-verify-doctor.ps1:204:    (New-Event -TaskId 'task-one' -EventId 'evt-3' -EventType 'artifact_read' -PreviousHash 'h2' -EventHash 'h3' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_issues'; path = $issuesRel; hash = (Get-TestFileSha256 -Path $issuesPath); proof_type = 'file_sha256' }),
tests\contracts\test-verify-doctor.ps1:205:    (New-Event -TaskId 'task-one' -EventId 'evt-4' -EventType 'artifact_read' -PreviousHash 'h3' -EventHash 'h4' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_module_structure'; path = $moduleRel; hash = (Get-TestFileSha256 -Path $modulePath); proof_type = 'file_sha256' }),
tests\contracts\test-verify-doctor.ps1:206:    (New-Event -TaskId 'task-one' -EventId 'evt-5' -EventType 'artifact_written' -PreviousHash 'h4' -EventHash 'h5' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_writing_plan'; path = $writingRel; hash = (Get-TestFileSha256 -Path $writingPath) })
tests\contracts\test-verify-doctor.ps1:226:  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
tests\contracts\test-verify-doctor.ps1:229:  Assert-Check (@($result.failures | Where-Object { $_.id -eq 'artifact_read_receipt_missing' }).Count -ge 2) 'compound_lookup should report missing compound receipts.'
tests\contracts\test-verify-doctor.ps1:245:  $eventsPath = Join-Path $taskDir 'events.jsonl'
tests\contracts\test-verify-doctor.ps1:247:    (New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'artifact_written' -PreviousHash '' -EventHash 'h1' -Payload @{ path = 'harness/docs/solutions/harness-drift-patterns.md' })
tests\contracts\test-verify-doctor.ps1:273:  Set-Content -LiteralPath (Join-Path $taskDir 'events.jsonl') -Value '' -Encoding UTF8
tests\contracts\test-verify-doctor.ps1:294:    (New-Event -TaskId 'other-task' -EventId 'evt-1' -EventType 'artifact_read' -PreviousHash '' -EventHash 'h1' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_prd'; path = 'harness/docs/tasks/active/task-one/planning/03-prd.md'; hash = 'sha256:fake'; proof_type = 'file_sha256' })
tests\contracts\test-verify-doctor.ps1:296:  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
tests\contracts\test-verify-doctor.ps1:298:  Assert-Check ($result.ok -eq $false) 'artifact_read from a different task_id must not satisfy required reads.'
tests\contracts\test-verify-doctor.ps1:316:    (New-Event -TaskId 'task-one' -EventId 'evt-1' -EventType 'artifact_read' -PreviousHash '' -EventHash 'h1' -Payload @{ gate_id = 'writing_plan'; artifact_id = 'planning_prd'; path = 'harness/docs/tasks/active/task-one/planning/03-prd.md'; hash = 'sha256:stale'; proof_type = 'file_sha256' })
tests\contracts\test-verify-doctor.ps1:318:  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
tests\contracts\test-verify-doctor.ps1:320:  Assert-Check ($result.ok -eq $false) 'stale artifact_read hash must not satisfy required reads.'
tests\contracts\test-verify-doctor.ps1:338:    (New-Event -TaskId 'task-one' -EventId 'evt-2' -EventType 'artifact_written' -PreviousHash 'h1' -EventHash 'h2' -Payload @{ gate_id = 'compound_review'; artifact_id = 'selected_relevant_solutions'; path = 'harness/docs/solutions/harness-drift-patterns.md'; hash = 'sha256:dummy'; candidate_ref = 'cand-1' })
tests\contracts\test-verify-doctor.ps1:340:  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
tests\contracts\test-verify-doctor.ps1:360:    (New-Event -TaskId 'task-one' -EventId 'evt-2' -EventType 'artifact_written' -PreviousHash 'h1' -EventHash 'h2' -Payload @{ gate_id = 'compound_review'; artifact_id = 'selected_relevant_solutions'; path = 'harness/docs/solutions/harness-drift-patterns.md'; hash = 'sha256:dummy'; candidate_ref = 'cand-2' })
tests\contracts\test-verify-doctor.ps1:362:  Write-Events -Path (Join-Path $taskDir 'events.jsonl') -Events $events
tests\contracts\test-verify-doctor.ps1:364:  Assert-Check ($result.ok -eq $false) 'solution write must fail when compound_review candidate_ref does not match artifact_written candidate_ref.'
tests\contracts\test-workflow-rules.ps1:30:  'events.jsonl',
tests\contracts\test-workflow-rules.ps1:31:  'gate-ledger.md',
tests\contracts\test-workflow-rules.ps1:35:  'events.jsonl, task.yaml, contracts, and PermissionDecision outputs keep stable machine-readable keys',
tests\contracts\test-workflow-rules.ps1:36:  'gate-ledger.md, planning artifacts, archive-summary.md, verification.md, and handoff.md are human-facing',
tests\contracts\test-workflow-rules.ps1:60:  'active task events.jsonl',
tests\contracts\test-workflow-rules.ps1:68:  '`events.jsonl` is a cold canonical log',
tests\contracts\test-workflow-rules.ps1:72:  'events.jsonl, task.yaml, contracts, and PermissionDecision outputs keep stable machine-readable keys',
tests\contracts\test-workflow-rules.ps1:73:  'gate-ledger.md, planning artifacts, archive-summary.md, verification.md, and handoff.md are human-facing',
tests\contracts\test-workflow-rules.ps1:80:  'events.jsonl은 verify/doctor/debug나 승인 근거 확인이 필요할 때만 읽어줘',
tests\contracts\test-workflow-rules.ps1:88:  'Record `artifact_read` events for required artifact reads',
tests\contracts\test-workflow-rules.ps1:105:  Assert-Check (-not $rulesRequiredReads.Contains('active task events.jsonl')) 'rules.md Required Reads must not hot-load active task events.jsonl.'
tests\contracts\test-workflow-rules.ps1:109:Assert-Check ($workflow.Contains('Do not read full `events.jsonl` for ordinary orientation')) 'workflow.md must mark events.jsonl as cold context.'
tests\contracts\verify-coverage-map.yaml:71:      - artifact_read_receipts
harness\templates\task\events.jsonl.template:1:{"event_type":"template_only","note":"Do not copy this line into a live task. A live events.jsonl starts empty and is append-only."}
harness\templates\task\gate-ledger.md:8:events.jsonl
harness\templates\task\gate-ledger.md:11:이 파일만 보고 권한을 판단하지 마세요. 실제 권한 판단은 `events.jsonl`, contracts, PermissionDecision을 기준으로 합니다.
harness\templates\task\implementation-approval.md:5:실제 승인 근거는 반드시 `events.jsonl`에 있어야 합니다.
harness\templates\task\task.yaml:5:canonical_event_log: events.jsonl
harness\templates\task\task.yaml:6:human_projection: gate-ledger.md
