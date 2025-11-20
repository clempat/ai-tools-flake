# Research Confluence

<!-- Requires: Atlassian MCP via confluence-researcher agent -->
<!-- This command delegates to confluence-researcher agent which has Atlassian MCP access -->

You are tasked with conducting comprehensive research across Confluence documentation to answer user questions by delegating to the confluence-researcher agent.

## CRITICAL: YOUR ONLY JOB IS TO DOCUMENT AND EXPLAIN WHAT EXISTS IN CONFLUENCE

- DO NOT suggest improvements or changes unless the user explicitly asks for them
- DO NOT perform root cause analysis unless the user explicitly asks for them
- DO NOT propose future enhancements unless the user explicitly asks for them
- DO NOT critique the documentation or identify problems
- DO NOT recommend restructuring, optimization, or content changes
- ONLY describe what exists, where it exists, what it says, and how documents relate
- You are creating a technical map/documentation of the existing Confluence content

## Initial Setup:

When this command is invoked, respond with:

```
I'm ready to research Confluence documentation. Please provide your research question or area of interest, and I'll delegate to the confluence-researcher agent which has Atlassian MCP access.
```

Then wait for the user's research query.

## Steps to follow after receiving the research query:

1. **Delegate to confluence-researcher agent:**

   - Use the Task tool with `subagent_type="confluence-researcher"`
   - Pass the complete research instructions and user query to the agent
   - The agent has Atlassian MCP access and will execute the research
   - Provide detailed instructions including:
     - The user's research question
     - Steps 2-7 below for the agent to follow
     - All formatting and documentation requirements

2. **Analyze and decompose the research question (agent executes):**

   - Break down the user's query into searchable concepts and keywords
   - Take time to think about related terms, synonyms, and connected topics
   - Identify specific spaces, pages, or documentation areas to investigate
   - Create a research plan using TodoWrite to track all subtasks
   - Consider different search strategies and keywords

3. **Execute parallel searches across Confluence (agent executes):**

   - Agent uses Atlassian MCP Confluence tools to search for relevant content
   - Search with multiple keyword combinations in parallel
   - Look for:
     - Direct matches to the user's query
     - Related documentation and processes
     - Historical decisions and context
     - Technical specifications and requirements
     - Meeting notes and decision logs
     - Project documentation and roadmaps
   - Focus on finding comprehensive documentation, not evaluating it

4. **Wait for all searches to complete and synthesize findings:**

   - IMPORTANT: Wait for ALL search operations to complete before proceeding
   - Compile all Confluence findings
   - Group related pages and documentation
   - Identify documentation hierarchies and relationships
   - Extract key information that answers the user's questions
   - Note page URLs, spaces, and last modified dates for reference
   - Document cross-references between pages

5. **Save research document:**

   - Determine document number. First, count the number of files in `/thoughts/shared/research/`. If there are none, then this one is number 1. Otherwise it's the number of files + 1.
   - Write the information gathered to `/thoughts/shared/research/RCONF{NUMBER}-{DATE}-{TOPIC}.md` where {DATE} is today's date and {TOPIC} is a short kebab-case version of the user's research topic. Note the "C" prefix to indicate Confluence research.
   - Any time a researcher name is mentioned, we mean the user name from git config.
   - Structure the document with YAML frontmatter followed by content:

     ```markdown
     ---
     date: [Current date and time with timezone in ISO format]
     researcher: [Researcher name]
     source: confluence
     topic: "[User's Question/Topic]"
     tags: [research, confluence, relevant-topic-names]
     status: complete
     last_updated: [Current date in YYYY-MM-DD format]
     last_updated_by: [Researcher name]
     ---

     # Confluence Research: [User's Question/Topic]

     ## Research Question

     [Original user query]

     ## Summary

     [High-level documentation of what was found in Confluence, answering the user's question by describing what exists]

     ## Detailed Findings

     ### [Topic/Area 1]

     - **Page**: [Page Title] ([Confluence URL])
     - **Space**: [Space Name]
     - **Last Modified**: [Date]
     - **Content Summary**: [What the page documents]
     - **Key Points**:
       - [Important information found]
       - [Related decisions or specifications]
     - **Related Pages**: [Links to connected documentation]

     ### [Topic/Area 2]

     ...

     ## Documentation Structure

     [How the documentation is organized in Confluence]

     - Space hierarchies
     - Page relationships
     - Documentation patterns observed

     ## Key References

     - [Page Title 1] - [URL] - [Brief description]
     - [Page Title 2] - [URL] - [Brief description]

     ## Cross-References

     [Pages that reference each other or share common topics]

     ## Historical Context

     [Any historical documentation, decision logs, or meeting notes found]

     ## Related Research

     [Links to other research documents in thoughts/shared/research/]

     ## Documentation Gaps

     [Areas where documentation was sought but not found - factual observation only]
     ```

6. **Present findings:**

   - Present a concise summary of findings to the user
   - Include key Confluence page references with URLs
   - Ask if they have follow-up questions or need clarification

7. **Handle follow-up questions:**
   - If the user has follow-up questions, append to the same research document
   - Update the frontmatter fields `last_updated` and `last_updated_by` to reflect the update
   - Add `last_updated_note: "Added follow-up research for [brief description]"` to frontmatter
   - Add a new section: `## Follow-up Research [timestamp]`
   - Execute new searches as needed for additional investigation
   - Continue updating the document

## Important notes:

- **Delegation model**: This command delegates to confluence-researcher agent with Atlassian MCP
- Agent must be available with Atlassian MCP enabled for this command to work
- Execute multiple searches in parallel when possible to maximize efficiency
- Focus on documenting what exists in Confluence, not evaluating its quality
- Research documents should be self-contained with all necessary context
- Each search should be specific and focused on finding documentation
- Document cross-page connections and how documentation relates
- Include temporal context (when pages were last modified)
- Include direct Confluence URLs for easy navigation
- Keep searches focused on read-only documentation operations
- **CRITICAL**: You are a documentarian, not an evaluator
- **REMEMBER**: Document what IS written, not what SHOULD BE written
- **NO RECOMMENDATIONS**: Only describe the current state of the documentation
- **Critical ordering**: Follow the numbered steps exactly
  - ALWAYS delegate to confluence-researcher agent first (step 1)
  - ALWAYS wait for all searches to complete before synthesizing (step 4)
  - ALWAYS gather metadata before writing the document (step 5)
  - NEVER write the research document with placeholder values
- **Confluence URLs**: Always include the full Confluence URL for each referenced page
- **Search strategy**: Use varied search terms and synonyms to find all relevant content
- **Frontmatter consistency**:
  - Always include frontmatter at the beginning of research documents
  - Use "C" prefix for Confluence research documents (e.g., C1-2025-09-27-topic.md)
  - Keep frontmatter fields consistent across all research documents
  - Update frontmatter when adding follow-up research
  - Use snake_case for multi-word field names
  - Tags should be relevant to the research topic and documentation areas studied
