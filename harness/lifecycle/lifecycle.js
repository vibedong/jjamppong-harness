#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

function parseArgs(argv) {
  const positional = [];
  const flags = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith('--')) {
      positional.push(token);
      continue;
    }
    const key = token.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      flags[key] = true;
    } else {
      flags[key] = next;
      i += 1;
    }
  }
  return { positional, flags };
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function copyTemplateDir(sourceRoot, targetRoot, replacements) {
  for (const entry of fs.readdirSync(sourceRoot, { withFileTypes: true })) {
    const source = path.join(sourceRoot, entry.name);
    const target = path.join(targetRoot, entry.name);
    if (entry.isDirectory()) {
      ensureDir(target);
      copyTemplateDir(source, target, replacements);
    } else if (entry.isFile()) {
      let text = fs.readFileSync(source, 'utf8');
      for (const [key, value] of Object.entries(replacements)) {
        text = text.split(`{{${key}}}`).join(value);
      }
      if (entry.name === 'events.jsonl.template') {
        fs.writeFileSync(path.join(targetRoot, 'events.jsonl'), '', 'utf8');
      } else {
        fs.writeFileSync(target, text, 'utf8');
      }
    }
  }
}

function activeTaskDirs(root) {
  const activeRoot = path.join(root, 'harness', 'docs', 'tasks', 'active');
  if (!fs.existsSync(activeRoot)) return [];
  return fs.readdirSync(activeRoot, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name);
}

function createTaskSkeleton(options) {
  const root = path.resolve(options.root || process.cwd());
  const slug = options.slug;
  const taskType = options.taskType || 'product_feature';
  if (!slug || !/^[a-z0-9][a-z0-9-]*$/.test(slug)) {
    throw new Error('Task slug must be lowercase ASCII kebab-case.');
  }

  const active = activeTaskDirs(root);
  if (active.length > 0 && !active.includes(slug)) {
    throw new Error(`Active task default is one. Existing active task(s): ${active.join(', ')}`);
  }

  const templateRoot = path.join(root, 'harness', 'templates', 'task');
  const taskRoot = path.join(root, 'harness', 'docs', 'tasks', 'active', slug);
  ensureDir(taskRoot);
  const now = new Date().toISOString();
  copyTemplateDir(templateRoot, taskRoot, {
    task_id: slug,
    task_type: taskType,
    created_at: now,
    updated_at: now,
  });
  return { ok: true, task: slug, task_root: taskRoot };
}

function archiveTask(options) {
  const root = path.resolve(options.root || process.cwd());
  const slug = options.slug;
  if (!slug) throw new Error('archive-task requires --slug.');

  const taskRoot = path.join(root, 'harness', 'docs', 'tasks', 'active', slug);
  if (!fs.existsSync(taskRoot)) throw new Error(`Active task not found: ${slug}`);
  const summary = path.join(taskRoot, 'archive-summary.md');
  if (!fs.existsSync(summary)) throw new Error('archive-summary.md is required before archive.');

  const now = new Date();
  const yyyy = String(now.getFullYear());
  const mm = String(now.getMonth() + 1).padStart(2, '0');
  const archiveRoot = path.join(root, 'harness', 'docs', 'tasks', 'archive', yyyy, mm, slug);
  ensureDir(path.dirname(archiveRoot));
  if (fs.existsSync(archiveRoot)) throw new Error(`Archive task already exists: ${archiveRoot}`);
  fs.renameSync(taskRoot, archiveRoot);
  return { ok: true, task: slug, archive_root: archiveRoot };
}

function main() {
  const { positional, flags } = parseArgs(process.argv.slice(2));
  const command = positional[0];
  let result;
  if (command === 'create-task') {
    result = createTaskSkeleton({ root: flags.root, slug: flags.slug, taskType: flags['task-type'] });
  } else if (command === 'archive-task') {
    result = archiveTask({ root: flags.root, slug: flags.slug });
  } else {
    throw new Error('Usage: lifecycle.js create-task|archive-task --root <root> --slug <slug>');
  }
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}

if (require.main === module) {
  try {
    main();
  } catch (error) {
    process.stderr.write(`ERROR ${error.message}\n`);
    process.exitCode = 1;
  }
}

module.exports = {
  createTaskSkeleton,
  archiveTask,
};
