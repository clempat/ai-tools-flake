# Openchamber Shared Access (OpenCode Only)

## TL;DR
> **Summary**: Add minimal OpenChamber client wiring in ai-tools-flake so any machine using the flake can attach to the same shared backend and continue sessions.
> **Deliverables**:
> - New `programs.ai-tools.openchamber.*` options
> - OpenCode-only wiring in `modules/opencode.nix`
> - Validation + negative-case assertions
> - Smoke checks and usage docs
> **Effort**: Short
> **Parallel**: YES - 4 waves
> **Critical Path**: T1 -> T2 -> T3 -> T4

## Context
### Original Request
User wants to continue/take over sessions from any machine with ai-tools-flake, while avoiding conflicts with existing `opencode-ops-01` setup.

### Interview Summary
- Prior variant architecture was intentionally dropped as over-scoped.
- Scope is now minimal and OpenCode-only.
- Auth should be passed as a secret file path from consumer config (sops-compatible).
- Host runtime (`openchamber` service, proxy, vars generation) remains in nix-homelab.

### Metis Review (gaps addressed)
- Freeze exact option contract and env mapping before implementation.
- Add strict assertions for malformed config.
- Keep default behavior unchanged when feature disabled.
- Block scope creep into service/proxy/container/secrets generation.

## Work Objectives
### Core Objective
Enable shared OpenChamber-backed session continuity on any machine consuming ai-tools-flake, via additive options and OpenCode config wiring only.

### Deliverables
- New options in `modules/ai-tools.nix`:
  - `programs.ai-tools.openchamber.enable` (bool, default `false`)
  - `programs.ai-tools.openchamber.url` (string, required when enabled)
  - `programs.ai-tools.openchamber.authSecretFile` (absolute path string, required when enabled)
- OpenCode wiring in `modules/opencode.nix` to expose OpenChamber runtime settings/env from those options.
- Assertions: enabled+missing URL/secret path, non-absolute secret path, invalid URL format.
- Smoke checks + README snippet for multi-machine setup.

### Definition of Done (verifiable conditions with commands)
- `grep -n "programs.ai-tools.openchamber" modules/ai-tools.nix` returns option definitions.
- `grep -n "openchamber" modules/opencode.nix` returns OpenCode-only mapping points.
- `nix flake check -L` exits 0.
- Invalid sample config (enabled + bad path/url) fails with explicit assertion errors.

### Must Have
- Additive options only; backward-compatible defaults (`enable = false`).
- OpenCode-only integration path.
- Secret **path** handling only (no reading secret content into Nix store).
- Clear cross-machine usage docs.

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- No `systemd.services.openchamber` changes in ai-tools-flake.
- No caddy/proxy/podman/firewall changes in ai-tools-flake.
- No clan/sops generators added to ai-tools-flake.
- No new variant framework in this scope.

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after with eval/build smoke checks.
- QA policy: every task includes happy and failure scenarios.
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`.

## Execution Strategy
### Parallel Execution Waves
> Target: maximize safe parallelism after contract freeze.

Wave 1: contract freeze
Wave 2: option surface
Wave 3: OpenCode wiring
Wave 4: checks/docs + guardrail negatives

### Dependency Matrix (full, all tasks)
| Task | Depends On | Blocks |
|---|---|---|
| T1 Contract freeze | - | T2,T3,T5 |
| T2 Option surface | T1 | T3,T4 |
| T5 Guardrail negatives | T1,T2,T3 | - |
| T3 OpenCode wiring | T1,T2 | T4,T5 |
| T4 Smoke checks + docs | T2,T3 | - |

### Agent Dispatch Summary (wave -> task count -> categories)
- Wave 1 -> 1 -> `deep`
- Wave 2 -> 1 -> `deep`
- Wave 3 -> 1 -> `deep`
- Wave 4 -> 2 -> `writing`, `unspecified-high`

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [ ] 1. Freeze minimal OpenChamber contract

  **What to do**: Define exact option names/types/defaults, env mapping keys, and assertion rules. Record hard non-goals (no host runtime infra).
  **Must NOT do**: Do not decide service deployment logic in this repo.

  **Recommended Agent Profile**:
  - Category: `deep` — Reason: contract errors cascade to all tasks.
  - Skills: [`nixos-advisor`] — precise Nix option/assertion design.
  - Omitted: [`playwright`] — no UI/browser.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 2,3,5 | Blocked By: none

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `modules/ai-tools.nix` — option namespace and `mkOption` style.
  - Pattern: `modules/opencode.nix` — current OpenCode settings/env composition.
  - Scope source: `../nix-homelab/machines/opencode-ops-01/configuration.nix` — host responsibilities to exclude.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -n "options\.programs\.ai-tools" modules/ai-tools.nix` succeeds.
  - [ ] `grep -n "programs\.opencode\.settings" modules/opencode.nix` succeeds.
  - [ ] Contract artifact created at `.sisyphus/evidence/task-1-contract.txt` with option names and env keys.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path contract lock
    Tool: Bash
    Steps: Extract option and opencode anchor lines with grep and write decided contract/env mapping into `.sisyphus/evidence/task-1-contract.txt`.
    Expected: Contract file includes `enable`, `url`, `authSecretFile`, defaults, and non-goals.
    Evidence: .sisyphus/evidence/task-1-contract.txt

  Scenario: Failure/edge case scope creep
    Tool: Bash
    Steps: Grep `../nix-homelab/machines/opencode-ops-01/configuration.nix` for `systemd\.services\.openchamber|caddy|podman|sops|clan` and list as excluded.
    Expected: Excluded classes are explicitly marked out-of-scope in evidence.
    Evidence: .sisyphus/evidence/task-1-contract-error.txt
  ```

  **Commit**: NO | Message: `n/a` | Files: n/a

- [ ] 2. Add `programs.ai-tools.openchamber.*` option surface

  **What to do**: Implement options in `modules/ai-tools.nix` with defaults and typing; make URL/secret path conditionally required when enabled.
  **Must NOT do**: Do not read secret file contents in Nix eval; handle path only.

  **Recommended Agent Profile**:
  - Category: `deep` — Reason: public API for consumers.
  - Skills: [`nixos-advisor`] — conditional assertions and option types.
  - Omitted: [`quick`] — not trivial due validation and compat requirements.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 3,4 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `modules/ai-tools.nix` existing option declarations under `programs.ai-tools.*`.
  - Constraint: `.sisyphus/plans/openchamber-shared-access.md` Must NOT section.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -n "programs\.ai-tools\.openchamber" modules/ai-tools.nix` returns definitions.
  - [ ] `grep -n "authSecretFile" modules/ai-tools.nix` returns path option and assertions.
  - [ ] `nix eval --impure --expr 'let f=builtins.getFlake (toString ./.); in builtins.isFunction f.homeManagerModules.default'` returns `true`.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path option evaluation
    Tool: Bash
    Steps: Evaluate minimal config with `openchamber.enable = false`; capture output in `.sisyphus/evidence/task-2-options.txt`.
    Expected: Evaluation succeeds; defaults preserve baseline.
    Evidence: .sisyphus/evidence/task-2-options.txt

  Scenario: Failure/edge case invalid secret path
    Tool: Bash
    Steps: Evaluate config with `openchamber.enable = true` and relative `authSecretFile`; capture stderr.
    Expected: Evaluation fails with clear absolute-path assertion message.
    Evidence: .sisyphus/evidence/task-2-options-error.txt
  ```

  **Commit**: YES | Message: `feat(ai-tools): add openchamber client options` | Files: `modules/ai-tools.nix`

- [ ] 3. Wire OpenChamber options into OpenCode only

  **What to do**: Map enabled options into `programs.opencode.settings`/env in `modules/opencode.nix`; keep behavior unchanged when disabled.
  **Must NOT do**: Do not touch Claude Desktop/Codex wiring in this scope.

  **Recommended Agent Profile**:
  - Category: `deep` — Reason: central runtime config path with regression risk.
  - Skills: [`nixos-advisor`] — module composition and mkIf patterns.
  - Omitted: [`frontend-ui-ux`] — irrelevant.

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: 4,5 | Blocked By: 1,2

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `modules/opencode.nix` `programs.opencode.settings` assignment.
  - Pattern: `modules/opencode.nix` existing assertions style (unknown MCP assertion).
  - API: new options from `modules/ai-tools.nix` task 2.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -n "openchamber" modules/opencode.nix` returns new mapping lines.
  - [ ] `grep -n "programs\.opencode\.settings" modules/opencode.nix` still returns single coherent settings block.
  - [ ] Baseline eval with `openchamber.enable = false` remains successful.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path shared backend wiring
    Tool: Bash
    Steps: Evaluate config with `openchamber.enable = true`, valid URL, and absolute `authSecretFile`; inspect generated opencode settings attr.
    Expected: Settings include OpenChamber endpoint/auth-file path mapping.
    Evidence: .sisyphus/evidence/task-3-wiring.txt

  Scenario: Failure/edge case malformed URL
    Tool: Bash
    Steps: Evaluate config with `url = "not-a-url"`; capture stderr.
    Expected: Evaluation fails with URL-format assertion message.
    Evidence: .sisyphus/evidence/task-3-wiring-error.txt
  ```

  **Commit**: YES | Message: `feat(opencode): wire openchamber shared-session config` | Files: `modules/opencode.nix`

- [ ] 4. Add smoke checks and multi-machine docs

  **What to do**: Add/extend flake checks so `nix flake check -L` covers this integration, and document cross-machine usage with sops secret-path handoff.
  **Must NOT do**: Do not publish real secrets in docs/examples.

  **Recommended Agent Profile**:
  - Category: `writing` — Reason: checks + user guidance.
  - Skills: [`nixos-advisor`] — accurate Nix snippets/check commands.
  - Omitted: [`artistry`] — conventional docs/check update.

  **Parallelization**: Can Parallel: YES | Wave 4 | Blocks: none | Blocked By: 2,3

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `flake.nix` perSystem outputs and check wiring area.
  - Pattern: `README.md` Home Manager usage/config sections.
  - Example host context: `../nix-homelab/machines/opencode-ops-01/configuration.nix` (for boundary note only).

  **Acceptance Criteria** (agent-executable only):
  - [ ] `nix flake check -L` exits 0.
  - [ ] `grep -n "openchamber" README.md` finds setup snippet.
  - [ ] `grep -n "OpenCode only\|host-side" README.md` finds scope boundary note.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path checks and docs
    Tool: Bash
    Steps: Run `nix flake check -L`; grep README lines for example and boundary note; store outputs.
    Expected: Checks pass and docs include multi-machine config snippet.
    Evidence: .sisyphus/evidence/task-4-checks-docs.txt

  Scenario: Failure/edge case doc leakage
    Tool: Bash
    Steps: `grep -n "OPENCHAMBER_UI_PASSWORD\|Bearer\|secret-value" README.md`.
    Expected: No real secret values present in documentation.
    Evidence: .sisyphus/evidence/task-4-checks-docs-error.txt
  ```

  **Commit**: YES | Message: `docs(nix): document shared openchamber setup` | Files: `flake.nix`, `README.md`

- [ ] 5. Add guardrail negative tests for scope and assertions

  **What to do**: Add explicit failing eval checks for invalid config and file-touch guardrails to ensure only intended module/docs files changed.
  **Must NOT do**: Do not make these checks depend on network or external services.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: policy hardening and failure validation.
  - Skills: [`nixos-advisor`] — robust failing-assertion test patterns.
  - Omitted: [`deep`] — heavy architecture not required here.

  **Parallelization**: Can Parallel: YES | Wave 4 | Blocks: none | Blocked By: 1,2,3

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: assertion style in `modules/opencode.nix` and task 2 option assertions.
  - Scope target files: `modules/ai-tools.nix`, `modules/opencode.nix`, `flake.nix`, `README.md`.

  **Acceptance Criteria** (agent-executable only):
  - [ ] Invalid URL/path eval commands fail with deterministic assertion text.
  - [ ] `git diff --name-only` during execution touches only planned files.
  - [ ] `grep -R -n "systemd\.services\.openchamber\|services\.caddy\|virtualisation\.oci-containers" modules` yields no new additions.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path guardrails pass
    Tool: Bash
    Steps: Run file-touch and scope grep checks after implementation.
    Expected: Only planned files touched; no host-runtime keys added.
    Evidence: .sisyphus/evidence/task-5-guardrails.txt

  Scenario: Failure/edge case bad config fails
    Tool: Bash
    Steps: Run evals for missing URL, bad URL, relative secret path with `enable = true`.
    Expected: All fail with clear assertion reasons.
    Evidence: .sisyphus/evidence/task-5-guardrails-error.txt
  ```

  **Commit**: YES | Message: `test(nix): add openchamber validation guardrails` | Files: `flake.nix` (checks), `modules/*` assertions

## Final Verification Wave (4 parallel agents, ALL must APPROVE)
- [ ] F1. Plan Compliance Audit — oracle
- [ ] F2. Code Quality Review — unspecified-high
- [ ] F3. Real Manual QA — unspecified-high (+ playwright if UI)
- [ ] F4. Scope Fidelity Check — deep

## Commit Strategy
- Commit 1: option contract + `modules/ai-tools.nix` options.
- Commit 2: `modules/opencode.nix` wiring + assertions.
- Commit 3: checks/docs/guardrail tests.

## Success Criteria
- Any ai-tools-flake machine can point OpenCode to shared OpenChamber and continue sessions.
- Existing `opencode-ops-01` host setup remains untouched/conflict-free.
- Misconfiguration fails early with explicit assertion messages.
- `nix flake check -L` passes.
