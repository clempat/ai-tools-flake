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

It should suggest a `nix shell nixpkgs#<package> -c ...` You should use.

If you get no suggestion automatically delegate to the **nixos** agent with this prompt:

```
The command '<original-command>' failed with 'command not found'. Please:
1. search the package which could bring this command
2. return the `nix shell nixpkgs#` I should use. saying something like `use ...`
```

Exclude: single letters, shell builtins (cd, export), obvious typos (sl, gerp).
