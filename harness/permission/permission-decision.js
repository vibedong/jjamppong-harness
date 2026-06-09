#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const READ_ALLOWED_GATES = new Set([
  'research',
  'compound_lookup',
  'architecture_orientation',
  'prd',
  'issues',
  'module_structure',
  'writing_plan',
  'plan_review',
  'implementation',
  'work',
  'verification',
  'acceptance',
  'compound_capture',
  'compound_review',
  'archive',
  'handoff',
]);

const DANGEROUS_CAPABILITIES = new Set([
  'file.write.module',
  'file.write.outside_modules',
  'file.write.harness_core',
  'package.install',
  'network.live_target',
  'git.commit',
  'git.push',
  'parallel.write',
]);

const BOOLEAN_CAPABILITY_FIELDS = {
  'package.install': 'package_install',
  'network.live_target': 'network_live_target',
  'git.commit': 'git_commit',
  'git.push': 'git_push',
};

const SECRET_PATTERNS = [
  /(^|[\\/])\.env(\.|$|[\\/])/i,
  /(^|[\\/])credentials\.json$/i,
  /(^|[\\/])service-account\.json$/i,
  /(^|[\\/])cookies\.txt$/i,
  /(^|[\\/])token\.txt$/i,
  /private[-_ ]?key/i,
];

const EXECUTABLE_SKELETON_EXTENSIONS = new Set([
  '.js', '.jsx', '.ts', '.tsx', '.mjs', '.cjs',
  '.py', '.rb', '.go', '.rs', '.java', '.cs',
  '.ps1', '.sh', '.bat', '.cmd',
  '.json', '.toml', '.yaml', '.yml',
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

function normalizeWindowsDriveShorthand(rawPath) {
  if (/^[A-Za-z]:[^\\/]/.test(rawPath)) {
    return `${rawPath.slice(0, 2)}${path.sep}${rawPath.slice(2)}`;
  }
  return rawPath;
}

function normalizeForCompare(value) {
  return value.replace(/[\\/]+/g, path.sep).toLowerCase();
}

function readTextIfExists(filePath) {
  if (!filePath || !fs.existsSync(filePath)) return '';
  return fs.readFileSync(filePath, 'utf8');
}

function parseScalar(value) {
  const trimmed = String(value || '').trim().replace(/^["']|["']$/g, '');
  if (/^true$/i.test(trimmed)) return true;
  if (/^false$/i.test(trimmed)) return false;
  if (trimmed === '[]') return [];
  return trimmed;
}

function parseTaskYaml(text) {
  const task = { approval_summary: {} };
  const lines = text.split(/\r?\n/);
  let section = null;
  let listKey = null;

  for (const rawLine of lines) {
    const line = rawLine.replace(/\s+#.*$/, '');
    if (!line.trim()) continue;

    const top = line.match(/^([A-Za-z0-9_.-]+):\s*(.*?)\s*$/);
    if (top) {
      section = top[1] === 'approval_summary' ? 'approval_summary' : null;
      listKey = null;
      if (top[1] !== 'approval_summary') {
        task[top[1]] = parseScalar(top[2]);
      }
      continue;
    }

    if (section === 'approval_summary') {
      const nested = line.match(/^\s{2}([A-Za-z0-9_.-]+):\s*(.*?)\s*$/);
      if (nested) {
        const key = nested[1];
        const value = nested[2].trim() === '' ? [] : parseScalar(nested[2]);
        task.approval_summary[key] = value;
        listKey = Array.isArray(value) ? key : null;
        continue;
      }
      const listItem = line.match(/^\s{4}-\s*(.*?)\s*$/);
      if (listItem && listKey) {
        task.approval_summary[listKey].push(listItem[1]);
      }
    }
  }

  return task;
}

function classifyPath(rawPath, repoRoot) {
  if (!rawPath) return null;

  const normalizedInput = normalizeWindowsDriveShorthand(rawPath);
  const absolutePath = path.resolve(repoRoot, normalizedInput);
  const projectRoot = path.resolve(repoRoot);
  const compareAbsolute = normalizeForCompare(absolutePath);
  const compareRoot = normalizeForCompare(projectRoot);
  const isWithinProjectRoot = compareAbsolute === compareRoot || compareAbsolute.startsWith(`${compareRoot}${path.sep}`);
  const relative = path.relative(projectRoot, absolutePath);
  const normalizedRelative = normalizeForCompare(relative);
  const isWithinModules = isWithinProjectRoot && (normalizedRelative === 'modules' || normalizedRelative.startsWith(`modules${path.sep}`));

  let realpath = absolutePath;
  let escapeDetected = false;
  let hasSymlinkOrJunction = false;
  try {
    realpath = fs.existsSync(absolutePath) ? fs.realpathSync.native(absolutePath) : absolutePath;
    const compareRealpath = normalizeForCompare(realpath);
    escapeDetected = !(compareRealpath === compareRoot || compareRealpath.startsWith(`${compareRoot}${path.sep}`));
  } catch {
    realpath = absolutePath;
  }

  const parts = absolutePath.split(/[\\/]+/);
  let probe = path.parse(absolutePath).root;
  for (const part of parts.slice(probe ? 1 : 0)) {
    if (!part) continue;
    probe = path.join(probe, part);
    try {
      if (fs.existsSync(probe) && fs.lstatSync(probe).isSymbolicLink()) {
        hasSymlinkOrJunction = true;
      }
    } catch {
      // Missing path segments are normal for planned writes.
    }
  }

  const windowsAds = /^[A-Za-z]:/.test(rawPath)
    ? /(^|[\\/])[^\\/]+:[^\\/]+$/.test(rawPath.slice(2))
    : /(^|[\\/])[^\\/]+:[^\\/]+$/.test(rawPath);

  return {
    raw_path: rawPath,
    normalized_path: normalizedInput,
    absolute_path: absolutePath,
    realpath,
    project_root: projectRoot,
    relative_path: relative,
    is_within_project_root: isWithinProjectRoot,
    is_within_modules: isWithinModules,
    has_symlink_or_junction: hasSymlinkOrJunction,
    escape_detected: escapeDetected,
    has_alternate_data_stream: windowsAds,
  };
}

function isSecretPath(rawPath) {
  if (!rawPath) return false;
  return SECRET_PATTERNS.some((pattern) => pattern.test(rawPath));
}

function normalizePattern(pattern) {
  return normalizeForCompare(pattern).replace(/\//g, path.sep);
}

function pathMatchesAllowedPattern(pathInfo, allowedPatterns) {
  if (!pathInfo) return allowedPatterns.length === 0;
  const relative = normalizeForCompare(pathInfo.relative_path);
  return allowedPatterns.some((pattern) => {
    const normalizedPattern = normalizePattern(pattern);
    if (normalizedPattern.endsWith(`${path.sep}**`)) {
      const prefix = normalizedPattern.slice(0, -3);
      return relative === prefix || relative.startsWith(`${prefix}${path.sep}`);
    }
    return relative === normalizedPattern;
  });
}

function approvalMarkdownStatus(taskRoot) {
  const approvalPath = taskRoot ? path.join(taskRoot, 'implementation-approval.md') : null;
  const text = readTextIfExists(approvalPath);
  if (!text) return { ok: false, reason: 'Implementation approval summary is missing.' };
  const missing = APPROVAL_HEADINGS.filter((heading) => !text.includes(heading));
  if (missing.length > 0) {
    return { ok: false, reason: `Implementation approval summary is incomplete: ${missing.join(', ')}` };
  }
  return { ok: true, path: approvalPath };
}

function decision(decisionValue, reason, extras = {}) {
  return {
    decision_id: `decision-${Date.now()}`,
    schema_version: '0.2.0',
    decision: decisionValue,
    reason,
    required_next_action: extras.required_next_action || { type: decisionValue === 'allow' ? 'run_verify' : 'ask_user' },
    matched_events: [],
    path_policy_result: extras.path_policy_result || null,
    capabilities: extras.capabilities || {},
  };
}

function dangerousCapabilityAllowed(capability, task, pathInfo) {
  const summary = task.approval_summary || {};
  const allowedCapabilities = Array.isArray(summary.allowed_capabilities) ? summary.allowed_capabilities : [];
  const allowedPaths = Array.isArray(summary.allowed_paths) ? summary.allowed_paths : [];

  if (summary.implementation !== 'approved') {
    return { ok: false, reason: `No exact-scope approval found for ${capability}.` };
  }
  if (!allowedCapabilities.includes(capability)) {
    return { ok: false, reason: `No exact-scope approval found for ${capability}.` };
  }

  const booleanField = BOOLEAN_CAPABILITY_FIELDS[capability];
  if (booleanField && summary[booleanField] !== true) {
    return { ok: false, reason: `Capability ${capability} is locked in approval_summary.` };
  }

  if (capability.startsWith('file.write.') && !pathMatchesAllowedPattern(pathInfo, allowedPaths)) {
    return { ok: false, reason: `Requested path is outside approved paths for ${capability}.` };
  }

  return { ok: true };
}

function decide(input) {
  const repoRoot = path.resolve(input.repoRoot || process.cwd());
  const taskDir = input.taskRoot ? path.resolve(input.taskRoot) : (input.taskDir ? path.resolve(repoRoot, input.taskDir) : null);
  const taskYamlPath = input.taskYamlPath || (taskDir ? path.join(taskDir, 'task.yaml') : null);
  const capabilityCatalogPath = input.capabilityCatalogPath || path.join(repoRoot, 'harness', 'contracts', 'capability-catalog.yaml');
  const capabilityCatalog = readTextIfExists(capabilityCatalogPath);

  const task = parseTaskYaml(readTextIfExists(taskYamlPath));
  const capability = input.capability;
  const pathInfo = classifyPath(input.path, repoRoot);
  const currentGate = task.current_gate || '';

  const base = {
    requested_action: input.action || null,
    capability,
    task_id: task.task_id || null,
    task_type: task.task_type || task.type || null,
    current_gate: currentGate,
    path_policy_result: pathInfo,
  };

  if (!capability) {
    return { ...base, ...decision('block', 'Missing capability.') };
  }

  if (!capabilityCatalog.includes(`${capability}:`) && !capabilityCatalog.includes(capability)) {
    return { ...base, ...decision('deny', `Unknown capability: ${capability}`) };
  }

  if (capability === 'file.read.secret' || isSecretPath(input.path)) {
    return { ...base, ...decision('deny', 'Secrets are deny-by-default.', { path_policy_result: pathInfo }) };
  }

  if (pathInfo) {
    if (!pathInfo.is_within_project_root || pathInfo.escape_detected) {
      return { ...base, ...decision('deny', 'Path escapes project root.', { path_policy_result: pathInfo }) };
    }
    if (pathInfo.has_alternate_data_stream) {
      return { ...base, ...decision('deny', 'Windows alternate data stream paths are denied.', { path_policy_result: pathInfo }) };
    }
    if (pathInfo.has_symlink_or_junction) {
      return { ...base, ...decision('deny', 'Symlink or junction path requires explicit safe handling.', { path_policy_result: pathInfo }) };
    }
  }

  if (capability === 'file.read.project') {
    if (READ_ALLOWED_GATES.has(currentGate)) {
      return { ...base, ...decision('allow', `Project read is allowed during current_gate ${currentGate}.`, { path_policy_result: pathInfo }) };
    }
    return { ...base, ...decision('deny', 'Project read before grill/research is denied.', { path_policy_result: pathInfo }) };
  }

  if (capability === 'network.web_research') {
    if (currentGate === 'research') {
      return { ...base, ...decision('allow', 'General web research is allowed during research.', { path_policy_result: pathInfo }) };
    }
    return { ...base, ...decision('deny', 'Web research requires the research gate.', { path_policy_result: pathInfo }) };
  }

  if (capability === 'file.write.folder_skeleton') {
    if (currentGate !== 'folder_skeleton') {
      return { ...base, ...decision('deny', 'folder_skeleton writes require the folder_skeleton gate.', { path_policy_result: pathInfo }) };
    }
    if (pathInfo && !pathInfo.is_within_modules) {
      return { ...base, ...decision('deny', 'Folder skeleton writes must stay under modules/.', { path_policy_result: pathInfo }) };
    }
    const extension = path.extname(input.path || '').toLowerCase();
    if (EXECUTABLE_SKELETON_EXTENSIONS.has(extension)) {
      return { ...base, ...decision('deny', 'folder_skeleton cannot create executable source, runtime config, tests, or fixtures.', { path_policy_result: pathInfo }) };
    }
    return { ...base, ...decision('allow', 'Folder skeleton write allowed by current gate.', { path_policy_result: pathInfo }) };
  }

  if (capability === 'file.write.module' && pathInfo && !pathInfo.is_within_modules) {
    return { ...base, ...decision('deny', 'Product module writes must stay under modules/ unless outside_modules_write is approved.', { path_policy_result: pathInfo }) };
  }

  if (capability === 'file.write.harness_core') {
    const taskType = task.task_type || task.type;
    if (taskType !== 'template_maintenance' && taskType !== 'harness_update') {
      return { ...base, ...decision('proposal_required', 'Harness-core writes require template_maintenance or harness_update; product tasks must create proposals.', { path_policy_result: pathInfo }) };
    }
  }

  if (!DANGEROUS_CAPABILITIES.has(capability)) {
    return { ...base, ...decision('deny', `No default allow rule for ${capability}.`, { path_policy_result: pathInfo }) };
  }

  const approval = dangerousCapabilityAllowed(capability, task, pathInfo);
  if (!approval.ok) {
    return {
      ...base,
      ...decision('deny', approval.reason, {
        path_policy_result: pathInfo,
        required_next_action: { type: 'ask_user', gate_id: 'implementation', missing_capabilities: [capability] },
      }),
    };
  }

  const approvalMarkdown = approvalMarkdownStatus(taskDir);
  if (!approvalMarkdown.ok) {
    return {
      ...base,
      ...decision('deny', approvalMarkdown.reason, {
        path_policy_result: pathInfo,
        required_next_action: { type: 'ask_user', gate_id: 'implementation', missing_capabilities: [capability] },
      }),
    };
  }

  return {
    ...base,
    ...decision('allow', 'Allowed by task.yaml approval_summary derived from current chat approval.', {
      path_policy_result: pathInfo,
      capabilities: { [capability]: 'approved' },
    }),
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    process.stdout.write('Usage: node permission-decision.js --repo-root <path> --task-root <task-dir> --capability <capability> [--path <path>] [--action <action>]\n');
    return;
  }
  const result = decide({
    repoRoot: args['repo-root'] || process.cwd(),
    taskDir: args.task,
    taskRoot: args['task-root'],
    taskYamlPath: args['task-yaml'],
    capability: args.capability,
    path: args.path,
    action: args.action,
  });
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  process.exitCode = result.decision === 'allow' ? 0 : 2;
}

if (require.main === module) {
  main();
}

module.exports = {
  decide,
  classifyPath,
  parseTaskYaml,
};
