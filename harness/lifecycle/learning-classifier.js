#!/usr/bin/env node
'use strict';

function categoryForFailureId(id) {
  const table = {
    gate_required_artifact_missing: 'artifact-routing',
    gate_artifact_content_insufficient: 'artifact-routing',
    implementation_approval_missing: 'permission-boundary',
    approval_summary_missing: 'permission-boundary',
    compound_review_required_for_solution_write: 'harness-drift',
    hot_context_too_large: 'harness-drift',
    hot_context_large_warning: 'harness-drift',
    legacy_ledger_artifact_present: 'harness-drift',
    nested_harness_folder: 'installer-flow',
    planning_started_during_install: 'installer-flow',
    github_repo_created_during_install: 'installer-flow',
    commit_created_during_install: 'permission-boundary',
    push_performed_during_install: 'permission-boundary',
  };
  return table[id] || null;
}

function scalarLine(text, key) {
  const escaped = key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const match = String(text || '').match(new RegExp(`^${escaped}:\\s*(.+?)\\s*$`, 'm'));
  return match ? match[1].trim() : '';
}

function classifyLearningCandidates(input) {
  const failures = Array.isArray(input.failures) ? input.failures : [];
  const acceptanceText = String(input.acceptanceText || '');
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

  const correction = scalarLine(acceptanceText, 'source_user_correction');
  if (correction) {
    const category = scalarLine(acceptanceText, 'source_user_correction_category') || 'harness-drift';
    const prevention = scalarLine(acceptanceText, 'source_user_correction_prevention') || 'Review this correction during compound_review.';
    pushCandidate({
      category,
      summary: correction,
      evidence: 'source_user_correction',
      recurrence_prevention: prevention,
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
