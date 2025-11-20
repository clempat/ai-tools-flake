# AI Tools Flake

Unified Nix flake for AI tools configuration including Claude Code, OpenCode, MCP servers, and AI agents.

## Features

- **Unified Module**: Single home-manager module that configures both Claude Code and OpenCode
- **MCP Servers**: Shared MCP server configurations across tools
- **AI Agents**: Reusable agent definitions with tool-specific metadata
- **Claude Skills**: Pre-configured skills for various tasks
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

    enableClaudeCode = true;
    enableOpencode = true;
    enableMcphub = false;
  };

  # Install Claude skills manually (until module supports them)
  home.file.".claude/skills/lint-with-conform".source =
    "${ai-tools-flake}/skills/lint-with-conform";
}
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
├── config/
│   ├── agents.nix         # Default agent configurations
│   ├── mcps.nix           # Default MCP server configurations
│   ├── memory.md          # Default memory/rules
│   └── agents/            # Agent content markdown files
├── skills/                # Claude skills
│   ├── lint-with-conform/
│   ├── nixos-advisor/
│   └── obsidian-worklog/
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
