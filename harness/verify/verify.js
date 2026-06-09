#!/usr/bin/env node
'use strict';

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const REQUIRED_ROOT_ITEMS = [
  'AGENTS.md',
  'README.md',
  'CONTEXT.md',
  'handoff.md',
  'harness',
  'modules',
  'module-template',
  'proposals',
  'harness.lock.yaml',
];

const REQUIRED_CONTRACTS = [
  'harness/contracts/capability-catalog.yaml',
  'harness/contracts/gate-contract-matrix.yaml',
  'harness/contracts/permission-decision.schema.yaml',
  'harness/contracts/path-policy.schema.yaml',
  'harness/contracts/task.schema.yaml',
  'harness/contracts/installer-contract.yaml',
  'harness/contracts/artifact-registry.yaml',
  'harness/contracts/skill-artifact-map.yaml',
];

const REQUIRED_LOCK_FIELDS = [
  'planning_started',
  'github_repo_created',
  'commit_created',
  'push_performed',
  'managed_files',
];

const ALLOWED_GATES = new Set([
  'intake',
  'grill',
  'research',
  'compound_lookup',
  'architecture_orientation',
  'prd',
  'issues',
  'module_structure',
  'writing_plan',
  'plan_review',
  'folder_skeleton',
  'implementation',
  'work',
  'verification',
  'acceptance',
  'compound_capture',
  'compound_review',
  'proposal',
  'archive',
  'handoff',
]);

const APPROVAL_HEADINGS = [
  '## 승인 질문',
  '## 사용자 답변 요약',
  '## 허용 작업',
  '## 금지 작업',
  '## 파일 범위',
  '## 테스트 범위',
  '## Capability 허용 여부',
  '## 승인 만료 또는 철회 조건',
];

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith('--')) continue;
    const key = token.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      args[key] = true;
    } else {
      args[key] = next;
      i += 1;
    }
  }
  return args;
}

function readText(filePath) {
  if (!fs.existsSync(filePath)) return '';
  return fs.readFileSync(filePath, 'utf8');
}

function sha256(filePath) {
  return crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex');
}

function yamlScalar(text, key) {
  const escaped = key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const match = text.match(new RegExp(`^\\s*${escaped}:\\s*(.+?)\\s*$`, 'm'));
  return match ? match[1].replace(/^["']|["']$/g, '') : null;
}

function yamlBoolean(text, key) {
  const value = yamlScalar(text, key);
  if (value === null) return null;
  if (/^true$/i.test(value)) return true;
  if (/^false$/i.test(value)) return false;
  return value;
}

function listDirectories(dirPath) {
  if (!fs.existsSync(dirPath)) return [];
  return fs.readdirSync(dirPath, { withFileTypes: true }).filter((entry) => entry.isDirectory()).map((entry) => entry.name);
}

function listFilesRecursive(dirPath) {
  if (!fs.existsSync(dirPath)) return [];
  const stat = fs.statSync(dirPath);
  if (stat.isFile()) return [dirPath];
  if (!stat.isDirectory()) return [];
  const files = [];
  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    const child = path.join(dirPath, entry.name);
    if (entry.isDirectory()) files.push(...listFilesRecursive(child));
    if (entry.isFile()) files.push(child);
  }
  return files;
}

function repoRelative(root, filePath) {
  return path.relative(root, filePath).replace(/\\/g, '/');
}

function parseManagedFiles(lockText) {
  const result = new Map();
  const blocks = lockText.split(/\n(?=\s{2}- path: )/);
  for (const block of blocks) {
    const pathMatch = block.match(/^\s{2}- path:\s*(.+?)\s*$/m);
    const shaMatch = block.match(/^\s{4}sha256:\s*([a-f0-9]+)\s*$/m);
    if (!pathMatch || !shaMatch) continue;
    result.set(pathMatch[1].trim().replace(/\\/g, '/'), shaMatch[1].trim());
  }
  return result;
}

function pushIssue(list, id, severity, message) {
  list.push({ id, severity, message });
}

function hasSubstantiveContent(text) {
  const lines = text.split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
  const meaningful = lines.filter((line) => !line.startsWith('#') && !/^[-*]\s*$/.test(line));
  return meaningful.join('\n').replace(/[-|:`\s]/g, '').length >= 12;
}

function hasRequirementBullet(text) {
  return /^[-*]\s+\S+/m.test(text) || /\b(requirement|요구|필수|해야|한다)\b/i.test(text);
}

function hasIssueItem(text) {
  return /^[-*]\s+\S+/m.test(text) || /\b(issue|작업|이슈|task)\b/i.test(text);
}

function hasModuleDecision(text) {
  return /modules[\\/A-Za-z0-9_-]*|no module yet|모듈 없음|모듈 구조/m.test(text);
}

function hasWritingPlanSteps(text) {
  return /^-\s+\[[ xX]\]\s+\S+/m.test(text);
}

function hasPlanReviewDecision(text) {
  return /no blocking issues|blocking|decision|리뷰|차단|문제 없음|반영/m.test(text);
}

function hasVerificationResult(text) {
  return /명령|command/i.test(text)
    && /기대|expected/i.test(text)
    && /실제|actual/i.test(text)
    && /통과|status|pass|fail/i.test(text);
}

function hasHandoffPrompt(text) {
  return /handoff\.md|다음 채팅|이어.*진행|next-chat/i.test(text);
}

function verifyRequiredArtifact(taskRoot, relativePath, checker, failures, message) {
  const fullPath = path.join(taskRoot, relativePath);
  if (!fs.existsSync(fullPath)) {
    pushIssue(failures, 'gate_required_artifact_missing', 'P0', `${message}: missing ${relativePath}`);
    return;
  }
  const text = readText(fullPath);
  if (!hasSubstantiveContent(text) || (checker && !checker(text))) {
    pushIssue(failures, 'gate_artifact_content_insufficient', 'P0', `${message}: insufficient ${relativePath}`);
  }
}

function verifyImplementationApproval(taskRoot, failures) {
  const approvalPath = path.join(taskRoot, 'implementation-approval.md');
  if (!fs.existsSync(approvalPath)) {
    pushIssue(failures, 'implementation_approval_missing', 'P0', 'implementation gate requires implementation-approval.md.');
    return;
  }
  const text = readText(approvalPath);
  const missing = APPROVAL_HEADINGS.filter((heading) => !text.includes(heading));
  if (missing.length > 0 || !/file\.|git\.|package\.|network\.|허용|금지/.test(text)) {
    pushIssue(failures, 'gate_artifact_content_insufficient', 'P0', 'implementation-approval.md is missing required headings or capability scope.');
  }
}

function verifyCurrentGateArtifacts(root, taskName, taskRoot, taskYaml, failures) {
  const gate = yamlScalar(taskYaml, 'current_gate');
  if (!gate) return;
  if (!ALLOWED_GATES.has(gate)) {
    pushIssue(failures, 'task_gate_unknown', 'P0', `Task ${taskName} has unknown current_gate: ${gate}.`);
    return;
  }

  if (gate === 'writing_plan') {
    verifyRequiredArtifact(taskRoot, 'planning/03-prd.md', hasRequirementBullet, failures, 'writing_plan gate requires PRD');
    verifyRequiredArtifact(taskRoot, 'planning/04-issues.md', hasIssueItem, failures, 'writing_plan gate requires issues');
    verifyRequiredArtifact(taskRoot, 'planning/05-module-structure.md', hasModuleDecision, failures, 'writing_plan gate requires module structure');
    verifyRequiredArtifact(taskRoot, 'planning/06-writing-plan.md', hasWritingPlanSteps, failures, 'writing_plan gate requires writing plan');
  }

  if (gate === 'implementation' || gate === 'work') {
    verifyImplementationApproval(taskRoot, failures);
  }

  if (gate === 'plan_review') {
    verifyRequiredArtifact(taskRoot, 'planning/07-plan-review.md', hasPlanReviewDecision, failures, 'plan_review gate requires plan review');
  }

  if (gate === 'verification') {
    verifyRequiredArtifact(taskRoot, 'verification.md', hasVerificationResult, failures, 'verification gate requires verification result');
  }

  if (gate === 'handoff') {
    verifyRequiredArtifact(path.resolve(root), 'handoff.md', hasHandoffPrompt, failures, 'handoff gate requires next-chat prompt');
  }
}

function verifyHotContext(root, taskRoot, failures, warnings) {
  const files = [
    path.join(root, 'AGENTS.md'),
    path.join(root, 'harness', 'rules', 'workflow.md'),
    path.join(taskRoot, 'task.yaml'),
    path.join(taskRoot, 'planning', '00-current-planning-context.md'),
  ];
  const totalBytes = files.reduce((sum, filePath) => sum + Buffer.byteLength(readText(filePath), 'utf8'), 0);
  if (totalBytes > 24 * 1024) {
    pushIssue(failures, 'hot_context_too_large', 'P0', `Hot context is ${totalBytes} bytes, above 24KB hard limit.`);
  } else if (totalBytes > 12 * 1024) {
    pushIssue(warnings, 'hot_context_large_warning', 'P1', `Hot context is ${totalBytes} bytes, above 12KB warning limit.`);
  }
}

function compoundReviewPromotes(taskRoot) {
  const review = readText(path.join(taskRoot, 'compound-review.md'));
  return review.includes('결정: promote')
    && review.includes('반영할 장기 문서:')
    && review.includes('사용자 승인 근거:');
}

function verifySolutionWrites(root, taskRoot, taskYaml, failures) {
  const gate = yamlScalar(taskYaml, 'current_gate');
  if (!['compound_capture', 'compound_review'].includes(gate)) return;

  const lockText = readText(path.join(root, 'harness.lock.yaml'));
  const managed = parseManagedFiles(lockText);
  const solutionRoot = path.join(root, 'harness', 'docs', 'solutions');
  const changed = listFilesRecursive(solutionRoot)
    .filter((filePath) => filePath.endsWith('.md'))
    .filter((filePath) => {
      const relative = repoRelative(root, filePath);
      const knownHash = managed.get(relative);
      return !knownHash || knownHash !== sha256(filePath);
    });

  if (changed.length > 0 && !compoundReviewPromotes(taskRoot)) {
    pushIssue(
      failures,
      'compound_review_required_for_solution_write',
      'P0',
      `Long-term solution writes require compound-review.md promote decision: ${changed.map((filePath) => repoRelative(root, filePath)).join(', ')}`
    );
  }
}

function verifyLiveCoreLedgerReferences(root, failures) {
  for (const relative of [
    'harness/contracts/ledger-event.schema.yaml',
    'harness/templates/task/events.jsonl.template',
    'harness/templates/task/gate-ledger.md',
  ]) {
    if (fs.existsSync(path.join(root, relative))) {
      pushIssue(failures, 'ledger_reference_in_live_core', 'P0', `Live core must not include legacy ledger file: ${relative}`);
    }
  }

  const rulesText = [
    readText(path.join(root, 'AGENTS.md')),
    readText(path.join(root, 'harness', 'rules', 'workflow.md')),
    readText(path.join(root, 'harness', 'rules', 'rules.md')),
  ].join('\n');
  if (/events\.jsonl.*(required|canonical|source of truth|승인 기록 원본)|canonical.*events\.jsonl/i.test(rulesText)) {
    pushIssue(failures, 'ledger_reference_in_live_core', 'P0', 'Live rules still describe events.jsonl as required or canonical.');
  }
}

function verifyActiveTasks(root, failures, warnings) {
  const activeDir = path.join(root, 'harness', 'docs', 'tasks', 'active');
  if (!fs.existsSync(activeDir)) return;

  const tasks = listDirectories(activeDir);
  if (tasks.length > 1) {
    pushIssue(failures, 'active_task_single_default', 'P0', `Expected at most one active task, found ${tasks.length}: ${tasks.join(', ')}`);
  }

  for (const taskName of tasks) {
    const taskRoot = path.join(activeDir, taskName);
    const taskYamlPath = path.join(taskRoot, 'task.yaml');
    const taskYaml = readText(taskYamlPath);
    if (!taskYaml) {
      pushIssue(failures, 'task_yaml_missing', 'P0', `Active task ${taskName} is missing task.yaml.`);
      continue;
    }

    for (const legacy of ['events.jsonl', 'gate-ledger.md']) {
      if (fs.existsSync(path.join(taskRoot, legacy))) {
        pushIssue(warnings, 'legacy_ledger_artifact_present', 'P1', `Task ${taskName} has legacy ${legacy}; do not hot-read it.`);
      }
    }

    verifyCurrentGateArtifacts(root, taskName, taskRoot, taskYaml, failures);
    verifyHotContext(root, taskRoot, failures, warnings);
    verifySolutionWrites(root, taskRoot, taskYaml, failures);
  }
}

function verifyRoot(rootPath) {
  const root = path.resolve(rootPath || process.cwd());
  const failures = [];
  const warnings = [];

  for (const item of REQUIRED_ROOT_ITEMS) {
    if (!fs.existsSync(path.join(root, item))) {
      pushIssue(failures, 'missing_root_item', 'P0', `Missing required root item: ${item}`);
    }
  }

  for (const contract of REQUIRED_CONTRACTS) {
    if (!fs.existsSync(path.join(root, contract))) {
      pushIssue(failures, 'missing_contract', 'P0', `Missing contract file: ${contract}`);
    }
  }

  for (const nested of ['jjamppong-harness', 'ourosuper-harness']) {
    if (fs.existsSync(path.join(root, nested, 'AGENTS.md'))) {
      pushIssue(failures, 'nested_harness_folder', 'P0', `Forbidden nested harness folder present: ${nested}/`);
    }
  }

  const lockText = readText(path.join(root, 'harness.lock.yaml'));
  for (const field of REQUIRED_LOCK_FIELDS) {
    if (!lockText.includes(field)) {
      pushIssue(failures, 'harness_lock_missing_field', 'P0', `harness.lock.yaml missing field: ${field}`);
    }
  }
  if (yamlBoolean(lockText, 'planning_started') === true) {
    pushIssue(failures, 'planning_started_during_install', 'P0', 'Installer must not start planning.');
  }
  if (yamlBoolean(lockText, 'github_repo_created') === true) {
    pushIssue(failures, 'github_repo_created_during_install', 'P0', 'Installer must not create GitHub repos by default.');
  }
  if (yamlBoolean(lockText, 'commit_created') === true) {
    pushIssue(failures, 'commit_created_during_install', 'P0', 'Installer must not commit by default.');
  }
  if (yamlBoolean(lockText, 'push_performed') === true) {
    pushIssue(failures, 'push_performed_during_install', 'P0', 'Installer must not push by default.');
  }

  verifyLiveCoreLedgerReferences(root, failures);
  verifyActiveTasks(root, failures, warnings);

  return {
    ok: failures.length === 0,
    root,
    failures,
    warnings,
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const root = path.resolve(args.root || process.cwd());
  const result = verifyRoot(root);
  if (args.json) {
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  } else if (result.ok) {
    process.stdout.write(`verify passed for ${result.root}\n`);
  } else {
    process.stdout.write(`verify failed for ${result.root}\n`);
    for (const failure of result.failures) {
      process.stdout.write(`- ${failure.id}: ${failure.message}\n`);
    }
  }
  process.exitCode = result.ok ? 0 : 1;
}

if (require.main === module) {
  main();
}

module.exports = {
  verifyRoot,
  yamlScalar,
  parseManagedFiles,
};
