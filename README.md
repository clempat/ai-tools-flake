# AI Tools Flake

Unified Nix flake for AI tools configuration including Claude Code, OpenCode, MCP servers, and AI agents.

## Features

- **Unified Module**: Single home-manager module that configures both Claude Code and OpenCode
- **MCP Servers**: Shared MCP server configurations across tools
- **AI Agents**: Reusable agent definitions with tool-specific metadata
- **Claude Skills**: Pre-configured skills for various tasks
- **Claude-Flow Commands**: Uses upstream `programs.{opencode,claude-code}.commands` options
- **Packages**: Custom packages like spec-kit
- **Default Configurations**: Sensible defaults that can be overridden per-system

## Usage

### As a Flake Input

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    ai-tools.url = "github:clempat/ai-tools-flake";
  };

  outputs = { nixpkgs, ai-tools, ... }: {
    # Your configuration
  };
}
```

### Home Manager Integration

#### Basic Setup (Use Defaults)

```nix
{
  imports = [ ai-tools.homeManagerModules.default ];

  programs.ai-tools = {
    enable = true;
    # Uses default MCPs, agents, and memory
    # Default extraPackages includes gh and ripgrep
    # Automatically installs claude-flow commands via upstream options
  };
}
```

#### Custom Configuration

```nix
{ config, ... }:
let
  ai-tools-flake = inputs.ai-tools;
in {
  imports = [ ai-tools-flake.homeManagerModules.default ];

  programs.ai-tools = {
    enable = true;

    # Merge with defaults
    mcpServers = ai-tools-flake.lib.defaultConfig.mcpServers // {
      # Enable specific servers
      github.enable = true;
      context7.enable = true;

      # Add custom server
      myserver = {
        enable = true;
        type = "http";
        url = "http://localhost:3000/mcp";
      };
    };

    # Use default agents or override
    agents = ai-tools-flake.lib.defaultConfig.agents // {
      # Disable an agent
      nixos.disable = true;

      # Add custom agent
      my-agent = {
        content = ./my-agent.md;
        description = "My custom agent";
        tools = [ "Read" "Write" ];
        model = "sonnet";
      };
    };

    # Use default memory or provide custom
    memory = ai-tools-flake.lib.defaultConfig.memory;
    # or
    # memory = ./my-memory.md;

    # Override default extra packages (gh, ripgrep)
    extraPackages = with pkgs; [
      gh       # GitHub CLI for ticket-driven-developer agent
      jq       # JSON processor for data manipulation
      ripgrep  # Fast search tool
      nodejs   # For npx-based MCP servers like playwright
    ];

    enableClaudeCode = true;
    enableOpencode = true;
    enableMcphub = false;

    # Claude-flow commands (enabled by default)
    enableClaudeFlowCommands = true;
    # Optional: use custom commands directory
    # commandsDir = ./my-commands;
  };

  # Install Claude skills manually (until module supports them)
  home.file.".claude/skills/lint-with-conform".source =
    "${ai-tools-flake}/config/skills/lint-with-conform";
}
```

### Claude-Flow Commands

The flake includes 9 pre-configured workflow commands that are automatically configured via upstream home-manager options:

- Uses `programs.opencode.commands` for OpenCode
- Uses `programs.claude-code.commands` for Claude Desktop

Available commands:

- **commit**: Create git commits for changes
- **create_plan**: Generate implementation plans
- **create_spec**: Create feature specifications
- **create_ticket**: Generate Jira tickets
- **create_worktree**: Create git worktrees
- **implement_plan**: Execute implementation plans
- **research_codebase**: Document and explain codebases
- **research_confluence**: Research Confluence documentation
- **validate_plan**: Validate implementation plans

To disable auto-installation:

```nix
programs.ai-tools = {
  enable = true;
  enableClaudeFlowCommands = false;
};
```

To use custom commands directory:

```nix
programs.ai-tools = {
  enable = true;
  commandsDir = ./my-custom-commands;
};
```

**Note**: Users can still add their own commands using the upstream options directly:

```nix
programs.opencode.commands = ./my-extra-commands;
programs.claude-code.commands = ./my-extra-commands;
```

### Using the Overlay

```nix
{
  nixpkgs.overlays = [ ai-tools.overlays.default ];

  # Now opencode wrapper is available in pkgs
  home.packages = [ pkgs.opencode ];
}
```

### Using Packages

```nix
{
  home.packages = [
    ai-tools.packages.${system}.spec-kit
  ];
}
```

## Structure

```
ai-tools-flake/
├── flake.nix              # Main flake definition
├── modules/
│   └── ai-tools.nix       # Home-manager module
├── config/                # All configuration
│   ├── agents.nix         # Default agent configurations
│   ├── mcps.nix           # Default MCP server configurations
│   ├── memory.md          # Default memory/rules
│   ├── agents/            # Agent content markdown files
│   └── skills/            # Claude skills
│       ├── lint-with-conform/
│       ├── nixos-advisor/
│       └── nixos-command-not-found/
├── commands/              # Claude-flow workflow commands
│   ├── commit.md
│   ├── create_plan.md
│   ├── create_spec.md
│   ├── create_ticket.md
│   ├── create_worktree.md
│   ├── implement_plan.md
│   ├── research_codebase.md
│   ├── research_confluence.md
│   └── validate_plan.md
├── pkgs/
│   └── spec-kit.nix       # Spec-kit package
└── overlays/
    └── default.nix        # OpenCode wrapper overlay
```

## Available Agents

- **frontend-developer**: Vue.js, TypeScript, modern web dev
- **senior-code-reviewer**: Code quality, architecture, security
- **ui-engineer**: UI/UX, accessibility, design systems
- **nixos**: NixOS configuration with MCP integration
- **ticket-driven-developer**: Jira ticket-driven dev with spec-kit integration (requires `gh` CLI)

## Available MCP Servers

- **nixos**: NixOS packages and options
- **figma-desktop**: Figma desktop integration
- **atlassian**: Atlassian/Jira integration
- **github**: GitHub integration
- **brave-search**: Brave search
- **sentry**: Sentry error tracking
- **n8n**: n8n workflow automation
- **todoist**: Todoist task management
- **playwright**: Browser automation
- **context7**: Context7 documentation

## Available Skills

- **lint-with-conform**: Format files based on conform config
- **nixos-advisor**: NixOS configuration advice
- **obsidian-worklog**: Obsidian worklog integration

## License

MIT
