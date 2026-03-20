# Openchamber Variant Exposure in ai-tools-flake

## TL;DR
> **Summary**: Add a first-class `programs.ai-tools.variant` selector in ai-tools-flake so consumers can choose `default` or `ops01` config profiles without importing host-coupled nix-homelab machine logic.
> **Deliverables**:
> - Variant option and validation contract in ai-tools module
> - Variant config asset layout (`default`, `ops01`) for opencode inputs
> - Refactored opencode module consuming selected variant assets
> - Eval/build smoke checks for both variants
> - Migration/usage docs for nix-homelab and other consumers
> **Effort**: Medium
> **Parallel**: YES - 4 waves
> **Critical Path**: T1 -> T2 -> T4 -> T5

## Context
### Original Request
User wants openchamber-related config in this ai flake while reusing ideas from `~/workspace/nix-homelab` `opencode-ops-01` special setup, and asked how to expose/select which config is active.

### Interview Summary
- Scope fixed to config variants only in ai-tools-flake.
- Service/proxy/secrets stay in host repo (`nix-homelab`), out of this change.
- Selection interface fixed to `programs.ai-tools.variant`.
- Compatibility policy: breaking cleanup allowed.
- Verification policy: eval/build smoke checks (no full test framework bootstrap).

### Metis Review (gaps addressed)
- Add explicit unknown-variant hard failure.
- Preserve behavior through explicit `default` variant fixture.
- Prevent scope creep into host infra (systemd, caddy, podman, sops/clan vars).
- Avoid imports from nix-homelab paths; keep ai-tools-flake self-contained.

## Work Objectives
### Core Objective
Make variant selection decision-complete for opencode config assets inside ai-tools-flake via one option (`programs.ai-tools.variant`) and two concrete variants (`default`, `ops01`).

### Deliverables
- Module option: `programs.ai-tools.variant` with strict validation.
- Variant asset structure for agents/mcps/providers/memory.
- `modules/opencode.nix` switched from hardcoded `../config/*.nix` to selected variant payload.
- Flake-level smoke checks verifying both variants evaluate/build.
- Usage docs and migration notes.

### Definition of Done (verifiable conditions with commands)
- `grep -n "programs.ai-tools.variant" modules/ai-tools.nix` returns option definition.
- `grep -n "assert.*variant" modules/opencode.nix` returns unknown-variant guard.
- `grep -R -n "config/variants/default\|config/variants/ops01" config modules` returns references.
- `nix flake check -L` exits 0 with variant checks passing.

### Must Have
- Explicit `default` and `ops01` variant keys.
- Unknown variant key fails evaluation with clear assertion message.
- No host-level logic copied from `nix-homelab` machine config.
- Day-1 variant semantics: `ops01` differs from `default` on `agents`, `mcps`, and `memoryPath` only; `providers` stays identical to `default`.
- Clear consumer usage snippet using `programs.ai-tools.variant`.

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- No systemd/openchamber service module additions in ai-tools-flake.
- No caddy/proxy/firewall/container changes in ai-tools-flake.
- No secrets/clan/sops path assumptions embedded in variant assets.
- No silent fallback when variant key is invalid.

## Verification Strategy
> ZERO HUMAN INTERVENTION — all verification is agent-executed.
- Test decision: tests-after, Nix eval/build smoke checks.
- QA policy: every task includes happy + failure scenario with explicit evidence artifact.
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`.

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extracted shared dependency work into Wave 1 to maximize later parallelism.

Wave 1: contract and boundaries
Wave 2: option surface + variant asset creation
Wave 3: opencode module rewiring
Wave 4: checks and docs

### Dependency Matrix (full, all tasks)
| Task | Depends On | Blocks |
|---|---|---|
| T1 contract | - | T2,T3 |
| T2 variant option | T1 | T4 |
| T3 variant assets | T1 | T4 |
| T4 module wiring | T2,T3 | T5,T6 |
| T5 smoke checks | T4 | - |
| T6 docs + migration | T4 | - |

### Agent Dispatch Summary (wave -> task count -> categories)
- Wave 1 -> 1 -> `deep`
- Wave 2 -> 2 -> `deep`, `deep`
- Wave 3 -> 1 -> `deep`
- Wave 4 -> 2 -> `unspecified-high`, `writing`

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task includes: Agent Profile + Parallelization + QA Scenarios.

- [ ] 1. Lock variant contract and boundaries

  **What to do**: Define exact variant keys (`default`, `ops01`), unknown-key failure behavior, and strict scope boundary (config assets only). Decide canonical asset shape: `{ agents, mcps, providers, memoryPath }`.
  **Must NOT do**: Do not include any host/runtime concerns (systemd, caddy, podman, firewall, sops/clan vars).

  **Recommended Agent Profile**:
  - Category: `deep` — Reason: module contract and boundary decisions impact all downstream tasks.
  - Skills: [`nixos-advisor`] — helps with robust Nix option/attrset contract design.
  - Omitted: [`frontend-ui-ux`, `playwright`] — no UI/browser work.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 2,3 | Blocked By: none

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `modules/ai-tools.nix` — top-level option namespace for `programs.ai-tools.*`.
  - Pattern: `modules/opencode.nix` — current hardcoded config ingestion and assertions style.
  - Scope boundary source: `../nix-homelab/machines/opencode-ops-01/configuration.nix` — host-specific logic to keep out.
  - API/Type: `config/agents.nix`, `config/mcps.nix`, `config/providers.nix`, `config/memory.md` — current asset inputs.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -n "programs.ai-tools" modules/ai-tools.nix` confirms option placement context.
  - [ ] `grep -n "import ../config/" modules/opencode.nix` confirms current ingestion points identified.
  - [ ] `! grep -R -n "services\\.|caddy\\|podman\\|virtualisation\\.|networking\\.firewall\\|sops\\|clan" modules` succeeds.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path contract freeze
    Tool: Bash
    Steps: Run `grep -n "programs.ai-tools" modules/ai-tools.nix` and `grep -n "import ../config/" modules/opencode.nix`; record selected contract keys in `.sisyphus/evidence/task-1-contract.txt`.
    Expected: Evidence file lists `default`, `ops01`, payload shape, and unknown-key hard-fail decision.
    Evidence: .sisyphus/evidence/task-1-contract.txt

  Scenario: Failure/edge case (scope creep)
    Tool: Bash
    Steps: Run `grep -n "services\.|caddy\|podman\|sops\|clan" ../nix-homelab/machines/opencode-ops-01/configuration.nix`; copy matches into `.sisyphus/evidence/task-1-contract-error.txt` as excluded classes.
    Expected: Evidence explicitly marks these classes as OUT-OF-SCOPE for ai-tools-flake variant work.
    Evidence: .sisyphus/evidence/task-1-contract-error.txt
  ```

  **Commit**: NO | Message: `n/a` | Files: n/a

- [ ] 2. Add `programs.ai-tools.variant` option in `modules/ai-tools.nix`

  **What to do**: Implement new option `programs.ai-tools.variant` with default `"default"` and docs listing allowed keys. Thread value into opencode module consumption path (`cfg.variant`).
  **Must NOT do**: Do not silently coerce/normalize unknown names; no fallback other than explicit default.

  **Recommended Agent Profile**:
  - Category: `deep` — Reason: option API change affects all consumers.
  - Skills: [`nixos-advisor`] — correct HM option schema + docs strings.
  - Omitted: [`git-master`] — no git operations needed for implementation task body.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 4 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `modules/ai-tools.nix` — existing `mkOption` usage for `programs.ai-tools.opencode.*`.
  - Pattern: `modules/opencode.nix` — consumes `cfg = config.programs.ai-tools`.
  - Guardrail: `.sisyphus/plans/openchamber-variant-exposure.md` — Must NOT section.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -n "programs.ai-tools.variant" modules/ai-tools.nix` returns exactly one option definition.
  - [ ] `grep -n "default = \"default\"" modules/ai-tools.nix` confirms explicit default.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path option exists
    Tool: Bash
    Steps: Run `grep -n "programs.ai-tools.variant" modules/ai-tools.nix` and `grep -n "default = \"default\"" modules/ai-tools.nix`; save to `.sisyphus/evidence/task-2-option.txt`.
    Expected: Both matches found and evidence includes line outputs.
    Evidence: .sisyphus/evidence/task-2-option.txt

  Scenario: Failure/edge case unknown variant
    Tool: Bash
    Steps: Evaluate a minimal module config setting `programs.ai-tools.variant = "nope"`; run `nix eval`/`nix-instantiate` command used by repo and capture error to `.sisyphus/evidence/task-2-option-error.txt`.
    Expected: Evaluation fails with clear variant assertion message.
    Evidence: .sisyphus/evidence/task-2-option-error.txt
  ```

  **Commit**: YES | Message: `refactor(ai-tools): add variant selector option` | Files: `modules/ai-tools.nix`

- [ ] 3. Create variant asset layout for `default` and `ops01`

  **What to do**: Introduce variant asset files under `config/variants/default/` and `config/variants/ops01/` (agents, mcps, providers, memory). Keep `default` behavior equivalent to current baseline by reusing or copying existing assets intentionally; set `ops01` providers equal to default providers on day 1.
  **Must NOT do**: No imports from `~/workspace/nix-homelab`; no embedded machine-specific domains, secret paths, or runtime services.

  **Recommended Agent Profile**:
  - Category: `deep` — Reason: data modeling and boundary safety.
  - Skills: [`nixos-advisor`] — Nix attrset composition and import strategy.
  - Omitted: [`writing`] — this is config implementation, not docs-only.

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 4 | Blocked By: 1

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `config/agents.nix`, `config/mcps.nix`, `config/providers.nix`, `config/memory.md` — baseline default payload.
  - Constraint: `../nix-homelab/machines/opencode-ops-01/configuration.nix` — examples of what must remain out of flake scope.
  - Guardrail: `modules/opencode.nix` expects data usable by MCP transforms and agent generation.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `test -f config/variants/default/agents.nix` and analogous checks for mcps/providers/memory pass.
  - [ ] `test -f config/variants/ops01/agents.nix` and analogous checks for mcps/providers/memory pass.
  - [ ] `diff -u config/variants/default/providers.nix config/variants/ops01/providers.nix` shows no differences.
  - [ ] `grep -R -n "mcp.patout.app\|sops\|clan\|/run/secrets" config/variants/ops01` returns only intentionally allowed endpoints and no secret-path coupling.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path assets present
    Tool: Bash
    Steps: Run file existence checks for all 8 variant files; write results to `.sisyphus/evidence/task-3-assets.txt`.
    Expected: All required files exist; exit code 0.
    Evidence: .sisyphus/evidence/task-3-assets.txt

  Scenario: Failure/edge case host coupling leak
    Tool: Bash
    Steps: Run `grep -R -n "services\.|virtualisation\.|users\.users\|networking\.firewall\|sops\|clan" config/variants`; save matches (if any) to `.sisyphus/evidence/task-3-assets-error.txt`.
    Expected: No host-level keys found in variant assets.
    Evidence: .sisyphus/evidence/task-3-assets-error.txt
  ```

  **Commit**: YES | Message: `feat(config): add default and ops01 variant assets` | Files: `config/variants/**`

- [ ] 4. Refactor `modules/opencode.nix` to consume selected variant payload

  **What to do**: Replace hardcoded `../config/*.nix` imports with variant-resolved imports keyed by `cfg.variant`; rename personal-prefixed locals to neutral names; keep existing MCP transform, routing, and agent-generation behavior unchanged.
  **Must NOT do**: Do not alter tool transform semantics (`http`->`remote`, `stdio`->`local`) or modify unrelated opencode settings.

  **Recommended Agent Profile**:
  - Category: `deep` — Reason: highest regression risk and central module logic.
  - Skills: [`nixos-advisor`] — safe module rewiring with assertions.
  - Omitted: [`artistry`] — conventional refactor, no unconventional approach needed.

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: 5,6 | Blocked By: 2,3

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `modules/opencode.nix` — current locals (`baseMcpServers`, `personalAgents`, `personalProviders`, `personalMemory`).
  - API/Type: `programs.ai-tools.variant` from `modules/ai-tools.nix`.
  - Test: current assertion style in `modules/opencode.nix` for enabled MCP names.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -n "import ../config/" modules/opencode.nix` no longer matches hardcoded direct imports for agents/mcps/providers/memory.
  - [ ] `grep -n "assert.*variant" modules/opencode.nix` shows unknown variant guard.
  - [ ] `nix eval --impure --expr 'let f=builtins.getFlake (toString ./.); in builtins.isFunction f.homeManagerModules.default'` returns `true`.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path default + ops01 eval
    Tool: Bash
    Steps: Run two evals with minimal HM configs, one with `variant = "default"`, one with `variant = "ops01"`; save outputs to `.sisyphus/evidence/task-4-wiring.txt`.
    Expected: Both evaluations succeed; generated settings attrs include provider/mcp/agent data.
    Evidence: .sisyphus/evidence/task-4-wiring.txt

  Scenario: Failure/edge case invalid key
    Tool: Bash
    Steps: Evaluate with `variant = "invalid"`; capture stderr to `.sisyphus/evidence/task-4-wiring-error.txt`.
    Expected: Evaluation fails with explicit unknown variant message.
    Evidence: .sisyphus/evidence/task-4-wiring-error.txt
  ```

  **Commit**: YES | Message: `refactor(opencode): load assets from selected variant` | Files: `modules/opencode.nix`

- [ ] 5. Add flake smoke checks for variant evaluation

  **What to do**: Add `checks` in `flake.nix` for both `default` and `ops01` variant eval/build smoke assertions so CI/local `nix flake check` validates variant wiring.
  **Must NOT do**: Do not add long-running integration tests or external-network-dependent checks.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` — Reason: Nix check wiring across outputs, moderate risk.
  - Skills: [`nixos-advisor`] — flake checks patterns.
  - Omitted: [`quick`] — non-trivial due check wiring and reproducibility constraints.

  **Parallelization**: Can Parallel: YES | Wave 4 | Blocks: none | Blocked By: 4

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `flake.nix` — existing `perSystem` outputs currently lacking checks.
  - API/Type: `homeManagerModules.default` exposure in `flake.nix`.
  - Dependency: variant assertion paths in `modules/opencode.nix`.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -n "checks" flake.nix` confirms new checks output.
  - [ ] `nix flake check -L` exits 0.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path check pass
    Tool: Bash
    Steps: Run `nix flake check -L` and store log in `.sisyphus/evidence/task-5-checks.log`.
    Expected: Exit code 0; both variant checks executed and passed.
    Evidence: .sisyphus/evidence/task-5-checks.log

  Scenario: Failure/edge case regression catch
    Tool: Bash
    Steps: Temporarily simulate invalid variant in check input (or run targeted eval with invalid key) and capture failure output to `.sisyphus/evidence/task-5-checks-error.log`.
    Expected: Check/eval fails deterministically with variant assertion.
    Evidence: .sisyphus/evidence/task-5-checks-error.log
  ```

  **Commit**: YES | Message: `test(flake): add variant smoke checks` | Files: `flake.nix`

- [ ] 6. Document usage and migration path

  **What to do**: Update README/docs for variant selection with concrete snippet, explain `default` vs `ops01`, and document explicit out-of-scope boundary (host services/secrets remain in nix-homelab).
  **Must NOT do**: Do not document unsupported variants or imply ai-tools-flake manages openchamber runtime service.

  **Recommended Agent Profile**:
  - Category: `writing` — Reason: docs precision and migration clarity.
  - Skills: [] — existing repo conventions sufficient.
  - Omitted: [`nixos-advisor`] — optional; not required for prose-only output.

  **Parallelization**: Can Parallel: YES | Wave 4 | Blocks: none | Blocked By: 4

  **References** (executor has NO interview context — be exhaustive):
  - Pattern: `README.md` usage sections for Home Manager import and options.
  - Scope boundary source: `../nix-homelab/machines/opencode-ops-01/configuration.nix` (host responsibilities stay there).
  - Option/API: `modules/ai-tools.nix` `programs.ai-tools.variant`.

  **Acceptance Criteria** (agent-executable only):
  - [ ] `grep -n "programs.ai-tools.variant" README.md` finds concrete snippet.
  - [ ] `grep -n "out of scope\|host-side\|nix-homelab" README.md` finds boundary note.

  **QA Scenarios** (MANDATORY — task incomplete without these):
  ```text
  Scenario: Happy path docs complete
    Tool: Bash
    Steps: Run grep commands above; save output to `.sisyphus/evidence/task-6-docs.txt`.
    Expected: Snippet includes both `default` and `ops01` examples and boundary note exists.
    Evidence: .sisyphus/evidence/task-6-docs.txt

  Scenario: Failure/edge case docs drift
    Tool: Bash
    Steps: Search for misleading service ownership text via `grep -n "openchamber service\|systemd" README.md`; save to `.sisyphus/evidence/task-6-docs-error.txt`.
    Expected: No claim that ai-tools-flake manages host runtime services.
    Evidence: .sisyphus/evidence/task-6-docs-error.txt
  ```

  **Commit**: YES | Message: `docs(ai-tools): add variant usage and migration notes` | Files: `README.md`

## Final Verification Wave (4 parallel agents, ALL must APPROVE)
- [ ] F1. Plan Compliance Audit — oracle
- [ ] F2. Code Quality Review — unspecified-high
- [ ] F3. Real Manual QA — unspecified-high (+ playwright if UI)
- [ ] F4. Scope Fidelity Check — deep

## Commit Strategy
- Commit 1: `refactor(ai-tools): add variant contract and option surface`
- Commit 2: `refactor(opencode): consume variantized config assets`
- Commit 3: `test(nix): add variant smoke checks and docs`

## Success Criteria
- `programs.ai-tools.variant` is selectable and validated.
- `default` keeps baseline behavior; `ops01` is available and isolated from host infra.
- `nix flake check -L` passes variant smoke checks.
- Docs give exact consumer snippet for selection and migration notes.
