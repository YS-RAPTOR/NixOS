---
name: babysit-pr
description: Monitor a pull request through review and CI. Use when the user asks to monitor, watch, or babysit a PR.
---

# Babysit PR

All the repos we work in have various AI review bots. They're helpful, even if they are not always right.

## Monitor the PR

Use T3 Code's `watch_pull_request` to monitor the PR:

1. T3 sends updates when checks fail, required checks pass, new comments or reviews arrive, or merge conflicts appear.
2. After starting the watch, end the turn. T3 handles monitoring; no polling loop or sleep command is needed.
3. When an update arrives, inspect the current PR state and handle it. If monitoring is still needed, end the turn again and wait for the next update.

## Handle updates

Only act on checks and comments newer than the latest push. Verify every bot finding against the source before changing code. Fix real findings and CI failures, distinguish repository failures from infrastructure flakes, and reply with a written reason when dismissing false positives.

Keep an eye on changes to `main` and rebase when needed. If an overlapping PR makes this one obsolete, stop monitoring, report it to the user, and ask before closing the PR.

If a review bot leaves feedback you believe is not worth addressing, reply with a written reason and resolve the comment.

## Human review

For human review feedback:

- If it is trivial or was already discussed and agreed with the user in this session, you may respond.
- Otherwise, notify the user and leave the reply to them.
- Include this note when replying to a human reviewer: `> Automated reply from an agent.`

## Media

Screenshots and videos help as well. Use `gh pr comment --attach <file>` or `gh pr edit --attach <file>` when needed.

## Scope and completion

Do not let review feedback expand the PR beyond the user's original goal. Address real shortcomings, but avoid scope creep.

If nothing has changed, stay quiet rather than posting filler comments. Stop when the review bots and required checks are green on the latest commit and report that the PR is ready.
