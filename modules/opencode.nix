# OpenCode configuration module
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ai-tools;
  shared = import ./ai-tools-shared.nix { inherit lib pkgs; };

  # Hardcoded personal configuration
  personalMcpServers = import ../config/mcps.nix;
  personalAgents = import ../config/agents.nix;
  personalMemory = ../config/memory.md;

  # Transform MCP server for opencode
  # Remove 'enable' field - we control availability via tools section
  # Add oauth = false for HTTP MCPs with headers (v1.0.137+ auto-enables OAuth)
  transformMcpForOpencode = name: server:
    let baseServer = builtins.removeAttrs server [ "enable" ];
    in if baseServer.type == "http" then
      (builtins.removeAttrs baseServer [ "type" ]) // { type = "remote"; }
        // (if baseServer ? headers then { oauth = false; } else { })
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

  # Convert mcps list to Opencode tools format ({name}*: true)
  mcpListToOpencodeTools = mcps:
    lib.listToAttrs (map (name: lib.nameValuePair "${name}*" true) mcps);

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

  # Generate opencode agent file with frontmatter + content
  generateOpencodeAgentFile = name: agent:
    let
      frontmatter = generateOpencodeFrontmatter name agent;
      content = builtins.readFile agent.content;
    in ''
      ${frontmatter}
      ${content}
    '';

  # Convert agents for OpenCode
  opencodeAgents =
    lib.mapAttrs (name: agent: generateOpencodeAgentFile name agent)
    (lib.filterAttrs (name: agent: !(agent.disable or false)) personalAgents);

in {
  config = mkIf cfg.enable (mkMerge [
    {
      programs.opencode = {
        enable = true;
        package = mkDefault pkgs.opencode;
        settings = {
          theme = "dark";
          mcp = lib.mapAttrs transformMcpForOpencode personalMcpServers;
          tools =
            # Disable per-agent MCP tools globally (those with enable = false)
            lib.mapAttrs' (name: server: lib.nameValuePair "${name}*" false)
            (lib.filterAttrs (name: server: !(server.enable or false))
              personalMcpServers);
        };
      };
    }
    (mkIf (opencodeAgents != { }) {
      programs.opencode.agents = opencodeAgents;
    })
    {
      programs.opencode.rules = personalMemory;
      programs.opencode.commands = shared.commandsAttrSet;
    }
  ]);
}
