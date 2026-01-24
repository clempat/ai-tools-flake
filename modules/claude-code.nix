# Claude Code configuration module
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.ai-tools;
  shared = import ./ai-tools-shared.nix { inherit lib pkgs; };

  # Beads hook command with optional stealth mode
  beadsHookCommand = if cfg.beads.hooks.stealth then "bd prime --stealth" else "bd prime";

  # Hardcoded personal configuration
  baseMcpServers = import ../config/mcps.nix;
  personalAgents = import ../config/agents.nix;
  personalMemory = ../config/memory.md;

  # Override beads MCP server enable state based on ai-tools.beads.enable
  personalMcpServers =
    baseMcpServers
    // (optionalAttrs (baseMcpServers ? beads) {
      beads = baseMcpServers.beads // {
        enable = cfg.beads.enable;
      };
    });

  enabledMcpList = lib.attrNames (
    lib.filterAttrs (name: server: server.enable or false) personalMcpServers
  );

  # Generate list of disabled MCP servers for claude-code settings
  disabledMcpServers = lib.attrNames (
    lib.filterAttrs (name: server: !(server.enable or false)) personalMcpServers
  );

  # Convert mcps list to Claude Code tools format (mcp__{name})
  mcpListToClaudeTools = mcps: map (name: "mcp__${name}") mcps;

  # Generate claude-code agent frontmatter
  generateClaudeFrontmatter =
    name: agent:
    let
      # Merge base tools with MCP tools from mcps list
      mcpList =
        enabledMcpList
        ++ (
          if (agent.mcps or null) != null then
            agent.mcps
          else if (agent.opencodeTools or null) != null then
            # Backward compat: convert old opencodeTools format
            map (pattern: lib.removeSuffix "*" pattern) (lib.attrNames agent.opencodeTools)
          else
            [ ]
        );

      allTools =
        (agent.tools or [ ])
        ++ mcpListToClaudeTools (lib.unique mcpList);

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

  # Generate claude agent file with frontmatter + content
  generateClaudeAgentFile =
    name: agent:
    let
      frontmatter = generateClaudeFrontmatter name agent;
      content = builtins.readFile agent.content;
      fullContent = ''
        ${frontmatter}
        ${content}
      '';
    in
    pkgs.writeText "${name}.md" fullContent;

  # Convert agents to directories for Claude Code
  claudeAgentsDir =
    if personalAgents != { } then
      pkgs.linkFarm "claude-agents" (
        lib.mapAttrsToList (name: agent: {
          name = "${name}.md";
          path = generateClaudeAgentFile name agent;
        }) (lib.filterAttrs (name: agent: !(agent.disable or false)) personalAgents)
      )
    else
      null;

in
{
  config = mkIf cfg.enable (mkMerge [
    {
      programs.claude-code = {
        enable = true;
        package = mkDefault pkgs.claude-code;
        mcpServers = personalMcpServers;
        settings = {
          theme = "dark";
          preferredNotifChannel = "native";
          disabledMcpjsonServers = disabledMcpServers;
        }
        // (optionalAttrs (cfg.beads.enable && cfg.beads.hooks.enable) {
          # Beads integration hooks - auto-inject workflow context
          hooks = {
            SessionStart = [
              {
                matcher = "";
                hooks = [
                  {
                    type = "command";
                    command = beadsHookCommand;
                  }
                ];
              }
            ];
            PreCompact = [
              {
                matcher = "";
                hooks = [
                  {
                    type = "command";
                    command = beadsHookCommand;
                  }
                ];
              }
            ];
          };
        });
      };
    }
    (mkIf (claudeAgentsDir != null) {
      programs.claude-code.agentsDir = claudeAgentsDir;
    })
    {
      programs.claude-code.memory.source = personalMemory;
      programs.claude-code.commands = shared.commandsAttrSet;
    }
  ]);
}
