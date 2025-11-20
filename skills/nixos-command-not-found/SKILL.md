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
3. **Search packages**: Use `nixos_search` to find packages containing the command
4. **Select best match**: Choose most relevant package (prefer exact name matches)
5. **Retry with nix shell**: Run `nix shell nixpkgs#<package> -c <original-command>`

## Implementation Steps

### 1. Environment Detection
Check if we're in NixOS:
```bash
test -d /etc/nixos || test -n "$NIX_STORE"
```

### 2. Package Search
Use nixos MCP to find packages:
```
nixos_search(query="<command-name>", search_type="packages", limit=10)
```

### 3. Package Selection Logic
- Exact name match: `command == package.name`
- Contains command: `command in package.name`
- Description match: Look for command in description
- Prefer shorter package names (likely more direct)

### 4. Command Retry
Execute with nix shell:
```bash
nix shell nixpkgs#<selected-package> -c <original-command> [args...]
```

## Examples

### Missing `tree` command
1. User runs: `tree /some/path`
2. Error: `zsh: command not found: tree`
3. Detect NixOS environment ✓
4. Search: `nixos_search(query="tree", search_type="packages")`
5. Find: `tree` package (exact match)
6. Retry: `nix shell nixpkgs#tree -c tree /some/path`

### Missing `jq` command
1. User runs: `cat data.json | jq '.name'`
2. Error: `command not found: jq`
3. Search: `nixos_search(query="jq", search_type="packages")`
4. Find: `jq` package
5. Retry: `nix shell nixpkgs#jq -c jq '.name'` (with stdin preserved)

### Missing `cargo` command
1. User runs: `cargo build`
2. Error: `command not found: cargo`
3. Search finds: `cargo`, `rust`, `rustup`
4. Select: `cargo` (exact match preferred)
5. Retry: `nix shell nixpkgs#cargo -c cargo build`

## Edge Cases

### Multiple Package Options
When multiple packages contain the command:
- Prefer exact name matches
- Prefer shorter names (e.g., `git` over `git-full`)
- Show user the options and ask for confirmation if ambiguous

### Complex Commands
For commands with pipes or redirects:
- Preserve full command structure
- Use shell escaping: `nix shell nixpkgs#<pkg> -c sh -c '<full-command>'`

### Already in Nix Shell
If `$IN_NIX_SHELL` is set:
- Still proceed (user might want different package)
- Inform user they're already in nix shell

## Error Handling

### Package Not Found
- Try broader search terms (remove version numbers, suffixes)
- Suggest manual search: "Try: nix search nixpkgs <command>"
- Offer to search programs: `nixos_search(query="<command>", search_type="programs")`

### Multiple Failures
- Keep track of attempted packages
- Don't retry same package twice
- Suggest manual installation if all attempts fail

## Integration Notes

### Detection Triggers
Monitor for these error patterns:
- `command not found: <cmd>`
- `<cmd>: No such file or directory`
- `zsh: command not found: <cmd>`
- `bash: <cmd>: command not found`

### Preservation of Context
- Maintain current working directory
- Preserve environment variables
- Keep stdin/stdout/stderr intact

### User Experience
- Show what package is being tried
- Brief success/failure feedback
- Don't repeat for same command in session

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