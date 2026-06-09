#!/usr/bin/env node
'use strict';

function categoryForFailureId(id) {
  const table = {
    artifact_forbidden_read: 'gate-order',
    artifact_read_receipt_missing: 'artifact-routing',
    artifact_required_write_missing: 'artifact-routing',
    nested_harness_folder: 'installer-flow',
    planning_started_during_install: 'installer-flow',
    github_repo_created_during_install: 'installer-flow',
    commit_created_during_install: 'permission-boundary',
    push_performed_during_install: 'permission-boundary',
    projection_without_canonical_event: 'permission-boundary',
    compound_review_required_for_solution_write: 'harness-drift',
  };
  return table[id] || null;
}

function classifyLearningCandidates(input) {
  const failures = Array.isArray(input.failures) ? input.failures : [];
  const events = Array.isArray(input.events) ? input.events : [];
  const candidates = [];
  let next = 1;

  function pushCandidate(candidate) {
    candidates.push({
      candidate_ref: candidate.candidate_ref || `cand-${String(next).padStart(3, '0')}`,
      ...candidate,
    });
    next += 1;
  }

  for (const failure of failures) {
    const category = categoryForFailureId(failure.id);
    if (!category) continue;
    pushCandidate({
      category,
      summary: failure.message || failure.id,
      evidence: failure.id,
      recurrence_prevention: `Add or update ${category} solution guidance after compound_review if this repeats.`,
      promotion_recommendation: 'keep_active_only',
    });
  }

  for (const event of events) {
    const payload = event.payload || {};
    if (event.event_type !== 'user_correction' || !payload.category) continue;
    pushCandidate({
      category: payload.category,
      summary: payload.summary || 'User correction recorded in canonical event data.',
      evidence: event.event_id || 'user_correction',
      recurrence_prevention: payload.recurrence_prevention || 'Review this correction during compound_review.',
      promotion_recommendation: 'keep_active_only',
    });
  }

  return { candidates };
}

function main() {
  const args = process.argv.slice(2);
  if (!args.includes('--stdin')) {
    throw new Error('Usage: learning-classifier.js --stdin --json');
  }
  let input = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (chunk) => {
    input += chunk;
  });
  process.stdin.on('end', () => {
    const normalizedInput = input.replace(/^\uFEFF/, '');
    const parsed = normalizedInput.trim() ? JSON.parse(normalizedInput) : {};
    process.stdout.write(`${JSON.stringify(classifyLearningCandidates(parsed), null, 2)}\n`);
  });
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
  classifyLearningCandidates,
};
