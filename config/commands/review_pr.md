# Review PR

<!-- Requires: GitHub CLI (gh) -->

Perform a thorough code review on a PR using the senior-code-reviewer agent.

## Usage

```
/review_pr <PR_URL_OR_NUMBER>
```

- PR URL: full GitHub URL (https://github.com/org/repo/pull/123)
- PR number: just the number if in the repo context

## Process

1. **Fetch PR info**:
   ```bash
   gh pr view <PR> --json number,title,body,baseRefName,headRefName,additions,deletions,changedFiles
   ```

2. **Get the diff**:
   ```bash
   gh pr diff <PR>
   ```

3. **Delegate to senior-code-reviewer agent**:
   - Use Task tool with `subagent_type="senior-code-reviewer"`
   - Prompt:
     ```
     Review this PR thoroughly.

     PR: <title> (#<number>)
     Base: <baseRefName> <- <headRefName>
     Stats: +<additions> -<deletions> in <changedFiles> files

     Description:
     <body>

     Diff:
     <diff content>

     For each issue found, provide:
     1. **File & Line**: exact file path and line number(s)
     2. **Severity**: critical | major | minor | suggestion
     3. **Category**: security | performance | architecture | reliability | readability
     4. **Issue**: clear description of the problem
     5. **Suggestion**: specific fix with code example if applicable

     Group findings by file. End with a summary:
     - Overall assessment (approve | request changes | comment)
     - Key concerns count by severity
     - Positive observations
     ```

4. **Format output**:
   - Present review with actionable comments
   - Each finding should be copy-pasteable to GitHub PR comments
   - Include file:line references for easy navigation

## Output Format

```markdown
## PR Review: <title>

### Summary
- **Verdict**: [Approve | Request Changes | Comment]
- **Critical**: X | **Major**: X | **Minor**: X | **Suggestions**: X

### Findings

#### `path/to/file.ts`

**[CRITICAL] Line 42-45: SQL Injection vulnerability**
Category: Security

The query uses string interpolation without sanitization.

```diff
- const query = `SELECT * FROM users WHERE id = ${userId}`;
+ const query = 'SELECT * FROM users WHERE id = $1';
+ const result = await db.query(query, [userId]);
```

---

#### `another/file.ts`
...

### Positive Observations
- Good test coverage for edge cases
- Clean separation of concerns
```

## Notes

- For large PRs, focus on most critical files first
- Use ref.tool to verify library usage patterns
- Cross-reference with project conventions if available
