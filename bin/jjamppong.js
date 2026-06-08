#!/usr/bin/env node
'use strict';

const path = require('path');
const { installHarness } = require('../harness/installer/install');
const { verifyRoot } = require('../harness/verify/verify');
const { diagnose } = require('../harness/doctor/doctor');
const { decide } = require('../harness/permission/permission-decision');

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

function printHelp() {
  process.stdout.write(`Usage:
  jjamppong install --target <path> [--template <path>]
  jjamppong verify --target <path> [--json]
  jjamppong doctor --target <path> [--proposal] [--json]
  jjamppong perm decide --repo-root <path> --capability <capability> [--path <path>]

Safety defaults:
  install stops after install/verify;
  no planning, package install, GitHub repo creation, commit, or push.
`);
}

function main() {
  const { positional, flags } = parseArgs(process.argv.slice(2));
  const command = positional[0];

  if (!command || flags.help || command === 'help') {
    printHelp();
    return;
  }

  if (command === 'install') {
    const target = flags.target || positional[1];
    if (!target) throw new Error('install requires --target <path>.');
    const result = installHarness({
      target,
      templateRoot: flags.template ? path.resolve(flags.template) : path.resolve(__dirname, '..'),
      version: require('../package.json').version,
    });
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
    return;
  }

  if (command === 'verify') {
    const target = flags.target || positional[1] || process.cwd();
    const result = verifyRoot(target);
    if (flags.json) {
      process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
    } else if (result.ok) {
      process.stdout.write(`verify passed for ${result.root}\n`);
    } else {
      process.stdout.write(`verify failed for ${result.root}\n`);
      for (const failure of result.failures) {
        process.stdout.write(`FAIL ${failure.id}: ${failure.message}\n`);
      }
    }
    process.exitCode = result.ok ? 0 : 1;
    return;
  }

  if (command === 'doctor') {
    const target = flags.target || positional[1] || process.cwd();
    const result = diagnose(target, { proposal: Boolean(flags.proposal) });
    if (flags.json) {
      process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
    } else if (result.ok) {
      process.stdout.write(`doctor found no P0 issues for ${result.root}\n`);
    } else {
      process.stdout.write(`doctor found ${result.failures.length} issue(s) for ${result.root}\n`);
      for (const failure of result.failures) {
        process.stdout.write(`- ${failure.id}: ${failure.next_action}\n`);
      }
      if (result.proposal_path) process.stdout.write(`proposal: ${result.proposal_path}\n`);
    }
    process.exitCode = result.ok ? 0 : 1;
    return;
  }

  if (command === 'perm' && positional[1] === 'decide') {
    const result = decide({
      repoRoot: flags['repo-root'] || process.cwd(),
      taskDir: flags.task,
      eventsPath: flags.events,
      taskYamlPath: flags['task-yaml'],
      capability: flags.capability,
      path: flags.path,
      action: flags.action,
    });
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
    process.exitCode = result.decision === 'allow' ? 0 : 2;
    return;
  }

  throw new Error(`Unknown command: ${positional.join(' ')}`);
}

try {
  main();
} catch (error) {
  process.stderr.write(`ERROR ${error.message}\n`);
  process.exitCode = 1;
}
