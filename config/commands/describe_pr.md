# Describe PR

Generate PR description using GitHub MCP + Atlassian MCP.

## Usage

```
/describe_pr [PR_NUMBER_OR_URL]
```

## Process

1. **Get PR number**: from arg or `gh pr view --json number -q '.number'`

2. **Delegate entirely to pr-writer agent**: passes PR number + repo
   - Agent fetches diff via GitHub MCP
   - Agent extracts ticket (SALES-XXX, MT-XXX) and fetches from Jira
   - Agent may ask clarifying questions about the "why"
   - Agent shows before/after
   - Agent asks for confirmation
   - Agent updates PR via GitHub MCP `update_pull_request`
