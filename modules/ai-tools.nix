{ config, lib, pkgs, inputs, system, ... }:

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

  # Hardcoded personal configuration
  personalMcpServers = import ../config/mcps.nix;
  personalAgents = import ../config/agents.nix;
  personalMemory = ../config/memory.md;

  # Generate mcphub.nvim servers.json
  mcphubServers = lib.mapAttrs transformMcpForMcphub personalMcpServers;
  mcphubConfig = builtins.toJSON { mcpServers = mcphubServers; };

  # Generate claude-code agent frontmatter
  generateClaudeFrontmatter = name: agent:
    let
      fields = lib.optionals (!(agent.disable or false))
        ([ "name: ${name}" "description: |" "  ${agent.description}" ]
          ++ lib.optional ((agent.tools or null) != null)
          "tools: [${lib.concatStringsSep ", " agent.tools}]"
          ++ lib.optional ((agent.model or null) != null) "model: ${agent.model}"
          ++ lib.optional ((agent.color or null) != null) "color: ${agent.color}");
    in ''
      ---
      ${lib.concatStringsSep "\n" fields}
      ---
    '';

  # Generate opencode agent frontmatter
  generateOpencodeFrontmatter = name: agent:
    let
      fields = [ "description: ${agent.description}" ]
        ++ lib.optional ((agent.mode or null) != null) "mode: ${agent.mode}"
        ++ lib.optional ((agent.opencodeModel or null) != null)
        "model: ${agent.opencodeModel}"
        ++ lib.optional ((agent.temperature or null) != null)
        "temperature: ${toString agent.temperature}"
        ++ lib.optional (agent.disable or false) "disable: true";

      toolsSection = lib.optionalString
        ((agent.opencodeMcp or null) != null && agent.opencodeMcp != [ ]) ''
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
  claudeAgentsDir = if personalAgents != { } then
    pkgs.linkFarm "claude-agents" (lib.mapAttrsToList (name: agent: {
      name = "${name}.md";
      path = generateAgentFile "claude" name agent;
    }) (lib.filterAttrs (name: agent: !(agent.disable or false)) personalAgents))
  else
    null;

  opencodeAgents =
    lib.mapAttrs (name: agent: generateAgentFile "opencode" name agent)
    (lib.filterAttrs (name: agent: !(agent.disable or false)) personalAgents);

in {
  options.programs.ai-tools = {
    enable = mkEnableOption "unified AI tools configuration";

    enableClaudeCode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable claude-code";
    };

    enableOpencode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable opencode";
    };

    enableMcphub = mkOption {
      type = types.bool;
      default = false;
      description = "Enable mcphub.nvim";
    };
  };

  config = mkIf cfg.enable {
    # Configure claude-code
    programs.claude-code = mkIf cfg.enableClaudeCode (mkMerge [
      {
        enable = true;
        package = inputs.ai-tools.packages.${system}.claude-code;
        mcpServers = personalMcpServers;
        settings = {
          theme = "dark";
          preferredNotifChannel = "native";
        };
      }
      (mkIf (claudeAgentsDir != null) { agentsDir = claudeAgentsDir; })
      { memory.source = personalMemory; }
    ]);

    # Configure opencode
    programs.opencode = mkIf cfg.enableOpencode (mkMerge [
      {
        enable = true;
        package = inputs.ai-tools.packages.${system}.opencode;
        settings = {
          theme = "dark";
          mcp = lib.mapAttrs transformMcpForOpencode personalMcpServers;
        };
      }
      (mkIf (opencodeAgents != { }) { agents = opencodeAgents; })
      { rules = personalMemory; }
    ]);

    # Configure mcphub.nvim
    home.file.".config/mcphub/servers.json" = mkIf cfg.enableMcphub {
      text = mcphubConfig;
    };
  };
}
