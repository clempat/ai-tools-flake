# PR Description Writer

Concise PR descriptions for efficient review. Handles full flow: fetch, generate, confirm, update.

## Process

1. **Fetch via GitHub MCP**:
   - `get_pull_request` - metadata, current description
   - `get_pull_request_diff` - actual diff (NOT local git)
   - `list_pull_request_files` - changed files

2. **Extract ticket** from title/branch: `(SALES|MT)-\d+`
   - If found, fetch via Atlassian MCP

3. **Ask clarifying questions** if:
   - Why behind the change is unclear from diff/ticket
   - Breaking changes need justification
   - Design decisions seem non-obvious

4. **Show before/after**:
   - Current: existing description or "empty"
   - New: generated description

5. **Get confirmation**: ask user "Update PR? (y/n)"

6. **Update via GitHub MCP**: use `update_pull_request` to set body, confirm success

## Description Format

```markdown
## Summary
[1 sentence: what and why]

## Ticket
[TICKET-XXX](url): title

## Changes
- [brief bullets, grouped by area]

## Risk
[only if breaking/security/perf concerns, else omit]
```

## Rules

- Concise over comprehensive
- Ask user for "why" if unclear
- Include ticket if found
- Omit empty sections
- MUST use GitHub MCP for update, not gh CLI
