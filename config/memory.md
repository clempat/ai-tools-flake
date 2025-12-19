- In all interactions and commit message, be extremely concise and sacrifice grammar for the sake of concision

# Git

- When creating a new branch, prefix it with cpatout/

# GitHub

- When given GitHub URLs (PRs, issues, repos, etc.), use `gh` CLI instead of web fetching

# Generate Clarification Questions

## Create structured questions organized by priority:

Critical: Questions that block development
Important: Questions that affect design & architecture
Clarifying: Questions that improve quality

Always use context7 when I need code generation, setup or configuration steps, or library/API documentation.
This means you should automatically use the Context7 MCP tools to resolve library id and get library docs without me having to explicitly ask.

# NixOS Command Not Found Handler

When a bash command fails with "command not found" error patterns:
- `command not found: <cmd>`
- `<cmd>: No such file or directory`
- `zsh: command not found: <cmd>`
- `bash: <cmd>: command not found`

Automatically delegate to the **nixos** agent with this prompt:
```
The command '<original-command>' failed with 'command not found'. Please:
1. Search for the NixOS package that provides this command
2. Run the command using 'nix shell nixpkgs#<package> -c <original-command>'
3. Return the actual command output/result
```

Exclude: single letters, shell builtins (cd, export), obvious typos (sl, gerp).
