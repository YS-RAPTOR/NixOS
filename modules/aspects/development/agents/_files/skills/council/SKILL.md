---
name: council
description: Use when asked to consult the council.
---

# Council

A council is a panel of models that review the user's work until they agree. Members only read and report. You are the **chair**.

The council runs four stages in order: **Design**, then the refinement stages **Simplification**, **Correctness** and **Quality**. The user can drop, reorder or replace stages, or add their own; see Custom stages.

The user consults the council for one of three things:

- **Design.** The user wants a decision before any code exists. Run the design stage only, report the agreed design and leave the code alone.
- **Build.** The user wants something new built. Run the design stage, note `HEAD` as the base, implement the agreed design yourself, then run the refinement stages on your implementation.
- **Review.** The user already has a change. Skip design and run the refinement stages on that change.

## Members

The members are the latest Sol and the latest Opus at high reasoning, unless the user requests different members. Find their current model IDs with `orchestrator_capabilities`. If a member is unavailable, stop and tell the user.

## The chair

You represent the user. Act as a judge, not a participant:

- Write prompts that carry the user's request, their constraints and the code. Keep your own opinions out; raise a doubt only as an open question.
- Judge every reply yourself against the code and `request.md`. Agree with a member only on the merits, never to end a stage.
- Answer members' questions yourself, from the user's request and their stated preferences. Ask the user only what you can't answer that way. Add each answer to `request.md`, so every member sees it next round.
- Keep the council on the user's prompt. Push back on findings and proposals that grow the scope beyond it.
- Push back on the user. If the council concludes something the user asked for is wrong, say so, with the council's reasons.

## Running the council

Before the first round, create `/tmp/council-<topic>/` and write `request.md`: the user's request in their words; its intent and what is out of scope, in 1–2 sentences; and every constraint and non-goal they have stated. Re-read `request.md` after any context compaction.

Every round, in every stage:

1. **Hold the code still.** Members read the live repository, so leave the files in scope untouched until every member has replied.
2. **Write the prompts.** Fill the variables of the stage's template, using the stage guideline and `request.md`. Write them fresh each round; members start every round with no memory.
3. **Send them.** Call `delegate_task` once per member with `mode: "async"` and a new `clientRequestId`. Wait for the completion notices instead of polling.
4. **Collect every reply.** A member that errors, times out or is interrupted has not approved. Cancel it, confirm it stopped, then retry it, up to three times; if it still fails, stop and tell the user. Save each reply in the council directory as `<stage>-<n>-<member>.md`.
5. **Act on the replies** as the stage's guideline describes. Record each finding's outcome in the council directory. After any edit, re-run the checks and fix anything the change broke before the next round.
6. **Decide.** The stage is over when its guideline says so and none of your open questions is unanswered. If it isn't over by the round type's limit, break the tie as the round type describes. Otherwise, run another round.

When the last stage ends, report to the user. Lead with every tie you broke and every question you answered on their behalf, so they can overrule any of it, then give each stage's summary as its round type describes, with its rounds, the members' providers and models, and their effort if `delegate_task` exposed it (otherwise say so).

## Round guidelines

Each round type sets what members see, the prompt template and the reply format. The stage fills the variables and decides how you judge replies and when it is over.

Every template shares these variables. A variable left empty drops its whole line.

| Variable           | Value                                                 |
| ------------------ | ----------------------------------------------------- |
| `$REQUEST`         | the path to `request.md`                              |
| `$STAGE`, `$ROUND` | the stage's name and the round number                 |
| `$CHECKS`          | the stage's checks, plus those of every earlier stage |
| `$QUESTIONS`       | your open questions for the members, if any           |

### Blind round

Members review the same change independently.

#### Setup

Before the first blind round, run the checks that cover the change and fix anything it broke. Never stash, discard or include unrelated changes. If they don't separate cleanly from the change, stop and ask. Then record in `request.md`:

- **Repo:** the checkout's absolute path.
- **Scope:** the change's paths, from `git status --short`.
- **Base:** for a build, the `HEAD` you noted before implementing. Otherwise, after `git fetch origin`:
    - PR: `git merge-base HEAD origin/<baseRefName>`, with `baseRefName` from `gh pr view <n> --json baseRefName,headRefOid`. Check out its branch only if the tree is clean, and confirm `HEAD` is the PR head or ahead of it only by this change.
    - Local branch: `git merge-base HEAD origin/<default-branch>`.
    - No remote: the base the user names, or `HEAD` for uncommitted changes only.
- **Diff:** one command from the base to the working tree, limited to the scope. Use it every round.
- **Checks:** each result, including checks that are missing or were already failing.

#### Rounds

- **Limit.** At most three. A stage can name conditions that extend this to five, and the user can always allow more.
- **Each round.** Every member reviews the whole current change. From round 2, it also sees its own earlier findings and how you handled them, never another member's.
- **Approvals.** An approval covers only code you haven't touched since the member read it. Edits that only change comments, docs or formatting keep it.
- **Tie-break.** Rule on any finding still disputed after two replies, and on each finding still open at the limit. Report both sides in 2–3 lines each.

| Variable      | Value                                                                                                                  |
| ------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `$DIFF`       | the diff command from `request.md`                                                                                     |
| `$SEVERITIES` | the stage's severity definitions, if it has any                                                                        |
| `$HISTORY`    | from round 2: this member's own findings, each marked fixed, disputed with your evidence, or declined with your reason |

```text
Review only. Do not edit files, commit, push, comment on PRs or start subagents.
Read $REQUEST first.
Stage: $STAGE, round $ROUND.
The change: in the recorded repo, run `$DIFF` and `git status --short`. Read all of it, any untracked files, and the code around it.
Check: $CHECKS
$SEVERITIES
Your earlier findings: $HISTORY Mark each one resolved, or still open with a reason.
$QUESTIONS
Keep each finding's id the same across rounds.
Reply:
VERDICT: APPROVE or CHANGES
<id> [<severity>] <file>:<line> <claim>. Evidence: <how you know>. Fix: <smallest fix>.
```

#### Summary

What the council changed: each fix, any mechanism it added or removed, and the finding behind it. The diff size before and after (`git diff --shortstat <base>`). A code-shaped sketch of the final change, such as a call tree or diff. Declined findings, one line each on why.

### Deliberation round

Members weigh each other's proposals until they back the same one.

#### Rounds

- **Limit.** At most five.
- **Round 1.** Each member proposes without seeing the others.
- **Between rounds.** Label each proposal A, B and so on rather than by model, and save it in the council directory. A revision replaces its author's earlier proposal under the same label, and agreement counts only for the version a member read.
- **From round 2.** Each member reads every proposal and replies as `$TASK` says.
- **Tie-break.** If members still back different proposals after the last round, pick the one that best meets `request.md` and the stage's checks, judged on the members' arguments rather than your own preference. Report the dissent and why you ruled against it.

Variables:

- `$TASK`, round 1: "Propose your recommended shape and a sketch of the key interfaces or code. Explain the alternatives you rejected, the risks, and any questions you need answered."
- `$TASK`, from round 2: "Agree with one proposal as it stands, or revise your own. Say what you take from the others and what you reject, with reasons. Agree only on the merits."
- `$PROPOSALS`, from round 2: the labelled proposal paths, and which label is the member's own.

```text
Discussion only. Do not edit files, commit, push, comment on PRs or start subagents.
Read $REQUEST first.
Stage: $STAGE, round $ROUND.
Consider: $CHECKS
Proposals so far: $PROPOSALS
$TASK
$QUESTIONS
Reply, ending with:
VERDICT: PROPOSE (round 1), or AGREE <label> or REVISE
```

#### Summary

The agreed proposal and any dissent.

## Stage guidelines

### Design

Deliberation round with:

- `$CHECKS`: the shape that meets the user's intent with the fewest mechanisms. Prefer native primitives. The existing architecture is open to challenge.

Over when every member agrees with the same proposal, no earlier than round 2. Write the agreed design into `request.md`, so the refinement stages check against it.

### Simplification

Blind round with:

- `$CHECKS`: what can be deleted, merged or inlined. Every guard, wrapper, flag, timer and poll must earn its place, including ones the council added.

Apply a finding when the result is smaller or clearer and behaves the same. Decline the rest in one line.

Over when every member returns `APPROVE`.

### Correctness

Blind round with:

- `$CHECKS`: bugs, broken callers, and anything that misses the user's intent. Style belongs to the quality stage; raise it here only when it hides a bug.
- `$SEVERITIES`: blocker = the intended case is wrong. should = a real bug callers or users will hit, within the request. nit = everything else. A rare case, another code path, a small performance cost or extra compatibility is a nit.

Apply that nit rule yourself too, whatever label a finding came with. For each finding:

- **Agree:** make the smallest fix, for the case that actually happens. Prefer deleting or narrowing code over adding a lock, timer, flag, cache, helper or option. Add one focused test that fails without the fix when the request needs it. A blocker closes with a fix and evidence, never with a comment.
- **Disagree:** record why, with evidence such as a file and line, a test or command output.
- **Nit or out of scope:** decline it in one line and list it as a follow-up.
- **Blocker or should whose only fix touches a stated non-goal:** ask the user whether to fix it or accept the risk.

If the round grew the diff (check `git diff --shortstat <base>`), cut before the next round.

**Budget extension:** allow up to five rounds while a blocker or should stays open, with evidence, in security, permissions, auth, data loss, state or concurrency.

Over when every member returns `APPROVE`, or only nits you decline.

### Quality

Blind round with:

- `$CHECKS`: the code reads like the repository's style standard: flow, nesting, naming and guards.

Apply a finding when it brings the code closer to the style standard without changing behaviour. Where members disagree on taste, follow the style standard, then the surrounding code.

Over when every member returns `APPROVE`.

### Custom stages

When the user adds or replaces a stage, write its guideline into `request.md` before round 1, in the same shape as the built-in stages. Use deliberation rounds when members must weigh each other's views to reach one decision, and blind rounds when each member can review on their own. Take `$CHECKS` from the user's description, and borrow the handling and end condition from the closest built-in stage. Ask the user when that isn't clear.
