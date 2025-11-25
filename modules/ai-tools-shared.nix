# Shared functions and utilities for AI tools configuration
{ lib, pkgs, ... }:

with lib;

rec {
  # Transform MCP server for opencode
  # Remove 'enable' field - we control availability via tools section
  transformMcpForOpencode = name: server:
    let baseServer = builtins.removeAttrs server [ "enable" ];
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

  # Transform MCP server for Claude Desktop
  transformMcpForClaudeDesktop = name: server:
    let
      baseConfig = if server.type == "stdio" then
        {
          command = server.command;
          args = server.args;
        } // lib.optionalAttrs (server ? env) { env = server.env; }
      else if server.type == "http" then
      # Claude Desktop supports remote MCP servers (Custom Connectors)
      # Note: OAuth configuration must be done manually in Claude Desktop UI
      # We can only provide the URL and type in the config file
      {
        type = "http";
        url = server.url;
      } else
        null;
    in baseConfig;

  # Convert mcps list to Claude Code tools format (mcp__{name})
  mcpListToClaudeTools = mcps: map (name: "mcp__${name}") mcps;

  # Convert mcps list to Opencode tools format ({name}*: true)
  mcpListToOpencodeTools = mcps:
    lib.listToAttrs (map (name: lib.nameValuePair "${name}*" true) mcps);

  # Generate claude-code agent frontmatter
  generateClaudeFrontmatter = name: agent:
    let
      # Merge base tools with MCP tools from mcps list
      allTools = (agent.tools or [ ]) ++ (if (agent.mcps or null) != null then
        mcpListToClaudeTools agent.mcps
      else if (agent.opencodeTools or null) != null then
      # Backward compat: convert old opencodeTools format
        map (pattern: "mcp__${lib.removeSuffix "*" pattern}")
        (lib.attrNames agent.opencodeTools)
      else
        [ ]);

      fields = lib.optionals (!(agent.disable or false))
        ([ "name: ${name}" "description: |" "  ${agent.description}" ]
          ++ lib.optional (allTools != [ ])
          "tools: [${lib.concatStringsSep ", " allTools}]"
          ++ lib.optional ((agent.model or null) != null)
          "model: ${agent.model}"
          ++ lib.optional ((agent.color or null) != null)
          "color: ${agent.color}");
    in ''
      ---
      ${lib.concatStringsSep "\n" fields}
      ---
    '';

  # Generate opencode agent frontmatter
  generateOpencodeFrontmatter = name: agent:
    let
      # Compute tools section
      opcodeTools = if (agent.mcps or null) != null then
        mcpListToOpencodeTools agent.mcps
      else if (agent.opencodeTools or null) != null then
        agent.opencodeTools
      else
        { };

      fields = [ "description: ${agent.description}" ]
        ++ lib.optional ((agent.mode or null) != null) "mode: ${agent.mode}"
        ++ lib.optional ((agent.opencodeModel or null) != null)
        "model: ${agent.opencodeModel}"
        ++ lib.optional ((agent.temperature or null) != null)
        "temperature: ${toString agent.temperature}"
        ++ lib.optional (agent.disable or false) "disable: true";

      toolsSection = lib.optionalString (opcodeTools != { }) ''
        tools:
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (pattern: enabled:
          "  ${pattern}: ${if enabled then "true" else "false"}") opcodeTools)}
      '';
    in ''
      ---
      ${lib.concatStringsSep "\n" fields}
      ${toolsSection}
      ---
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

  # Convert commands directory to attribute set for home-manager
  commandsAttrSet = let
    commandsDir = ../config/commands;
    commandFiles = builtins.readDir commandsDir;
  in lib.mapAttrs' (name: type:
    let
      # Remove .md extension for command name
      commandName = lib.removeSuffix ".md" name;
    in lib.nameValuePair commandName (commandsDir + "/${name}"))
  (lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name)
    commandFiles);

  # Generate mcphub.nvim servers.json
  generateMcphubConfig = personalMcpServers:
    let
      mcphubServers = lib.mapAttrs transformMcpForMcphub personalMcpServers;
    in builtins.toJSON { mcpServers = mcphubServers; };
}
