# Create ticket

<!-- Requires: Atlassian MCP via ticket-creator agent -->
<!-- This command delegates to ticket-creator agent which has Atlassian MCP access for Jira -->

You are tasked with creating a Jira ticket by delegating to the ticket-creator agent. 

## Initial Setup:

When this command is invoked:

1. **Check if parameters were provided**:
   - If a ticket description was provided, skip the default message.

2. **If no parameters provided**, respond with:

```
I'm ready to create a Jira ticket. Please describe your issue in detail, and I'll delegate to the ticket-creator agent which has Atlassian MCP access.
```

Then wait for the user's ticket description.

## Steps to follow after receiving the ticket description:

1. **Delegate to ticket-creator agent:**
   - Use the Task tool with `subagent_type="ticket-creator"`
   - Pass the ticket description and instructions (steps 2-8 below) to the agent
   - The agent has Atlassian MCP access and will create the Jira ticket
   - Include all formatting requirements and ask agent to:
     - Create actual Jira ticket using Atlassian MCP
     - Also save markdown record in `thoughts/shared/tickets/` for local reference
     - Return Jira ticket URL and key

2. **Determine the ticket number (agent executes)**
    - Find the highest numbered document in the `thoughts/shared/tickets/` directory
    - If no document is present, ticket number is 1.

3. **Synthesize title and summary (agent executes)**
    - Summarize the user's input to no more than three sentences
    - Further boil it down to a short title of a few words max

4. **Define a file name (agent executes)**
    - Use the directory `thoughts/shared/tickets/`
    - Use a filename like `{NUMBER}-{title}.md`
    - {NUMBER} comes from step 2 and looks like `ENG-XXX`.
    - {title} comes from step 3 and should be in `kebab-case`

5. **Analyse and decompose the ticket description (agent executes)**
    - Break down the user's description into a problem statement and a desired outcome

6. **Compose and present the ticket (agent executes)**
    - Compose it with YAML frontmatter followed by content:
```markdown
---
date: [Current date and time with timezone in ISO format]
requester: [Requester name from git config]
topic: "[The title defined above]"
status: open
last_updated: [Current date in YYYY-MM-DD format]
last_updated_by: [Requester name from git config]
---

# TICKET: [title]

## Summary

[A summary of the problem and desired outcome in max 1-2 short sentences]

## Problem
[The problem statement]

## Desired outcome

[The desired outcome]

```
    - Create the Jira ticket using Atlassian MCP tools
    - Present the ticket contents to the user with Jira URL
    - Ask if they want to accept, or change the ticket contents

7. **Handle follow-ups (agent executes)**
    - If the user wants to make changes to the ticket, update Jira and run Steps 3 through 6 again.
    - If the user says they want to accept, continue to the next step.

8. **Save local record (agent executes)**
    - Save the document to the file name defined in step 4
    - Include Jira ticket URL and key in the markdown frontmatter 
