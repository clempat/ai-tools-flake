# Default agent configurations
{
  frontend-developer = {
    content = ./agents/frontend-developer.md;
    description =
      "Modern frontend developer specializing in Vue.js, TypeScript, and web technologies. Expertise in component design, state management, build tooling, and performance optimization.";
    tools = [
      "Glob"
      "Grep"
      "Read"
      "Write"
      "Edit"
      "MultiEdit"
      "WebSearch"
      "WebFetch"
      "TodoWrite"
      "Bash"
    ];
    model = "sonnet";
    color = "blue";
    mode = "all";
    mcps = [ "context7" "chrome-devtools" ];
  };

  senior-code-reviewer = {
    content = ./agents/senior-code-reviewer.md;
    description =
      "Senior code reviewer focusing on code quality, architecture, security, and best practices. Provides constructive feedback and improvement suggestions.";
    tools = [ "Glob" "Grep" "Read" ];
    model = "sonnet";
    color = "purple";
    mode = "subagent";
    mcps = [ "context7" "github" ];
  };

  ui-engineer = {
    content = ./agents/ui-engineer.md;
    description =
      "UI/UX engineer specializing in component design, accessibility, responsive layouts, and design systems. Focuses on user experience and visual polish.";
    tools = [
      "Glob"
      "Grep"
      "Read"
      "Write"
      "Edit"
      "MultiEdit"
      "WebSearch"
      "WebFetch"
      "TodoWrite"
      "Bash"
    ];
    model = "sonnet";
    color = "cyan";
    mode = "all";
    mcps = [ "context7" "figma-desktop" "github" ];
  };

  nixos = {
    content = ./agents/nixos.md;
    description = "NixOS configuration advisor with MCP integration";
    tools = [ "Glob" "Grep" "Read" "Write" "Edit" ];
    model = "sonnet";
    color = "green";
    mode = "all";
    opencodeModel = "anthropic/claude-sonnet-4-20250514";
    temperature = 0.1;
    mcps = [ "nixos" ];
  };

  ticket-driven-developer = {
    content = ./agents/ticket-driven-developer.md;
    description =
      "Ticket-driven dev agent that requires Jira ticket, checks Figma designs, uses GitHub tools, and operates in plan-first mode with clarifying questions";
    tools = [
      "Glob"
      "Grep"
      "Read"
      "Write"
      "Edit"
      "MultiEdit"
      "WebFetch"
      "TodoWrite"
      "Bash"
    ];
    model = "sonnet";
    color = "yellow";
    mode = "all";
    temperature = 0.2;
    mcps = [ "atlassian" "figma-desktop" "brave-search" "context7" ];
  };

  confluence-researcher = {
    content = ./agents/confluence-researcher.md;
    description =
      "Confluence documentation researcher. Searches and synthesizes findings from Confluence pages. Read-only documentation operations.";
    tools = [ "Read" "Grep" "Glob" "TodoWrite" "WebFetch" ];
    model = "sonnet";
    color = "teal";
    mode = "subagent";
    mcps = [ "atlassian" ];
  };

  ticket-creator = {
    content = ./agents/ticket-creator.md;
    description =
      "Jira ticket creator. Creates Jira tickets using Atlassian MCP and maintains local markdown records.";
    tools = [ "Read" "Write" "Grep" "Glob" "TodoWrite" ];
    model = "sonnet";
    color = "red";
    mode = "subagent";
    mcps = [ "atlassian" ];
  };

  codebase-analyzer = {
    content = ./agents/codebase-analyzer.md;
    description =
      "Documents and explains how code implementations currently work with precise file:line references. Read-only analysis without suggestions.";
    tools = [ "Glob" "Grep" "Read" ];
    model = "sonnet";
    color = "blue";
    mode = "subagent";
  };

  codebase-locator = {
    content = ./agents/codebase-locator.md;
    description =
      "Maps file locations and organizational structures. Fast file discovery by topic/feature without code analysis.";
    tools = [ "Glob" "Grep" "Read" ];
    model = "haiku";
    color = "gray";
    mode = "subagent";
  };

  codebase-pattern-finder = {
    content = ./agents/codebase-pattern-finder.md;
    description =
      "Locates existing code patterns and usage examples. Pattern librarian showing how implementations are currently done.";
    tools = [ "Glob" "Grep" "Read" ];
    model = "sonnet";
    color = "indigo";
    mode = "subagent";
  };

  thoughts-analyzer = {
    content = ./agents/thoughts-analyzer.md;
    description =
      "Extracts high-value insights from research docs. Surfaces decisions, trade-offs, constraints, and lessons learned.";
    tools = [ "Read" "Grep" "Glob" ];
    model = "sonnet";
    color = "orange";
    mode = "subagent";
  };

  thoughts-locator = {
    content = ./agents/thoughts-locator.md;
    description =
      "Discovers relevant docs in thoughts/ directory. Fast categorization without deep analysis.";
    tools = [ "Read" "Grep" "Glob" ];
    model = "haiku";
    color = "pink";
    mode = "subagent";
  };

  web-search-researcher = {
    content = ./agents/web-search-researcher.md;
    description =
      "Web research specialist for modern info. Searches docs, best practices, and technical solutions with source attribution.";
    tools = [ "WebSearch" "WebFetch" "TodoWrite" "Read" "Grep" "Glob" ];
    model = "sonnet";
    color = "yellow";
    mode = "subagent";
  };

  n8n-workflow-engineer = {
    content = ./agents/n8n-workflow-engineer.md;
    description =
      "n8n workflow specialist. Creates workflows, debugs errors, optimizes performance, configures nodes, and implements best practices.";
    tools = [
      "Glob"
      "Grep"
      "Read"
      "Write"
      "Edit"
      "WebSearch"
      "WebFetch"
      "TodoWrite"
    ];
    model = "sonnet";
    color = "magenta";
    mode = "all";
    mcps = [ "context7" "n8n" "n8n-official" ];
  };

  chrome-debugger = {
    content = ./agents/chrome-debugger.md;
    description =
      "QA specialist verifying implementations via Chrome. Inspects dev console, network requests, and DOM for errors and issues.";
    tools = [ "Read" "TodoWrite" ];
    model = "sonnet";
    color = "orange";
    mode = "subagent";
    mcps = [ "chrome-devtools" ];
  };

  pr-writer = {
    content = ./agents/pr-writer.md;
    description =
      "Creates comprehensive PR descriptions optimized for human reviewers. Analyzes changes, assesses risks, and structures descriptions for efficient review.";
    tools = [ "Glob" "Grep" "Read" "Bash" "TodoWrite" ];
    model = "sonnet";
    color = "green";
    mode = "subagent";
    mcps = [ "github" "atlassian" ];
  };

  network-main = {
    content = ./agents/network-main.md;
    description =
      "Homelab network specialist for family networks with UniFi and smart home (Z-Wave, Zigbee). Network certification aware.";
    tools = [ "WebSearch" "WebFetch" "TodoWrite" ];
    model = "sonnet";
    color = "cyan";
    mode = "all";
    mcps = [ "unifi" ];
  };

  productivity-coach = {
    content = ./agents/productivity-coach.md;
    description =
      "Productivity expert with GTD, Atomic Habits, Deep Work, and 15+ methodology knowledge. Creates optimized Todoist tasks.";
    tools = [ "WebSearch" "WebFetch" "TodoWrite" ];
    model = "sonnet";
    color = "lime";
    mode = "all";
    mcps = [ "todoist" ];
  };
}
