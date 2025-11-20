# Default agent configurations
{
  frontend-developer = {
    content = ./agents/frontend-developer.md;
    description = "Modern frontend developer specializing in Vue.js, TypeScript, and web technologies. Expertise in component design, state management, build tooling, and performance optimization.";
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
    opencodeMcp = [ "context7" ];
  };

  senior-code-reviewer = {
    content = ./agents/senior-code-reviewer.md;
    description = "Senior code reviewer focusing on code quality, architecture, security, and best practices. Provides constructive feedback and improvement suggestions.";
    tools = [
      "Glob"
      "Grep"
      "Read"
    ];
    model = "sonnet";
    color = "purple";
    mode = "subagent";
    opencodeMcp = [
      "context7"
      "github"
    ];
  };

  ui-engineer = {
    content = ./agents/ui-engineer.md;
    description = "UI/UX engineer specializing in component design, accessibility, responsive layouts, and design systems. Focuses on user experience and visual polish.";
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
    opencodeMcp = [ "context7" ];
  };

  nixos = {
    content = ./agents/nixos.md;
    description = "NixOS configuration advisor with MCP integration";
    tools = [
      "Glob"
      "Grep"
      "Read"
      "Write"
      "Edit"
    ];
    model = "sonnet";
    color = "green";
    mode = "subagent";
    opencodeModel = "anthropic/claude-sonnet-4-20250514";
    temperature = 0.1;
    opencodeMcp = [ "nixos" ];
  };

  ticket-driven-developer = {
    content = ./agents/ticket-driven-developer.md;
    description = "Ticket-driven dev agent that requires Jira ticket, checks Figma designs, uses GitHub tools, and operates in plan-first mode with clarifying questions";
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
    opencodeMcp = [
      "atlassian"
      "figma-desktop"
      "brave-search"
      "context7"
    ];
  };
}
