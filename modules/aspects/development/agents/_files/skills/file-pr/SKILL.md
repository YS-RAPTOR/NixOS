---
name: file-pr
description: Use when the user asks to file, open, create or update a pull request.
---

# File PR

## Review the change

Check whether a PR for this branch already exists; update it rather than creating a duplicate.

Review the full diff against the target branch, including earlier commits, and confirm its contents match the user's goal. Use the whole change to inform both the PR description and release notes.

## Release notes

If the repository uses a release-note fragment workflow:

- Check existing entries and add or update what is required, following the repository's conventions and changelog style.
- In monorepos, write project/package-specific entries unless tightly related changes are better explained together.

## Title

PR titles usually become commit messages. Follow the repository's conventions, using recently merged PRs and Git history as examples. Write a concise, human-readable title that explains why the change matters.

- Bad: `perf(server): negotiate permessage-deflate on the websocket`
- Good: `perf(server): cut websocket frame size by 70%+ with gzipping`

## Description

Follow the repository's PR template, or write a clear summary if none exists. Open the summary with the problem from the user's original prompt, then briefly explain the solution—not an implementation inventory.

- Bad: “Removed implicit workspace carry-over from every new-thread entry point and deleted contextual thread helpers.”
- Good: “My ‘new worktree’ default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.”

## Publish

Create or update the PR using the host's CLI, including any required release-note entries. Open it ready for review rather than as a draft so review bots run, unless the user requests a draft.

- On GitHub, attach images or videos with `--attach <file>` on `gh pr create`, `gh pr edit` or `gh pr comment`. Repeat the flag for multiple files.
- If an upload fails, check the returned PR URL before retrying—the PR may already have been created or updated.

Link the published PR to the T3 thread with `link_pull_request`. For a stack, link every PR.
