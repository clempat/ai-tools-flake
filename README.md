# AI Tools Flake

Unified Nix flake for AI tools configuration including Claude Code, OpenCode, MCP servers, and AI agents.

## Features

- **Unified Module**: Single home-manager module that configures both Claude Code and OpenCode
- **MCP Servers**: Shared MCP server configurations across tools
- **Claude Desktop Integration**: Auto-configures MCP servers for Claude Desktop on macOS
- **AI Agents**: Reusable agent definitions with tool-specific metadata
- **Claude Skills**: Pre-configured skills for various tasks
- **Claude-Flow Commands**: Uses upstream `programs.{opencode,claude-code}.commands` options
- **Packages**: Custom packages like spec-kit
- **Default Configurations**: Sensible defaults that can be overridden per-system
- **Flexible Versioning**: Control opencode/claude-code versions via flake follows or nixpkgs overlays

## Requirements

- **home-manager**: Must use `unstable` branch (programs.claude-code only in unstable)
- **nixpkgs**: Recommends `nixos-unstable` (claude-code package)

## Usage

### As a Flake Input

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    ai-tools.url = "github:clempat/ai-tools-flake";
    ai-tools.inputs.nixpkgs.follows = "nixpkgs";  # Use your nixpkgs
  };

  outputs = { nixpkgs, home-manager, ai-tools, ... }: {
    homeConfigurations.youruser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        ai-tools.homeManagerModules.default
        {
          programs.ai-tools.enable = true;
        }
      ];
    };
  };
}
```

### Home Manager Integration

#### Basic Setup (Minimal)

```nix
{ inputs, ... }:
{
  imports = [ inputs.ai-tools.homeManagerModules.default ];

  programs.ai-tools.enable = true;
  
  # That's it! Automatically:
  # - Installs claude-code & opencode from nixpkgs-unstable
  # - Configures MCPs, agents, memory from config/
  # - Adds claude-flow commands
  # - Auto-configures Claude Desktop (macOS)
}
```

#### Override Package Versions

The module automatically uses packages from the flake. To override:

```nix
{ inputs, pkgs, ... }:
{
  imports = [ inputs.ai-tools.homeManagerModules.default ];

  programs.ai-tools.enable = true;
  
  # Optional: override package versions
  programs.opencode.package = inputs.opencode.packages.${pkgs.system}.default;
  programs.claude-code.package = pkgs.unstable.claude-code;
}
```

### Claude Desktop Configuration (macOS)

On macOS, the module automatically configures Claude Desktop by generating `~/Library/Application Support/Claude/claude_desktop_config.json`.

**What's Auto-Configured:**
- ✅ **stdio MCP servers** (nixos, playwright) are automatically added to the config file
- ✅ **HTTP MCP servers** via the **mcp-gateway** proxy (NEW!)

**MCP Gateway (Automatic HTTP Support)**

The flake includes an `mcp-gateway` package that acts as a stdio→HTTP proxy, allowing ALL your HTTP MCP servers to work with Claude Desktop automatically!

**How it works:**
1. The gateway runs as a stdio MCP server (Claude Desktop compatible)
2. It proxies requests to your HTTP MCP servers (atlassian, github, context7, etc.)
3. All HTTP servers appear as tools in Claude Desktop

**Generated config:**
```json
{
  "mcpServers": {
    "gateway": {
      "command": "/nix/store/.../bin/mcp-gateway",
      "env": {
        "MCP_GATEWAY_CONFIG": "~/.config/mcp-gateway/config.json"
      }
    },
    "nixos": {
      "command": "nix",
      "args": ["run", "github:utensils/mcp-nixos", "--"]
    }
  }
}
```

The gateway config (`~/.config/mcp-gateway/config.json`) is automatically generated from your `config/mcps.nix` HTTP servers.

**Alternative: Manual Configuration**

If you prefer manual configuration or the gateway doesn't work:

1. Open Claude Desktop → **Settings → Connectors**
2. Click **"Add custom connector"**
3. Enter server URLs from `config/mcps.nix`
4. Configure OAuth authentication if needed

**Technical Details:**

- Gateway uses [multi-mcp](https://github.com/kfirtoledo/multi-mcp) (Python-based)
- Packaged as a Nix derivation with all dependencies
- Config auto-generated from enabled HTTP servers in `config/mcps.nix`

### Claude-Flow Commands

Automatically installed workflow commands:

- **commit**: Create git commits
- **create_plan**: Generate implementation plans
- **create_spec**: Create feature specs
- **create_ticket**: Generate Jira tickets
- **create_worktree**: Create git worktrees
- **implement_plan**: Execute implementation plans
- **research_codebase**: Document codebases
- **research_confluence**: Research Confluence docs
- **validate_plan**: Validate implementation plans

Commands automatically configured via:
- `programs.opencode.commands`
- `programs.claude-code.commands`

### Advanced: Direct Package Access

```nix
{
  # Access packages from the flake directly
  home.packages = [
    inputs.ai-tools.packages.${system}.opencode
    inputs.ai-tools.packages.${system}.claude-code
    inputs.ai-tools.packages.${system}.spec-kit
  ];
}
```

### Advanced: Quick Shell (without home-manager)

```bash
nix develop github:clempat/ai-tools-flake
# Provides: opencode, claude-code, gh
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
│       ├── gitea-tea/
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
- **refs**: refs.tool documentation

## Available Skills

- **lint-with-conform**: Format files based on conform config
- **gitea-tea**: Gitea workflows with tea CLI
- **nixos-advisor**: NixOS configuration advice
- **obsidian-worklog**: Obsidian worklog integration

## License

MIT
