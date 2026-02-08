---
name: gitea-tea
description: Work with Gitea using tea CLI for auth, repo, issue, pull request, and release workflows. Use when user references Gitea, self-hosted git forges, or asks for tea commands.
---

# Gitea + tea CLI

Use this skill when tasks target Gitea and the `tea` CLI, especially if the user would normally use `gh` on GitHub.

## When To Use

- User mentions Gitea, self-hosted git, forgejo-compatible flows, or `tea`
- You need CLI automation for issues, pull requests, repos, comments, or releases
- You need host-specific auth profiles (multiple Gitea instances)

## Core Rules

1. Prefer `tea` over `gh` for Gitea targets.
2. Always scope commands to target explicitly when ambiguity exists:
   - `--repo owner/name`
   - `--login <profile>`
   - `--remote <remote-name>`
3. If command flags differ by tea version, run `tea <cmd> --help` first and follow local help text.
4. For PR/review actions, ensure local branches are pushed before create/merge operations.

## Auth Workflow

### Create login profile (token)

```bash
tea login add --name <profile> --url https://gitea.example.com --token <token>
```

### Verify logins / switch default

```bash
tea login ls
tea login default -n <profile>
```

### Optional env-based auth (automation)

- `GITEA_SERVER_URL`
- `GITEA_SERVER_TOKEN`
- `GITEA_SERVER_USER`
- `GITEA_SERVER_PASSWORD`

## Command Mapping (gh -> tea)

- Repo list: `gh repo list` -> `tea repos ls`
- Issue list: `gh issue list` -> `tea issues ls`
- Issue create: `gh issue create` -> `tea issues create`
- PR list: `gh pr list` -> `tea pr ls` or `tea pulls ls`
- PR create: `gh pr create` -> `tea pr create` or `tea pulls create`
- PR checkout: `gh pr checkout <n>` -> `tea pulls checkout <n>`
- Comment on PR/issue: `gh pr comment` / `gh issue comment` -> `tea comment <index> [body]`
- Release list/create: `gh release list/create` -> `tea releases ls` / `tea releases create`

## Practical Patterns

### Work on a specific repo

```bash
tea issues ls --repo owner/name --login <profile>
tea pr ls --repo owner/name --login <profile>
```

### Create issue / PR

```bash
tea issues create --repo owner/name --title "Title" --body "Details"
tea pr create --repo owner/name --head <branch> --title "Title" --description "Details"
```

### Review / merge PR

```bash
tea pulls review <index>
tea pulls approve <index>
tea pulls merge <index>
```

### Release workflow

```bash
tea releases create --repo owner/name --tag vX.Y.Z --title "vX.Y.Z"
tea release assets --help
```

## Safety + Verification

- Run read-only commands first (`ls`, `list`, `view`) before mutating operations.
- If repo context unclear, require explicit `--repo` and `--login`.
- Before destructive actions (`delete`, `close`, `merge`), confirm target index and repository.
- If command fails, capture `tea <subcommand> --help` output and adapt flags to installed version.

## Troubleshooting

- Auth failures: re-check login profile URL/token; verify `tea login ls`.
- Wrong target host/repo: pass both `--login` and `--repo` explicitly.
- PR creation errors: ensure branch is pushed and upstream is configured.
- TLS issues on internal hosts: prefer proper CA trust; use insecure flags only when user explicitly accepts risk.
