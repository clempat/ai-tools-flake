{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ai-tools;

  # Transform MCP server for opencode
  transformMcpForOpencode = name: server:
    let
      baseServer = if server ? enable then
        (builtins.removeAttrs server [ "enable" ]) // {
          enabled = server.enable;
        }
      else
        server;
    in if baseServer.type == "http" then
      (builtins.removeAttrs baseServer [ "type" ]) // { type = "remote"; }
    else if baseServer.type == "stdio" then
      let
        withoutOldFields =
          builtins.removeAttrs baseServer [ "type" "command" "args" "env" ];
        withCommand = withoutOldFields // {
          type = "local";
          command = [ baseServer.command ] ++ baseServer.args;
        };
      in if baseServer ? env then
        withCommand // { environment = baseServer.env; }
      else
        withCommand
    else
      baseServer;

  # Transform MCP server for mcphub.nvim
  transformMcpForMcphub = name: server:
    let
      # mcphub uses "disabled" instead of "enable"
      baseServer = builtins.removeAttrs server [ "enable" "type" ];
      withDisabled = if server ? enable then
        baseServer // { disabled = !server.enable; }
      else
        baseServer;
    in if server.type == "http" then
      # http servers: keep url and headers, remove type
      withDisabled
    else if server.type == "stdio" then
      # stdio servers: keep command, args, env as-is
      withDisabled
    else
      withDisabled;

  # Generate mcphub.nvim servers.json
  mcphubServers = lib.mapAttrs transformMcpForMcphub cfg.mcpServers;
  mcphubConfig = builtins.toJSON { mcpServers = mcphubServers; };

  # Generate claude-code agent frontmatter
  generateClaudeFrontmatter = name: agent:
    let
      fields = lib.optionals (!agent.disable)
        ([ "name: ${name}" "description: |" "  ${agent.description}" ]
          ++ lib.optional (agent.tools != null)
          "tools: [${lib.concatStringsSep ", " agent.tools}]"
          ++ lib.optional (agent.model != null) "model: ${agent.model}"
          ++ lib.optional (agent.color != null) "color: ${agent.color}");
    in ''
      ---
      ${lib.concatStringsSep "\n" fields}
      ---
    '';

  # Generate opencode agent frontmatter
  generateOpencodeFrontmatter = name: agent:
    let
      fields = [ "description: ${agent.description}" ]
        ++ lib.optional (agent.mode != null) "mode: ${agent.mode}"
        ++ lib.optional (agent.opencodeModel != null)
        "model: ${agent.opencodeModel}"
        ++ lib.optional (agent.temperature != null)
        "temperature: ${toString agent.temperature}"
        ++ lib.optional agent.disable "disable: true";

      toolsSection = lib.optionalString
        (agent.opencodeMcp != null && agent.opencodeMcp != [ ]) ''
          tools:
          ${lib.concatMapStringsSep "\n" (mcp: "  ${mcp}*: true")
          agent.opencodeMcp}
        '';
    in ''
      ---
      ${lib.concatStringsSep "\n" fields}
      ${toolsSection}---
    '';

  # Generate agent file with frontmatter + content
  generateAgentFile = format: name: agent:
    let
      frontmatter = if format == "claude" then
        generateClaudeFrontmatter name agent
      else
        generateOpencodeFrontmatter name agent;
      content = builtins.readFile agent.content;
      fullContent = ''
        ${frontmatter}
        ${content}
      '';
    in if format == "claude" then
      pkgs.writeText "${name}.md" fullContent
    else
      fullContent; # opencode expects text, not derivation

  # Convert agents to directories for each tool
  claudeAgentsDir = if cfg.agents != { } then
    pkgs.linkFarm "claude-agents" (lib.mapAttrsToList (name: agent: {
      name = "${name}.md";
      path = generateAgentFile "claude" name agent;
    }) (lib.filterAttrs (name: agent: !agent.disable) cfg.agents))
  else
    null;

  opencodeAgents =
    lib.mapAttrs (name: agent: generateAgentFile "opencode" name agent)
    (lib.filterAttrs (name: agent: !agent.disable) cfg.agents);

  # Agent option type
  agentType = types.submodule {
    options = {
      content = mkOption {
        type = types.path;
        description =
          "Path to agent content markdown file (without frontmatter)";
      };

      description = mkOption {
        type = types.str;
        description = "Brief description of agent purpose and when to use it";
      };

      # Claude-code specific
      tools = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description =
          "List of tools for claude-code (Glob, Grep, Read, Write, etc.)";
      };

      model = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Model name for claude-code (sonnet, opus, haiku)";
      };

      color = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Color for claude-code agent";
      };

      # Opencode specific
      mode = mkOption {
        type = types.nullOr (types.enum [ "primary" "subagent" "all" ]);
        default = "all";
        description = "Agent mode for opencode";
      };

      temperature = mkOption {
        type = types.nullOr types.float;
        default = null;
        description = "Temperature for opencode (0.0-1.0)";
      };

      opencodeModel = mkOption {
        type = types.nullOr types.str;
        default = null;
        description =
          "Full model identifier for opencode (e.g., anthropic/claude-sonnet-4)";
      };

      opencodeMcp = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description =
          "List of MCP server names this agent can access in opencode";
      };

      disable = mkOption {
        type = types.bool;
        default = false;
        description = "Disable this agent";
      };
    };
  };

in {
  options.programs.ai-tools = {
    enable = mkEnableOption "unified AI tools configuration";

    mcpServers = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description = "MCP servers configuration (claude-code format)";
      example = {
        context7 = {
          type = "http";
          url = "https://mcp.context7.com/mcp";
          headers = { Authorization = "Bearer \${TOKEN}"; };
        };
      };
    };

    agents = mkOption {
      type = types.attrsOf agentType;
      default = { };
      description = "AI agents configuration";
      example = {
        reviewer = {
          content = ./agents/reviewer.md;
          description = "Reviews code for quality and best practices";
          tools = [ "Read" "Grep" ];
          model = "sonnet";
          mode = "subagent";
        };
      };
    };

    memory = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Memory/rules file path";
    };

    enableClaudeCode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable claude-code with this configuration";
    };

    enableOpencode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable opencode with this configuration";
    };

    enableMcphub = mkOption {
      type = types.bool;
      default = false;
      description = "Enable mcphub.nvim with this configuration";
    };
  };

  config = mkIf cfg.enable {
    # Configure claude-code
    programs.claude-code = mkIf cfg.enableClaudeCode (mkMerge [
      {
        enable = true;
        package = pkgs.claude-code;
        mcpServers = cfg.mcpServers;
        settings = {
          theme = "dark";
          preferredNotifChannel = "native";
        };
      }
      (mkIf (claudeAgentsDir != null) { agentsDir = claudeAgentsDir; })
      (mkIf (cfg.memory != null) { memory.source = cfg.memory; })
    ]);

    # Configure opencode
    programs.opencode = mkIf cfg.enableOpencode (mkMerge [
      {
        enable = true;
        package = pkgs.opencode;
        settings = {
          theme = "dark";
          mcp = lib.mapAttrs transformMcpForOpencode cfg.mcpServers;
        };
      }
      (mkIf (opencodeAgents != { }) { agents = opencodeAgents; })
      (mkIf (cfg.memory != null) { rules = cfg.memory; })
    ]);

    # Configure mcphub.nvim
    home.file.".config/mcphub/servers.json" = mkIf cfg.enableMcphub {
      text = mcphubConfig;
    };
  };
}
