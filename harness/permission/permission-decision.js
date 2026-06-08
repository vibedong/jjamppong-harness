#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const CAPABILITY_EFFECT_ALIASES = {
  'file.write.module': ['file.write.module', 'code', 'tests', 'fixtures'],
  'file.write.folder_skeleton': ['file.write.folder_skeleton', 'folder_skeleton'],
  'file.write.outside_modules': ['file.write.outside_modules', 'outside_modules_write'],
  'file.write.harness_core': ['file.write.harness_core', 'harness_core_change'],
  'network.live_target': ['network.live_target', 'live_access'],
  'network.web_research': ['network.web_research'],
  'package.install': ['package.install', 'package_install'],
  'git.commit': ['git.commit', 'git_commit'],
  'git.push': ['git.push', 'git_push'],
  'installer.install': ['installer.install'],
  'parallel.write': ['parallel.write'],
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

function parseTaskYaml(text) {
  const task = {};
  for (const line of text.split(/\r?\n/)) {
    const match = line.match(/^\s*([A-Za-z0-9_.-]+):\s*(.+?)\s*$/);
    if (!match) continue;
    task[match[1]] = match[2].replace(/^["']|["']$/g, '');
  }
  return task;
}

function readJsonl(filePath) {
  if (!filePath || !fs.existsSync(filePath)) return [];
  const text = fs.readFileSync(filePath, 'utf8');
  return text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line, index) => {
      try {
        return JSON.parse(line);
      } catch (error) {
        const err = new Error(`Invalid JSONL at ${filePath}:${index + 1}: ${error.message}`);
        err.code = 'INVALID_JSONL';
        throw err;
      }
    });
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

function eventPayload(event) {
  return event && typeof event.payload === 'object' && event.payload !== null ? event.payload : {};
}

function gateStatus(events, gateId) {
  for (let i = events.length - 1; i >= 0; i -= 1) {
    const event = events[i];
    const payload = eventPayload(event);
    if (event.event_type === 'gate_status_change' && payload.gate_id === gateId) {
      return payload.status || null;
    }
    if (event.event_type === 'approval_decision' && payload.gate_id === gateId) {
      return payload.status || null;
    }
  }
  return null;
}

function capabilityAliases(capability) {
  return CAPABILITY_EFFECT_ALIASES[capability] || [capability];
}

function hasCapabilityInApproval(approval, capability) {
  const payload = eventPayload(approval);
  const aliases = capabilityAliases(capability);
  const effects = payload.effects || {};
  const capabilities = Array.isArray(payload.capabilities) ? payload.capabilities : [];
  return aliases.some((alias) => effects[alias] === true || capabilities.includes(alias));
}

function targetPathCovered(approval, pathInfo) {
  if (!pathInfo) return true;
  const payload = eventPayload(approval);
  const targetPaths = payload.target_paths || {};
  const allowed = Array.isArray(targetPaths.allowed) ? targetPaths.allowed : [];
  if (allowed.length === 0) return false;

  const relative = normalizeForCompare(pathInfo.relative_path);
  return allowed.some((pattern) => {
    const normalizedPattern = normalizeForCompare(pattern);
    if (normalizedPattern.endsWith(`${path.sep}**`)) {
      const prefix = normalizedPattern.slice(0, -3);
      return relative === prefix || relative.startsWith(`${prefix}${path.sep}`);
    }
    if (normalizedPattern.endsWith('/**')) {
      const prefix = normalizedPattern.slice(0, -3).replace(/\//g, path.sep);
      return relative === prefix || relative.startsWith(`${prefix}${path.sep}`);
    }
    return relative === normalizedPattern;
  });
}

function invalidatedApprovalIds(events) {
  const ids = new Set();
  for (const event of events) {
    if (event.event_type !== 'invalidation') continue;
    const payload = eventPayload(event);
    if (payload.approval_event_id) ids.add(payload.approval_event_id);
    if (payload.approval_id) ids.add(payload.approval_id);
  }
  return ids;
}

function findApproval(events, capability, pathInfo) {
  const invalidated = invalidatedApprovalIds(events);
  return events.find((event) => {
    if (event.event_type !== 'approval_decision') return false;
    const payload = eventPayload(event);
    if (payload.status !== 'approved') return false;
    if (invalidated.has(event.event_id) || invalidated.has(payload.approval_id)) return false;
    return hasCapabilityInApproval(event, capability) && targetPathCovered(event, pathInfo);
  });
}

function decision(decisionValue, reason, extras = {}) {
  return {
    decision_id: `decision-${Date.now()}`,
    schema_version: '0.1.0',
    decision: decisionValue,
    reason,
    required_next_action: extras.required_next_action || { type: decisionValue === 'allow' ? 'run_verify' : 'ask_user' },
    matched_events: extras.matched_events || [],
    path_policy_result: extras.path_policy_result || null,
    capabilities: extras.capabilities || {},
  };
}

function decide(input) {
  const repoRoot = path.resolve(input.repoRoot || process.cwd());
  const taskDir = input.taskDir ? path.resolve(repoRoot, input.taskDir) : null;
  const eventsPath = input.eventsPath || (taskDir ? path.join(taskDir, 'events.jsonl') : null);
  const taskYamlPath = input.taskYamlPath || (taskDir ? path.join(taskDir, 'task.yaml') : null);
  const capabilityCatalogPath = input.capabilityCatalogPath || path.join(repoRoot, 'harness', 'contracts', 'capability-catalog.yaml');
  const capabilityCatalog = readTextIfExists(capabilityCatalogPath);

  const task = parseTaskYaml(readTextIfExists(taskYamlPath));
  const events = readJsonl(eventsPath);
  const capability = input.capability;
  const pathInfo = classifyPath(input.path, repoRoot);

  const base = {
    requested_action: input.action || null,
    capability,
    task_type: task.task_type || task.type || null,
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
    const researchStatus = gateStatus(events, 'research');
    if (researchStatus === 'open' || researchStatus === 'completed' || researchStatus === 'approved') {
      return { ...base, ...decision('allow', 'Project read is allowed during research after grill.', { path_policy_result: pathInfo }) };
    }
    return { ...base, ...decision('deny', 'Project read before grill/research is denied.', { path_policy_result: pathInfo }) };
  }

  if (capability === 'network.web_research') {
    const researchStatus = gateStatus(events, 'research');
    if (researchStatus === 'open' || researchStatus === 'completed' || researchStatus === 'approved') {
      return { ...base, ...decision('allow', 'General web research is allowed during research.', { path_policy_result: pathInfo }) };
    }
    return { ...base, ...decision('deny', 'Web research requires the research gate.', { path_policy_result: pathInfo }) };
  }

  if (capability === 'file.write.folder_skeleton') {
    if (pathInfo && !pathInfo.is_within_modules) {
      return { ...base, ...decision('deny', 'Folder skeleton writes must stay under modules/.', { path_policy_result: pathInfo }) };
    }
    const extension = path.extname(input.path || '').toLowerCase();
    if (EXECUTABLE_SKELETON_EXTENSIONS.has(extension)) {
      return { ...base, ...decision('deny', 'folder_skeleton cannot create executable source, runtime config, tests, or fixtures.', { path_policy_result: pathInfo }) };
    }
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

  const approval = findApproval(events, capability, pathInfo);
  if (!approval) {
    return {
      ...base,
      ...decision('deny', `No exact-scope approval found for ${capability}.`, {
        path_policy_result: pathInfo,
        required_next_action: { type: 'ask_user', gate_id: 'implementation', missing_capabilities: [capability] },
      }),
    };
  }

  return {
    ...base,
    ...decision('allow', `Allowed by approval event ${approval.event_id}.`, {
      matched_events: [approval.event_id],
      path_policy_result: pathInfo,
      capabilities: { [capability]: 'approved' },
    }),
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    process.stdout.write('Usage: node permission-decision.js --repo-root <path> --task <task-dir> --capability <capability> [--path <path>] [--action <action>]\n');
    return;
  }
  const result = decide({
    repoRoot: args['repo-root'] || process.cwd(),
    taskDir: args.task,
    eventsPath: args.events,
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
  readJsonl,
};
