#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const { classifyLearningCandidates } = require('./learning-classifier');

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
      fs.writeFileSync(target, text, 'utf8');
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

function captureLearning(options) {
  const root = path.resolve(options.root || process.cwd());
  const slug = options.slug;
  if (!slug) throw new Error('capture-learning requires --slug.');

  const taskRoot = path.join(root, 'harness', 'docs', 'tasks', 'active', slug);
  if (!fs.existsSync(taskRoot)) throw new Error(`Active task not found: ${slug}`);

  const verifyPath = options.verifyJson ? path.resolve(options.verifyJson) : null;
  const verificationPath = path.join(taskRoot, 'verification.md');
  const acceptancePath = path.join(taskRoot, 'acceptance.md');
  const verifyText = verifyPath && fs.existsSync(verifyPath) ? fs.readFileSync(verifyPath, 'utf8') : '';
  const verifyResult = verifyText ? JSON.parse(verifyText) : { failures: [] };
  const verificationText = fs.existsSync(verificationPath) ? fs.readFileSync(verificationPath, 'utf8') : '';
  const acceptanceText = fs.existsSync(acceptancePath) ? fs.readFileSync(acceptancePath, 'utf8') : '';

  const result = classifyLearningCandidates({
    verificationText,
    acceptanceText,
    failures: verifyResult.failures || [],
  });

  const candidateCount = result.candidates.length;
  const verifySummary = verificationText.split(/\r?\n/).map((line) => line.trim()).find(Boolean) || '';
  const userCorrection = acceptanceText.split(/\r?\n/).map((line) => line.trim()).find((line) => line.includes('수정') || line.includes('정정')) || '';
  const lines = [
    '# 배운 점 후보',
    '',
    '이 문서는 구조화된 검증 결과와 사용자 정정에서 나온 재발방지 후보만 기록합니다.',
    '',
    'raw 대화 전문을 저장하지 않습니다.',
    '',
    '## Capture Metadata',
    '',
    `candidate_count: ${candidateCount}`,
    `source_verify_summary: ${verifySummary}`,
    `source_user_correction: ${userCorrection}`,
    `no_candidate_reason: ${candidateCount === 0 ? '분류 가능한 구조화 증거가 없습니다.' : ''}`,
    '',
    '## 자동분류 후보',
    '',
  ];

  if (candidateCount === 0) {
    lines.push('아직 기록된 후보가 없습니다.');
  } else {
    result.candidates.forEach((candidate, index) => {
      lines.push(`### 후보 ${index + 1}`);
      lines.push('');
      lines.push(`분류: ${candidate.category}`);
      lines.push(`요약: ${candidate.summary}`);
      lines.push(`증거: ${candidate.evidence}`);
      lines.push(`재발방지 후보: ${candidate.recurrence_prevention}`);
      lines.push(`장기 반영 추천: ${candidate.promotion_recommendation}`);
      lines.push('');
    });
  }

  const outputPath = path.join(taskRoot, 'learning-capture.md');
  fs.writeFileSync(outputPath, `${lines.join('\n')}\n`, 'utf8');
  return { ok: true, task: slug, output_path: outputPath, candidates: candidateCount };
}

function main() {
  const { positional, flags } = parseArgs(process.argv.slice(2));
  const command = positional[0];
  let result;
  if (command === 'create-task') {
    result = createTaskSkeleton({ root: flags.root, slug: flags.slug, taskType: flags['task-type'] });
  } else if (command === 'archive-task') {
    result = archiveTask({ root: flags.root, slug: flags.slug });
  } else if (command === 'capture-learning') {
    result = captureLearning({ root: flags.root, slug: flags.slug, verifyJson: flags['verify-json'] });
  } else {
    throw new Error('Usage: lifecycle.js create-task|archive-task|capture-learning --root <root> --slug <slug>');
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
  captureLearning,
};
