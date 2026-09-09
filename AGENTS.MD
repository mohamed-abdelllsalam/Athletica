# Codex instructions for this Flutter project

## Authoritative rules

Read `CLAUDE.md` at the repository root at the beginning of every session and follow its latest content. It remains the engineering source of truth. This file translates its workflow to Codex; it does not weaken its rules. If a conflict remains, flag it and preserve the stricter requirement within the instruction hierarchy.

## Skills and completion

- Before a new feature, load and follow `.agents/skills/flutter-feature/SKILL.md` (Codex skill: `$flutter-feature`).
- Before marking any task complete, load and run `.agents/skills/flutter-code-review/SKILL.md` (Codex skill: `$flutter-code-review`). The slash names in CLAUDE.md refer to these same workflows.
- Read relevant existing code first. Keep changes minimal and run relevant checks. Do not claim a mandatory check passed if it was skipped or unavailable.
- If a required skill or specialist cannot be found, report the missing item. Do not silently replace it; get explicit approval for a substitute when the required step cannot be performed.

## Specialist agents

The `@name` labels in CLAUDE.md identify roles, not Codex slash commands. Their definitions are in `.codex/agents/{name}.toml`.

- Proactively suggest `debugger` for bugs, crashes, errors, or unexpected behavior.
- After the self-review passes, always suggest `code-reviewer` for an independent review before a PR.
- Proactively suggest `test-writer` for new or changed code without corresponding tests or missing coverage. Delegate creation of `*_test.dart` files to `test-writer`, preserving the project settings hook's intent. If it is unavailable, disclose that and obtain approval before substituting direct authorship.
- Proactively suggest `git-expert` at the branch, commit, or PR stage and for conflicts, rebases, or complex Git work. After task approval, use it for branch, commit, and PR output.
- A suggestion is not an instruction to launch all agents. Delegate only the relevant bounded work when required by these rules or requested by the user. Pass the role definition and the repository rules to the specialist. Wait for its result before claiming its step passed.
- Do not silently substitute a generic agent that has not received the required role instructions.

## Clarifications from the supplied updates

- Architectural call flow is presentation → domain contracts → data implementation. Source dependencies point presentation → domain ← data; domain never imports data or Flutter.
- The shared-code threshold in CLAUDE.md is **two or more places**, including within one feature.
- Follow the controller/listener lifecycle checklist in the review skill. Prefer widget ownership; exceptional Cubit/Bloc ownership requires disposal in `close()` and a disposal test.
- Use the existing `mocktail` conventions and `bloc_test` for Cubit/Bloc transition tests; inspect the dependency file and existing tests first.
- Do not run the archived build_runner reminder. It conflicts with CLAUDE.md's explicit ban on Freezed/build_runner.
- Before destructive commands, explain the effect and preserve existing work. Obtain explicit authorization for discarding work, history rewriting, and force-pushing. Pushing requires user confirmation; an explicit push authorization already given for the same action satisfies that requirement.

## Permission boundary

These are workflow instructions, not executable tool restrictions. They do not grant permissions or override Codex sandbox, organization policy, or user authorization. The original Claude Write/Edit hooks are not installed by this package.
