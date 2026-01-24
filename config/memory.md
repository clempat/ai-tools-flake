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

Always use refs.tool when I need code generation, setup or configuration steps, or library/API documentation.
Use ref_search_documentation to search docs (web, github, private repos, pdfs), then ref_read_url to read content.

# NixOS Command Not Found Handler

Use skill `nixos-command-not-found` for command-not-found handling. Exclude: single letters, shell builtins (cd, export), obvious typos (sl, gerp).
