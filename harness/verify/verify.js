#!/usr/bin/env node
'use strict';

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
  'harness/contracts/ledger-event.schema.yaml',
  'harness/contracts/permission-decision.schema.yaml',
  'harness/contracts/path-policy.schema.yaml',
  'harness/contracts/task.schema.yaml',
  'harness/contracts/installer-contract.yaml',
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
