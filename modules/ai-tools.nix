{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:

with lib;

let
  cfg = config.programs.ai-tools;

  # Transform MCP server for opencode
  # Remove 'enable' field - we control availability via tools section
  transformMcpForOpencode =
    name: server:
    let
      baseServer = builtins.removeAttrs server [ "enable" ];
    in
    if baseServer.type == "http" then
      (builtins.removeAttrs baseServer [ "type" ]) // { type = "remote"; }
    else if baseServer.type == "stdio" then
      let
        withoutOldFields = builtins.removeAttrs baseServer [
          "type"
          "command"
          "args"
          "env"
        ];
        withCommand = withoutOldFields // {
          type = "local";
          command = [ baseServer.command ] ++ baseServer.args;
        };
      in
      if baseServer ? env then withCommand // { environment = baseServer.env; } else withCommand
    else
      baseServer;

  # Transform MCP server for mcphub.nvim
  transformMcpForMcphub =
    name: server:
    let
      # mcphub uses "disabled" instead of "enable"
      baseServer = builtins.removeAttrs server [
        "enable"
        "type"
      ];
      withDisabled = if server ? enable then baseServer // { disabled = !server.enable; } else baseServer;
    in
    if server.type == "http" then
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

  # Generate list of disabled MCP servers for claude-code settings
  disabledMcpServers = lib.attrNames (
    lib.filterAttrs (name: server: !(server.enable or false)) personalMcpServers
  );

  # Generate mcphub.nvim servers.json
  mcphubServers = lib.mapAttrs transformMcpForMcphub personalMcpServers;
  mcphubConfig = builtins.toJSON { mcpServers = mcphubServers; };

  # Convert mcps list to Claude Code tools format (mcp__{name})
  mcpListToClaudeTools = mcps: map (name: "mcp__${name}") mcps;

  # Convert mcps list to Opencode tools format ({name}*: true)
  mcpListToOpencodeTools = mcps: lib.listToAttrs (map (name: lib.nameValuePair "${name}*" true) mcps);

  # Generate claude-code agent frontmatter
  generateClaudeFrontmatter =
    name: agent:
    let
      # Merge base tools with MCP tools from mcps list
      allTools =
        (agent.tools or [ ])
        ++ (
          if (agent.mcps or null) != null then
            mcpListToClaudeTools agent.mcps
          else if (agent.opencodeTools or null) != null then
            # Backward compat: convert old opencodeTools format
            map (pattern: "mcp__${lib.removeSuffix "*" pattern}") (lib.attrNames agent.opencodeTools)
          else
            [ ]
        );

      fields = lib.optionals (!(agent.disable or false)) (
        [
          "name: ${name}"
          "description: |"
          "  ${agent.description}"
        ]
        ++ lib.optional (allTools != [ ]) "tools: [${lib.concatStringsSep ", " allTools}]"
        ++ lib.optional ((agent.model or null) != null) "model: ${agent.model}"
        ++ lib.optional ((agent.color or null) != null) "color: ${agent.color}"
      );
    in
    ''
      ---
      ${lib.concatStringsSep "\n" fields}
      ---
    '';

  # Generate opencode agent frontmatter
  generateOpencodeFrontmatter =
    name: agent:
    let
      # Compute tools section
      opcodeTools =
        if (agent.mcps or null) != null then
          mcpListToOpencodeTools agent.mcps
        else if (agent.opencodeTools or null) != null then
          agent.opencodeTools
        else
          { };

      fields = [
        "description: ${agent.description}"
      ]
      ++ lib.optional ((agent.mode or null) != null) "mode: ${agent.mode}"
      ++ lib.optional ((agent.opencodeModel or null) != null) "model: ${agent.opencodeModel}"
      ++ lib.optional ((agent.temperature or null) != null) "temperature: ${toString agent.temperature}"
      ++ lib.optional (agent.disable or false) "disable: true";

      toolsSection = lib.optionalString (opcodeTools != { }) ''
        tools:
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            pattern: enabled: "  ${pattern}: ${if enabled then "true" else "false"}"
          ) opcodeTools
        )}
      '';
    in
    ''
      ---
      ${lib.concatStringsSep "\n" fields}
      ${toolsSection}
      ---
    '';

  # Generate agent file with frontmatter + content
  generateAgentFile =
    format: name: agent:
    let
      frontmatter =
        if format == "claude" then
          generateClaudeFrontmatter name agent
        else
          generateOpencodeFrontmatter name agent;
      content = builtins.readFile agent.content;
      fullContent = ''
        ${frontmatter}
        ${content}
      '';
    in
    if format == "claude" then pkgs.writeText "${name}.md" fullContent else fullContent; # opencode expects text, not derivation

  # Convert agents to directories for each tool
  claudeAgentsDir =
    if personalAgents != { } then
      pkgs.linkFarm "claude-agents" (
        lib.mapAttrsToList (name: agent: {
          name = "${name}.md";
          path = generateAgentFile "claude" name agent;
        }) (lib.filterAttrs (name: agent: !(agent.disable or false)) personalAgents)
      )
    else
      null;

  opencodeAgents = lib.mapAttrs (name: agent: generateAgentFile "opencode" name agent) (
    lib.filterAttrs (name: agent: !(agent.disable or false)) personalAgents
  );

  # Convert commands directory to attribute set for home-manager
  commandsAttrSet =
    let
      commandsDir = ../config/commands;
      commandFiles = builtins.readDir commandsDir;
    in
    lib.mapAttrs' (
      name: type:
      let
        # Remove .md extension for command name
        commandName = lib.removeSuffix ".md" name;
      in
      lib.nameValuePair commandName (commandsDir + "/${name}")
    ) (lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name) commandFiles);

in
{
  options.programs.ai-tools = {
    enable = mkEnableOption "unified AI tools configuration";
  };

  config = mkIf cfg.enable (mkMerge [
    # Configure claude-code
    (mkMerge [
      {
        programs.claude-code = {
          enable = true;
          package = inputs.ai-tools.packages.${system}.claude-code;
          mcpServers = personalMcpServers;
          settings = {
            theme = "dark";
            preferredNotifChannel = "native";
            disabledMcpjsonServers = disabledMcpServers;
          };
        };
      }
      (mkIf (claudeAgentsDir != null) {
        programs.claude-code.agentsDir = claudeAgentsDir;
      })
      {
        programs.claude-code.memory.source = personalMemory;
        programs.claude-code.commands = commandsAttrSet;
      }
    ])

    # Configure opencode
    (mkMerge [
      {
        programs.opencode = {
          enable = true;
          package = inputs.ai-tools.packages.${system}.opencode;
          settings = {
            theme = "dark";
            mcp = lib.mapAttrs transformMcpForOpencode personalMcpServers;
            keybinds.session_child_cycle = "alt+right";
            keybinds.session_child_cycle_reverse = "alt+left";
            tools =
              # Disable per-agent MCP tools globally (those with enable = false)
              lib.mapAttrs' (name: server: lib.nameValuePair "${name}*" false) (
                lib.filterAttrs (name: server: !(server.enable or false)) personalMcpServers
              );
          };
        };
      }
      (mkIf (opencodeAgents != { }) {
        programs.opencode.agents = opencodeAgents;
      })
      {
        programs.opencode.rules = personalMemory;
        programs.opencode.commands = commandsAttrSet;
      }
    ])
  ]);
}
