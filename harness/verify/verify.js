#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

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
  'harness/contracts/ledger-event.schema.yaml',
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

function readJsonl(filePath, failures) {
  if (!fs.existsSync(filePath)) return [];
  const lines = readText(filePath).split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
  const events = [];
  lines.forEach((line, index) => {
    try {
      events.push(JSON.parse(line));
    } catch (error) {
      failures.push({
        id: 'invalid_jsonl',
        severity: 'P0',
        message: `Invalid JSONL in ${filePath}:${index + 1}: ${error.message}`,
      });
    }
  });
  return events;
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

function parseContractSections(text, sectionName) {
  const result = {};
  const lines = text.split(/\r?\n/);
  let inSection = false;
  let currentKey = null;
  let currentList = null;

  for (let index = 0; index < lines.length; index += 1) {
    const rawLine = lines[index];
    const withoutComment = rawLine.replace(/\s+#.*$/, '');
    if (!withoutComment.trim()) continue;
    const indent = withoutComment.match(/^\s*/)[0].length;
    const trimmed = withoutComment.trim();

    if (indent === 0 && trimmed === `${sectionName}:`) {
      inSection = true;
      currentKey = null;
      currentList = null;
      continue;
    }

    if (inSection && indent === 0 && trimmed.endsWith(':')) {
      break;
    }

    if (!inSection) continue;

    if (indent === 2 && /^[-A-Za-z0-9_]+:$/.test(trimmed)) {
      currentKey = trimmed.slice(0, -1);
      result[currentKey] = {};
      currentList = null;
      continue;
    }

    if (!currentKey) {
      throw new Error(`Unsupported ${sectionName} contract shape at line ${index + 1}: ${rawLine}`);
    }

    if (indent === 4 && /^[-A-Za-z0-9_]+:$/.test(trimmed)) {
      currentList = trimmed.slice(0, -1);
      result[currentKey][currentList] = [];
      continue;
    }

    if (indent === 4 && /^[-A-Za-z0-9_]+:\s+/.test(trimmed)) {
      const [key, ...rest] = trimmed.split(':');
      result[currentKey][key] = rest.join(':').trim().replace(/^["']|["']$/g, '');
      currentList = null;
      continue;
    }

    if (indent === 6 && trimmed.startsWith('- ')) {
      if (!currentList || !Array.isArray(result[currentKey][currentList])) {
        throw new Error(`List item without list owner at line ${index + 1}: ${rawLine}`);
      }
      result[currentKey][currentList].push(trimmed.slice(2).trim().replace(/^["']|["']$/g, ''));
      continue;
    }

    throw new Error(`Unsupported ${sectionName} contract shape at line ${index + 1}: ${rawLine}`);
  }

  return result;
}

function readArtifactRegistry(root) {
  return parseContractSections(readText(path.join(root, 'harness', 'contracts', 'artifact-registry.yaml')), 'artifacts');
}

function readSkillArtifactMap(root) {
  return parseContractSections(readText(path.join(root, 'harness', 'contracts', 'skill-artifact-map.yaml')), 'gates');
}

function currentGateFromTaskYaml(taskYaml) {
  return yamlScalar(taskYaml, 'current_gate');
}

function normalizeEventPath(value) {
  return String(value || '').replace(/\\/g, '/');
}

function artifactRelativePathFor(taskName, artifact) {
  if (!artifact || !artifact.path) return null;
  if (artifact.path.startsWith('chat:') || artifact.path.startsWith('project_source:')) return artifact.path;
  if (artifact.root_relative === 'true' || artifact.root_relative === true) {
    return normalizeEventPath(artifact.path);
  }
  return normalizeEventPath(path.join('harness', 'docs', 'tasks', 'active', taskName, artifact.path));
}

function artifactAbsolutePathFor(root, taskName, artifact) {
  const relativePath = artifactRelativePathFor(taskName, artifact);
  if (!relativePath || relativePath.startsWith('chat:') || relativePath.startsWith('project_source:')) return relativePath;
  return path.join(root, ...relativePath.split('/'));
}

function sha256File(filePath) {
  return `sha256:${crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex')}`;
}

function artifactReadReceipt(events, taskName, gateId, artifactId, artifact, expectedRelativePath, expectedAbsolutePath) {
  return events.find((event) => {
    const payload = event.payload || {};
    if (event.task_id !== taskName) return false;
    if (event.event_type !== 'artifact_read') return false;
    if (payload.gate_id !== gateId || payload.artifact_id !== artifactId) return false;
    if (normalizeEventPath(payload.path) !== expectedRelativePath) return false;
    if (artifact.path.startsWith('chat:') || artifact.path.startsWith('project_source:')) {
      return payload.proof_type === 'pseudo_artifact_marker' && typeof payload.hash === 'string' && payload.hash.length > 0;
    }
    if (payload.proof_type !== 'file_sha256' || !fs.existsSync(expectedAbsolutePath)) return false;
    return payload.hash === sha256File(expectedAbsolutePath);
  });
}

function artifactWrittenEvent(events, taskName, gateId, artifactId, artifact, expectedRelativePath, expectedAbsolutePath) {
  if (['events_log', 'active_task_events', 'task_yaml'].includes(artifactId)) {
    return expectedAbsolutePath && fs.existsSync(expectedAbsolutePath);
  }
  return events.find((event) => {
    const payload = event.payload || {};
    if (event.task_id !== taskName) return false;
    if (event.event_type !== 'artifact_written') return false;
    if (payload.gate_id !== gateId || payload.artifact_id !== artifactId) return false;
    if (normalizeEventPath(payload.path) !== expectedRelativePath) return false;
    if (artifact.path.startsWith('chat:') || artifact.path.startsWith('project_source:')) {
      return typeof payload.hash === 'string' && payload.hash.length > 0;
    }
    if (!fs.existsSync(expectedAbsolutePath)) return false;
    return payload.hash === sha256File(expectedAbsolutePath);
  });
}

function eventWritesSolution(event) {
  const payload = event.payload || {};
  const writtenPath = String(payload.path || payload.target_path || '');
  return event.event_type === 'artifact_written'
    && /^harness[\\/]docs[\\/]solutions[\\/].+\.md$/i.test(writtenPath);
}

function solutionWritePath(event) {
  const payload = event.payload || {};
  return String(payload.path || payload.target_path || '').replace(/\\/g, '/');
}

function solutionWriteCandidateRef(event) {
  const payload = event.payload || {};
  return String(payload.candidate_ref || '');
}

function hasMatchingCompoundReviewDecision(events, writeIndex, writePath, candidateRef) {
  return events.slice(0, writeIndex).some((event) => {
    const payload = event.payload || {};
    return event.event_type === 'compound_review_decision'
      && ['promote', 'merge_existing'].includes(payload.decision)
      && typeof candidateRef === 'string'
      && candidateRef.length > 0
      && payload.candidate_ref === candidateRef
      && typeof payload.user_approval_event_id === 'string'
      && payload.user_approval_event_id.length > 0
      && String(payload.target_solution_path || '').replace(/\\/g, '/') === writePath;
  });
}

function learningCaptureCandidateCount(text) {
  const match = text.match(/^candidate_count:\s*(\d+)\s*$/m);
  return match ? Number(match[1]) : null;
}

function verifyEventHashChain(events, taskName, failures) {
  for (let i = 0; i < events.length; i += 1) {
    const event = events[i];
    if (!event.event_id || !event.event_type || !event.event_hash) {
      failures.push({
        id: 'event_required_fields',
        severity: 'P0',
        message: `Task ${taskName} has an event missing event_id/event_type/event_hash.`,
      });
    }
    if (i > 0 && event.previous_hash !== events[i - 1].event_hash) {
      failures.push({
        id: 'event_hash_chain_broken',
        severity: 'P0',
        message: `Task ${taskName} has broken event hash chain at event ${event.event_id || i}.`,
      });
    }
  }
}

function verifyArtifactRoutingForTask(root, taskName, taskYaml, events, failures, warnings) {
  const registryPath = path.join(root, 'harness', 'contracts', 'artifact-registry.yaml');
  const mapPath = path.join(root, 'harness', 'contracts', 'skill-artifact-map.yaml');
  if (!fs.existsSync(registryPath) || !fs.existsSync(mapPath)) {
    failures.push({
      id: 'missing_contract',
      severity: 'P0',
      message: 'Missing artifact routing contract file.',
    });
    return;
  }

  let registry;
  let gates;
  try {
    registry = readArtifactRegistry(root);
    gates = readSkillArtifactMap(root);
  } catch (error) {
    failures.push({
      id: 'artifact_contract_parse_failed',
      severity: 'P0',
      message: `Artifact routing contract parse failed: ${error.message}`,
    });
    return;
  }

  const gateId = currentGateFromTaskYaml(taskYaml);
  if (!gateId) return;
  if (!gates[gateId]) {
    failures.push({
      id: 'artifact_gate_unknown',
      severity: 'P0',
      message: `Task ${taskName} has current_gate ${gateId}, but skill-artifact-map.yaml does not define it.`,
    });
    return;
  }

  const gate = gates[gateId];
  const requiredReads = Array.isArray(gate.must_read) ? gate.must_read : [];
  const requiredWrites = Array.isArray(gate.must_write) ? gate.must_write : [];
  const forbiddenReads = Array.isArray(gate.must_not_read) ? gate.must_not_read : [];

  for (const artifactId of [...requiredReads, ...requiredWrites, ...forbiddenReads]) {
    if (!registry[artifactId]) {
      failures.push({
        id: 'artifact_contract_unknown_artifact',
        severity: 'P0',
        message: `Gate ${gateId} references unknown artifact id ${artifactId}.`,
      });
    }
  }

  for (const artifactId of requiredReads) {
    const artifact = registry[artifactId];
    if (!artifact) continue;
    if (artifact.read_receipt_required === 'false' || artifact.read_receipt_required === false) continue;
    const expectedRelativePath = artifactRelativePathFor(taskName, artifact);
    const expectedAbsolutePath = artifactAbsolutePathFor(root, taskName, artifact);
    if (!artifactReadReceipt(events, taskName, gateId, artifactId, artifact, expectedRelativePath, expectedAbsolutePath)) {
      failures.push({
        id: 'artifact_read_receipt_missing',
        severity: ['writing_plan', 'compound_lookup', 'implementation'].includes(gateId) ? 'P0' : 'P1',
        message: `Task ${taskName} gate ${gateId} is missing a valid artifact_read receipt for ${artifactId}.`,
      });
    }
  }

  for (const artifactId of forbiddenReads) {
    const forbiddenRead = events.some((event) => {
      const payload = event.payload || {};
      return event.task_id === taskName
        && event.event_type === 'artifact_read'
        && payload.gate_id === gateId
        && payload.artifact_id === artifactId;
    });
    if (forbiddenRead) {
      failures.push({
        id: 'artifact_forbidden_read',
        severity: 'P0',
        message: `Task ${taskName} gate ${gateId} read forbidden artifact ${artifactId}.`,
      });
    }
  }

  for (const artifactId of requiredWrites) {
    const artifact = registry[artifactId];
    if (!artifact || artifact.path.startsWith('chat:') || artifact.path.startsWith('project_source:')) continue;
    const expectedRelativePath = artifactRelativePathFor(taskName, artifact);
    const expectedAbsolutePath = artifactAbsolutePathFor(root, taskName, artifact);
    if (!artifactWrittenEvent(events, taskName, gateId, artifactId, artifact, expectedRelativePath, expectedAbsolutePath)) {
      failures.push({
        id: 'artifact_required_write_missing',
        severity: ['compound_capture', 'compound_review', 'verification'].includes(gateId) ? 'P0' : 'P1',
        message: `Task ${taskName} gate ${gateId} is missing a valid artifact_written event for ${artifactId}.`,
      });
    }
  }

  if (gateId === 'compound_capture') {
    const learningPath = path.join(root, 'harness', 'docs', 'tasks', 'active', taskName, 'learning-capture.md');
    if (!fs.existsSync(learningPath)) {
      failures.push({
        id: 'learning_capture_missing',
        severity: 'P0',
        message: `Task ${taskName} is at compound_capture but learning-capture.md is missing.`,
      });
    } else {
      const learningText = readText(learningPath);
      const candidateCount = learningCaptureCandidateCount(learningText);
      const learningCandidateEvents = events.filter((event) => event.event_type === 'learning_candidate');
      if (candidateCount === null) {
        failures.push({
          id: 'learning_capture_stale_template',
          severity: 'P0',
          message: `Task ${taskName} learning-capture.md is missing candidate_count metadata.`,
        });
      } else if (candidateCount === 0 && !/^no_candidate_reason:\s*\S+/m.test(learningText)) {
        failures.push({
          id: 'learning_capture_no_candidate_reason_missing',
          severity: 'P0',
          message: `Task ${taskName} learning-capture.md has zero candidates without a no_candidate_reason.`,
        });
      } else if (candidateCount > learningCandidateEvents.length) {
        failures.push({
          id: 'learning_candidate_event_missing',
          severity: 'P0',
          message: `Task ${taskName} learning-capture.md candidate_count exceeds learning_candidate events.`,
        });
      }
    }
  }

  events.forEach((event, index) => {
    if (!eventWritesSolution(event)) return;
    const writePath = solutionWritePath(event);
    const candidateRef = solutionWriteCandidateRef(event);
    if (!hasMatchingCompoundReviewDecision(events, index, writePath, candidateRef)) {
      failures.push({
        id: 'compound_review_required_for_solution_write',
        severity: 'P0',
        message: `Task ${taskName} wrote ${writePath} without a prior matching compound_review decision for candidate ${candidateRef || '(missing)'}.`,
      });
    }
  });

  void warnings;
}

function hasApprovalDecision(events) {
  return events.some((event) => {
    const payload = event.payload || {};
    return event.event_type === 'approval_decision' && payload.status === 'approved';
  });
}

function verifyActiveTasks(root, failures, warnings) {
  const activeDir = path.join(root, 'harness', 'docs', 'tasks', 'active');
  if (!fs.existsSync(activeDir)) return;

  const tasks = listDirectories(activeDir).filter((name) => name !== '.gitkeep');
  if (tasks.length > 1) {
    failures.push({
      id: 'active_task_single_default',
      severity: 'P0',
      message: `Multiple active tasks found without parallel approval: ${tasks.join(', ')}`,
    });
  }

  for (const task of tasks) {
    const taskDir = path.join(activeDir, task);
    const eventsPath = path.join(taskDir, 'events.jsonl');
    const taskYamlPath = path.join(taskDir, 'task.yaml');
    const events = readJsonl(eventsPath, failures);
    verifyEventHashChain(events, task, failures);

    if (fs.existsSync(taskYamlPath)) {
      const taskYaml = readText(taskYamlPath);
      verifyArtifactRoutingForTask(root, task, taskYaml, events, failures, warnings);
      if (/(approved|allowed|permission|capabilit)/i.test(taskYaml) && !hasApprovalDecision(events)) {
        failures.push({
          id: 'projection_without_canonical_event',
          severity: 'P0',
          message: `Task ${task} has task.yaml permission-like state without approval_decision in events.jsonl.`,
        });
      }
    } else {
      warnings.push({
        id: 'active_task_missing_task_yaml',
        severity: 'warning',
        message: `Task ${task} has no task.yaml derived cache.`,
      });
    }
  }
}

function verifyHarnessLock(root, failures) {
  const lockPath = path.join(root, 'harness.lock.yaml');
  const text = readText(lockPath);
  if (!text) return;

  for (const field of REQUIRED_LOCK_FIELDS) {
    if (!text.includes(field)) {
      failures.push({
        id: 'harness_lock_missing_field',
        severity: 'P0',
        message: `harness.lock.yaml missing required field: ${field}`,
      });
    }
  }

  for (const field of ['planning_started', 'github_repo_created', 'commit_created', 'push_performed']) {
    const value = yamlBoolean(text, field);
    if (value !== false) {
      failures.push({
        id: `${field}_during_install`,
        severity: 'P0',
        message: `harness.lock.yaml must record ${field}: false for install-only safety.`,
      });
    }
  }
}

function verifyRoot(root) {
  const projectRoot = path.resolve(root);
  const failures = [];
  const warnings = [];

  for (const item of REQUIRED_ROOT_ITEMS) {
    if (!fs.existsSync(path.join(projectRoot, item))) {
      failures.push({
        id: 'missing_root_item',
        severity: 'P0',
        message: `Missing required root item: ${item}`,
      });
    }
  }

  for (const contract of REQUIRED_CONTRACTS) {
    if (!fs.existsSync(path.join(projectRoot, contract))) {
      failures.push({
        id: 'missing_contract',
        severity: 'P0',
        message: `Missing contract file: ${contract}`,
      });
    }
  }

  for (const nested of ['jjamppong-harness', 'ourosuper-harness']) {
    if (fs.existsSync(path.join(projectRoot, nested, 'AGENTS.md'))) {
      failures.push({
        id: 'nested_harness_folder',
        severity: 'P0',
        message: `Forbidden nested harness folder found: ${nested}/`,
      });
    }
  }

  for (const secretName of ['.env', '.env.local', 'credentials.json', 'service-account.json', 'cookies.txt', 'token.txt']) {
    if (fs.existsSync(path.join(projectRoot, secretName))) {
      failures.push({
        id: 'secret_file_present',
        severity: 'P0',
        message: `Secret-like file present at root and must not be read or published: ${secretName}`,
      });
    }
  }

  verifyHarnessLock(projectRoot, failures);
  verifyActiveTasks(projectRoot, failures, warnings);

  return {
    ok: failures.length === 0,
    root: projectRoot,
    failures,
    warnings,
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const root = args.root || process.cwd();
  const result = verifyRoot(root);
  if (args.json) {
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  } else if (result.ok) {
    process.stdout.write(`verify passed for ${result.root}\n`);
  } else {
    process.stdout.write(`verify failed for ${result.root}\n`);
    for (const failure of result.failures) {
      process.stdout.write(`FAIL ${failure.id}: ${failure.message}\n`);
    }
    for (const warning of result.warnings) {
      process.stdout.write(`WARN ${warning.id}: ${warning.message}\n`);
    }
  }
  process.exitCode = result.ok ? 0 : 1;
}

if (require.main === module) {
  main();
}

module.exports = {
  verifyRoot,
};
