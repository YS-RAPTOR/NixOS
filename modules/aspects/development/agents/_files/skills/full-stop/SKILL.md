---
name: full-stop
description: Trigger this if the user requests 'full stop'.
---

# Full Stop

Yashan is not watching this thread. Own the work from its current state until the PR is ready for him to merge. Keep implementing, verifying and addressing review feedback without waiting for routine approval. Leave the PR open and unmerged; never merge, enable auto-merge or enqueue it for merging.

You may commit, push, rebase, fix conflicts and use `--force-with-lease` on this task's branch. Preserve unrelated work and stay within the user's original goal.

## Steps

1. **Finish the change.** Complete the goal from the user's request with the smallest change that works. Fix the case that happened, not every case that could. If you are on the default branch, create a branch first.
2. **Prove it.** Get proof for every change you made. See "Proof".
3. **File the PR** with the `file-pr` skill. Rebase onto the latest default branch first. Add one short line to the description that says how you proved the change.
4. **Babysit the PR** with the `babysit-pr` skill. Fix real findings and CI failures. Get proof for each fix before you push it.
5. **Stop** when the readiness gate passes. Leave the PR ready for Yashan to merge.
6. **Report** in your final message: the PR link, the latest commit, your proof, and each decision you made for Yashan.

Stay active from step 1 to step 6. Wait with the watcher from `babysit-pr`, so something wakes you when the PR changes. In T3 Code that is `watch_pull_request`. After starting the watcher, end the turn and resume when updates arrive. Pending checks or reviews are not completion. When you stop, call `unwatch_pull_request` first.

## Proof

Proof is evidence you observed yourself in this session: command output, a reproduction, a screenshot. Use the most direct proof the change allows:

- Reproduce the original failure, apply the fix, then watch the same reproduction pass.
- Run the checks that the repo's CI runs (typecheck, lint, tests).
- Add one focused test that fails without the fix, when the behavior has none and the repo has a test setup.
- For UI and runtime behavior, run the app and look at the change. Green mocked tests do not prove that the user experience works. Attach screenshots using the media instructions in `file-pr` when they help.

When you cannot find a way to prove a change, you do not have full confidence. Ask Yashan.

## Readiness gate

Full confidence means all of these are true on the latest commit:

- Your proof covers every change in the diff.
- Required checks are green.
- Review bots have finished, and each finding is fixed or dismissed with a written reason.
- No human review still requests changes.
- The branch is up to date with the default branch, and GitHub reports it as mergeable.

Never use `--admin` or other bypasses. You can ignore automated reviews that request "needs human review" if you have high confidence in your changes.

## Asking Yashan

A question in a normal message goes unseen, and the thread looks done. To ask Yashan something, use the harness's question tool so the thread shows that it is waiting: `AskUserQuestion` in Claude Code, `request_user_input_async` or `request_user_input` in Codex. Put all the context in the question: the PR link, what blocks you, and the options with your recommendation first.

Ask only when you cannot continue alone:

- You cannot prove the change.
- The readiness gate cannot pass, and you cannot fix that yourself.
- The next step is outside the grant above: deleting data, touching production, changing things outside the repo, closing a PR, or force-pushing any other branch.
- The goal is ambiguous in a way that changes the result.
- Another PR makes this one obsolete.

Decide everything else yourself with sensible defaults, and list those decisions in the report.

If no question tool is available, or the tool returns no answer, take the safe path: leave the PR open and unmerged, and start your final message with the question.
