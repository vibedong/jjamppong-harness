#!/usr/bin/env node
'use strict';

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const { verifyRoot } = require('../verify/verify');

const ROOT_ITEMS = [
  'AGENTS.md',
  'README.md',
  'CONTEXT.md',
  'handoff.md',
  'harness',
  'modules',
  'module-template',
  'proposals',
];

const EXCLUDED_DIRS = new Set([
  '.git',
  '.worktrees',
  'node_modules',
  'tests',
  'source-history',
]);

function normalizeTargetPath(target) {
  let text = String(target || '').trim();
  if (/^[A-Za-z]:[^\\/]/.test(text)) {
    text = `${text.slice(0, 2)}${path.sep}${text.slice(2)}`;
  }
  return path.resolve(text);
}

function sha256(filePath) {
  return crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex');
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function shouldSkip(relativePath) {
  const parts = relativePath.split(/[\\/]+/);
  if (parts.some((part) => EXCLUDED_DIRS.has(part))) return true;
  const normalized = relativePath.replace(/\\/g, '/');
  if (normalized.startsWith('harness/docs/tasks/active/')) return true;
  if (normalized.startsWith('harness/docs/tasks/archive/')) return true;
  if (normalized.startsWith('harness/artifacts/local/')) return true;
  return false;
}

function collectFiles(root, relative = '') {
  const current = path.join(root, relative);
  if (!fs.existsSync(current)) return [];
  const stat = fs.statSync(current);
  if (stat.isFile()) return [relative];
  if (!stat.isDirectory()) return [];

  const files = [];
  for (const entry of fs.readdirSync(current)) {
    const childRelative = relative ? path.join(relative, entry) : entry;
    if (shouldSkip(childRelative)) continue;
    files.push(...collectFiles(root, childRelative));
  }
  return files;
}

function backupExisting(targetRoot, relativePath, backupRoot, rollbackFiles) {
  const targetPath = path.join(targetRoot, relativePath);
  if (!fs.existsSync(targetPath)) return null;

  const backupPath = path.join(backupRoot, relativePath);
  ensureDir(path.dirname(backupPath));
  fs.copyFileSync(targetPath, backupPath);
  rollbackFiles.push({
    original: relativePath.replace(/\\/g, '/'),
    backup: path.relative(targetRoot, backupPath).replace(/\\/g, '/'),
    restored: false,
  });
  return backupPath;
}

function copyManagedFile(templateRoot, targetRoot, relativePath, backupRoot, rollbackFiles, managedFiles) {
  const sourcePath = path.join(templateRoot, relativePath);
  const targetPath = path.join(targetRoot, relativePath);
  ensureDir(path.dirname(targetPath));

  const sourceHash = sha256(sourcePath);
  if (fs.existsSync(targetPath)) {
    const targetHash = sha256(targetPath);
    if (targetHash === sourceHash) {
      managedFiles.push({
        path: relativePath.replace(/\\/g, '/'),
        sha256: sourceHash,
        owner: 'harness-core',
        action: 'unchanged',
      });
      return;
    }
    backupExisting(targetRoot, relativePath, backupRoot, rollbackFiles);
  }

  fs.copyFileSync(sourcePath, targetPath);
  managedFiles.push({
    path: relativePath.replace(/\\/g, '/'),
    sha256: sourceHash,
    owner: 'harness-core',
    action: 'written',
  });
}

function writeNeutralTaskDirs(targetRoot) {
  for (const relative of [
    'harness/docs/tasks/active',
    'harness/docs/tasks/archive',
    'harness/artifacts/local',
  ]) {
    const dir = path.join(targetRoot, relative);
    ensureDir(dir);
    const keep = path.join(dir, '.gitkeep');
    if (!fs.existsSync(keep)) fs.writeFileSync(keep, '', 'utf8');
  }
}

function writeHarnessLock(targetRoot, options, managedFiles, rollbackFiles) {
  const lockPath = path.join(targetRoot, 'harness.lock.yaml');
  const lines = [
    'harness:',
    '  name: jjamppong-harness',
    `  version: ${options.version}`,
    'installer:',
    '  package: "@vibedong/jjamppong-harness"',
    `  version: ${options.version}`,
    `installed_at: "${new Date().toISOString()}"`,
    `installed_from: "${options.templateRoot.replace(/\\/g, '/')}"`,
    'planning_started: false',
    'github_repo_created: false',
    'commit_created: false',
    'push_performed: false',
    'managed_files:',
  ];
  for (const file of managedFiles) {
    lines.push(`  - path: ${file.path}`);
    lines.push(`    sha256: ${file.sha256}`);
    lines.push(`    owner: ${file.owner}`);
    lines.push(`    action: ${file.action}`);
  }
  if (managedFiles.length === 0) lines.push('  []');
  if (rollbackFiles.length > 0) {
    lines.push('rollback_manifest:');
    lines.push(`  path: ${options.rollbackManifest.replace(/\\/g, '/')}`);
  }
  fs.writeFileSync(lockPath, `${lines.join('\n')}\n`, 'utf8');
}

function writeRollbackManifest(targetRoot, rollbackRoot, rollbackFiles) {
  if (rollbackFiles.length === 0) return null;
  const manifestPath = path.join(rollbackRoot, 'rollback-manifest.yaml');
  const lines = [
    `created_at: "${new Date().toISOString()}"`,
    'operation: install',
    'files:',
  ];
  for (const file of rollbackFiles) {
    lines.push(`  - original: ${file.original}`);
    lines.push(`    backup: ${file.backup}`);
    lines.push(`    restored: ${file.restored}`);
  }
  fs.writeFileSync(manifestPath, `${lines.join('\n')}\n`, 'utf8');
  return path.relative(targetRoot, manifestPath);
}

function installHarness(options) {
  const templateRoot = path.resolve(options.templateRoot || path.resolve(__dirname, '..', '..'));
  const targetRoot = normalizeTargetPath(options.target);
  const version = options.version || '0.1.0';

  if (!fs.existsSync(templateRoot)) throw new Error(`Template root not found: ${templateRoot}`);
  ensureDir(targetRoot);

  for (const nested of ['jjamppong-harness', 'ourosuper-harness']) {
    if (fs.existsSync(path.join(targetRoot, nested, 'AGENTS.md'))) {
      throw new Error(`Refusing to install with forbidden nested harness folder present: ${nested}/`);
    }
  }

  const stamp = new Date().toISOString().replace(/[-:]/g, '').replace(/\..+$/, 'Z');
  const backupRoot = path.join(targetRoot, '.harness-backups', stamp);
  const rollbackFiles = [];
  const managedFiles = [];

  for (const rootItem of ROOT_ITEMS) {
    const sourcePath = path.join(templateRoot, rootItem);
    if (!fs.existsSync(sourcePath)) continue;
    const files = collectFiles(templateRoot, rootItem);
    for (const relativePath of files) {
      copyManagedFile(templateRoot, targetRoot, relativePath, backupRoot, rollbackFiles, managedFiles);
    }
  }

  writeNeutralTaskDirs(targetRoot);
  const rollbackManifest = writeRollbackManifest(targetRoot, backupRoot, rollbackFiles);
  writeHarnessLock(targetRoot, { version, templateRoot, rollbackManifest }, managedFiles, rollbackFiles);

  const verification = verifyRoot(targetRoot);
  if (!verification.ok) {
    return {
      ok: false,
      target: targetRoot,
      installed: managedFiles.length,
      rollback_manifest: rollbackManifest,
      verification,
    };
  }

  return {
    ok: true,
    target: targetRoot,
    installed: managedFiles.length,
    rollback_manifest: rollbackManifest,
    verification,
    stopped_after_install: true,
    planning_started: false,
    github_repo_created: false,
    commit_created: false,
    push_performed: false,
  };
}

module.exports = {
  installHarness,
  normalizeTargetPath,
};
