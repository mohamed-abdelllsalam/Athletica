# AGENTS.md — OpenCode instructions

## Authority

- Read `CLAUDE.md` at repo root at the start of every session and follow it. If this file conflicts with `CLAUDE.md`, flag it and follow the stricter rule.

## Skills

- Before scaffolding a feature, endpoint, cubit/bloc, or answering architecture questions: load the `flutter-feature` skill first. It holds the Clean Architecture reference (`Screen → Cubit → UseCase → RepoInterface → RepoImpl → DataSource → API`, DI/route checklists). Do not paste its templates from memory.
- Before marking any task done: load and run the `flutter-code-review` skill. Report PASS / NEEDS_CHANGES / BLOCKED; never claim a check passed if skipped or unavailable.
- If a required skill cannot be loaded, report it and get explicit approval before substituting.

## Specialists

- Role definitions live in `.codex/agents/{debugger,code-reviewer,test-writer,git-expert}.toml`. The `@name` labels in `CLAUDE.md` are those roles.
- Proactively suggest `debugger` (bugs/crashes), `test-writer` (new/changed code without tests), `code-reviewer` (after self-review passes, before PR), `git-expert` (branch/commit/PR, conflicts, rebases).
- Delegate only the relevant bounded work via subagents, passing the role file plus repo rules; wait for its result before claiming the step passed. Never silently substitute a generic agent without the role instructions.

## Commands

- `flutter pub get` — install deps (Dart SDK `^3.11.4`).
- `flutter analyze` — only static gate (repo uses `flutter_lints`, no custom rules).
- `flutter test test/path/to/file_test.dart` — single file; `flutter test --plain-name "<test name>"` — focused case.
- `flutter run --flavor dev -t lib/main_dev.dart` / `--flavor prod -t lib/main_prod.dart` — run (mirrors `.vscode/launch.json`).
- `scripts/distribute_dev.ps1` (+ `.sh` on macOS) / `distribute_prod.ps1` (ps1 only, no `.sh`) — release only: auto-bumps `pubspec.yaml` version, runs `clean → pub get → flutter build apk --flavor <dev|prod> --target lib/main_<dev|prod>.dart --release`, distributes via Firebase. Never run for a normal code change.
- No CI, `opencode.json`, or pre-commit hooks exist — local `analyze` + `test` are the only gates. Never claim CI ran a check.

## Flavors and env (easy to get wrong)

- `lib/main_dev.dart` loads `.env.dev` + `AppConfig.dev()`; `lib/main_prod.dart` loads `.env.prod` + `AppConfig.prod()`; both call `setupDependencies()` after `dotenv.load`. Keep the flavor ↔ target ↔ env file trio matched.
- `lib/athletica_app.dart` is the app root; `main_*.dart` files are thin bootstrap only.
- `.env.dev` / `.env.prod` are bundled Flutter assets (see `pubspec.yaml`) — never put secrets in them, never log their contents.

## Architecture (non-obvious only)

- Layout: `lib/core/{config,di,errors,network,services,utils,widgets,helper}/` + `lib/features/<feature>/{data,domain,presentation}/`. Data depends on domain, presentation depends on domain; domain depends on nothing and has zero `package:flutter/...` imports.
- Error contract: data layer catches exceptions → typed `Failure` (`lib/core/errors/`); domain/use-cases return `ApiResult<T>` (`lib/core/utils/api_result.dart`); presentation maps failures to UI messages. Never skip layers.
- DI lives in the single `lib/core/di/injection_container.dart` (`get_it`): lazy singletons for data sources/repos/use cases, factory for cubits — except intentional keep-alive singletons (`ProfileCubit`, `NutritionTemplatesListCubit`, `ProfileInfoCubit`). Resolve via `get_it`, never `new` feature deps manually.
- Shared code used in 2+ places — including twice inside one feature — goes in `core/`. Check `core/` before creating helpers.
- No Freezed / `build_runner` (absolute ban in `CLAUDE.md` — the stricter rule governs): sealed-class states, manual `fromJson`/`toJson`, Dio directly. Never add codegen or Retrofit.
- Controllers (`TextEditingController`, `FocusNode`, etc.) are created in `initState` — never as field initializers, never in `build()` — with matching `dispose()`; pair every `addListener` with `removeListener`; a caller-provided `transitionAnimationController` is disposed by the caller. Cubit-owned controllers are the exception and must be disposed in `close()` plus a disposal test. The `tool/check_controller_lifecycle.dart` script referenced by the review skill does not exist in this repo — report that check as unavailable instead of running it.

## Tests (corrected — read before writing)

- Only `flutter_test` is installed. `mocktail` / `bloc_test` are NOT dependencies and no test imports them — use hand-written fakes and exercise real use cases for state assertions. Check `pubspec.yaml` + existing `test/` imports before adding any test package. (Note: the `flutter-code-review` skill still mentions `mocktail`/`bloc_test` — that line is stale; `pubspec.yaml` is the source of truth.)
- `test/` currently holds only the default `test/widget_test.dart` smoke test — mirror `lib/` paths for new tests; widget tests must initialize `ScreenUtil` first (the app wraps everything in `ScreenUtilInit`).
- Bug fixes need a reproducing test; one behavior per test, deterministic, no timing dependence.

## Safety and git

- Smallest change that fixes the root cause; read relevant code first; don't refactor unrelated files or add packages without justification.
- Before destructive commands explain the effect and preserve work; get explicit authorization for discarding changes, history rewriting, or force-push. Push requires user confirmation. Branch/commit/PR conventions live in `.codex/agents/git-expert.toml` — delegate to it after task approval.
