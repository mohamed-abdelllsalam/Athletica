# AGENTS.md

<!--
Golden Test: "Would removing this rule cause the agent to make mistakes?"
If not — cut it.
-->

---

## External File Loading — CRITICAL

The project's authoritative engineering rules live in `CLAUDE.md`.

You MUST read `CLAUDE.md` at the start of every session and follow all of its rules on every task.

* `CLAUDE.md` is mandatory and applies to all workflows in this project.
* If `CLAUDE.md` is modified during the project, treat its latest content as the source of truth.
* This file (`AGENTS.md`) only adds or refines OpenCode-specific behavior.
* Nothing in this file may weaken, override, or contradict `CLAUDE.md`.
* Do not duplicate rules from `CLAUDE.md` here unless they are necessary to explain OpenCode-specific behavior.

---

## OpenCode-Specific Workflow

### Skills

The workflow rules defined in `CLAUDE.md` remain mandatory.

In particular:

* Before creating a new feature, invoke the `/flutter-feature` skill.
* Before marking a task complete, run the `/flutter-code-review` skill.
* After the task is approved, use the `@git-expert` agent for branch, commit, and PR output.

If a required skill or command is unavailable in OpenCode:

* Do NOT silently skip it.
* Clearly inform the user that the required skill/command is unavailable.
* Continue only with the user's explicit approval when the missing step is required to proceed safely.

### Agents

Follow the proactive agent-selection rules from `CLAUDE.md`.

When the corresponding situation occurs, proactively suggest:

* `@debugger` for bugs, crashes, errors, or unexpected behavior.
* `@code-reviewer` after `/flutter-code-review` passes, before proceeding to PR.
* `@test-writer` when code is added/changed without appropriate tests or coverage is missing.
* `@git-expert` for branches, commits, PRs, merge conflicts, rebases, or complex Git operations.

Do not replace a required agent with an unrelated workflow unless the user explicitly requests it.

---

## Repository Instruction Precedence

When working in this repository:

1. Follow the applicable repository instructions.
2. `CLAUDE.md` is the authoritative project rule set.
3. This `AGENTS.md` only provides OpenCode-specific interpretation and workflow behavior.
4. Never weaken a rule from `CLAUDE.md`.

When instructions conflict, preserve the stricter requirement and flag the conflict instead of silently ignoring it.

---

## Change Discipline

OpenCode must follow the same engineering discipline defined in `CLAUDE.md`:

* Inspect relevant existing code before making changes.
* Prefer the smallest correct change.
* Fix root causes rather than symptoms.
* Do not perform unrelated refactors.
* Do not introduce new architecture, dependencies, abstractions, or patterns without justification.
* Preserve existing behavior, APIs, and UX unless the task explicitly requires a change.

---

## Final Verification

Before considering a task complete:

* Verify that the implementation satisfies `CLAUDE.md`.
* Run the required tests relevant to the change.
* Run `/flutter-code-review` when required.
* If the required review skill is unavailable, explicitly tell the user instead of silently skipping it.
* If code was changed and tests are missing, follow the `@test-writer` rule from `CLAUDE.md`.
* Do not claim a task is complete when a mandatory verification step has not been performed.

---

## Git / PR Workflow

Do not independently invent a branch, commit, or PR workflow when `@git-expert` is required.

When the task reaches the Git stage:

1. Suggest/use `@git-expert` according to `CLAUDE.md`.
2. Let `@git-expert` handle branch, commit, and PR-related decisions.
3. Preserve the project's existing Git conventions.
4. Do not rewrite history, force-push, or perform destructive Git operations without explicit authorization.

---

## Important

`CLAUDE.md` remains the primary source of truth for:

* Architecture
* Flutter/Dart conventions
* State management
* Layer boundaries
* Dependency injection
* Error handling
* Testing
* Security
* Feature structure
* Build-method discipline
* Required skills
* Required agents

Do not copy those rules into this file. Read and follow `CLAUDE.md` instead.
