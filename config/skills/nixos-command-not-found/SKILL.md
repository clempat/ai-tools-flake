---
name: nixos-command-not-found
description: Auto-install missing commands in NixOS environments. Detects NixOS, searches for packages containing the missing command, and re-runs with nix shell. Use when commands fail with "command not found" errors.
---

# NixOS Command Not Found Handler

Automatically handles "command not found" errors in NixOS environments by searching for packages and retrying with `nix shell`.

## When to Use

Activate this skill when:
- Command fails with "command not found" or "No such file or directory"
- User is in NixOS environment (detected by `/etc/nixos` existence or `NIX_STORE` env var)
- Command appears to be a standard Unix tool or known package

## Workflow

1. **Detect NixOS environment**: Check for `/etc/nixos` or `NIX_STORE` env var
2. **Extract command name**: Get the missing command from error output
3. **If error output already suggests a nix shell**: Run that exact command
4. **Else search locally**: Use `nix search nixpkgs <cmd>` and pick best match
5. **Run via nix shell**: `nix shell nixpkgs#<package> -c <original-command>`
6. **Delegate only if needed**: If no match or ambiguous, delegate to nixos agent

## Implementation Steps

### 1. Environment Detection
Check if we're in NixOS:
```bash
test -d /etc/nixos || test -n "$NIX_STORE"
```

### 2. Use Suggested nix shell (if present)
If the error output already includes a recommended `nix shell nixpkgs#... -c ...`, run it as-is.

### 3. Local Search + Run
Search locally and pick best match from plain text output:
```bash
nix search nixpkgs <cmd>
```
Selection order:
1. Exact attr path equals cmd
2. Attr path contains cmd
3. Description contains cmd

Then run:
```bash
nix shell nixpkgs#<package> -c <original-command>
```

### 4. Delegate When Needed
If no match or too many ambiguous results, delegate to nixos agent to resolve.

## Examples

### Missing `tree` command
1. User runs: `tree /some/path`
2. Error: `zsh: command not found: tree`
3. Detect NixOS environment ✓
4. Run `nix search nixpkgs tree`
5. Pick `tree` package, run `nix shell nixpkgs#tree -c tree /some/path`
6. Return: actual directory tree output

### Missing `jq` command
1. User runs: `cat data.json | jq '.name'`
2. Error: `command not found: jq`
3. Run `nix search nixpkgs jq`
4. Pick `jq` package, run with stdin preserved
5. Return: actual JSON parsing result

### Missing `cargo` command
1. User runs: `cargo build`
2. Error: `command not found: cargo`
3. Run `nix search nixpkgs cargo`
4. Pick `cargo` package, run `nix shell nixpkgs#cargo -c cargo build`
5. Return: actual build output or errors

### Suggested nix shell already provided
1. Error output includes: `use nix shell nixpkgs#ripgrep -c rg ...`
2. Run that exact command
3. Return command output

## Edge Cases

### Multiple Package Options
Try local selection order first. If still ambiguous, delegate to nixos agent.

### Complex Commands  
Nixos agent handles command complexity:
- Preserves pipes, redirects, and shell syntax
- Uses appropriate shell escaping when needed
- Maintains stdin/stdout/stderr as expected

### Already in Nix Shell
Still proceed (might need different package). Inform user about current nix shell context.

## Error Handling

### Package Not Found
If local search fails, delegate to nixos agent for broader search/fallbacks.

### Command Failures
Return actual command results. Distinguish between "package not found" vs "command failed".

## Integration Notes

### Detection Triggers
Monitor for these error patterns:
- `command not found: <cmd>`
- `<cmd>: No such file or directory`
- `zsh: command not found: <cmd>`
- `bash: <cmd>: command not found`

### Agent Responsibilities
Only delegate when local search fails or ambiguous. When delegated, nixos agent handles:
- Maintains current working directory
- Preserves environment variables
- Keeps stdin/stdout/stderr intact
- Shows what package was used
- Provides appropriate feedback

### Main Agent Role
- Detects NixOS environment
- Runs suggested nix shell if present
- Else runs local `nix search`
- Delegates only if needed
- Returns command results to user

## Configuration

### Excluded Commands
Don't handle these (likely typos or not packages):
- Single letters: `a`, `b`, `x`
- Common typos: `sl`, `gerp`
- Shell builtins that failed: `cd`, `export`

### Channel Preference
- Default to `nixpkgs#` (follows system channel)
- Could use `nixpkgs/unstable#` for newest versions
- Respect user's flake configuration if detected
