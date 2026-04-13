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

  # Beads hook command with optional stealth mode
  beadsHookCommand =
    if cfg.beads.hooks.stealth then "bd prime --stealth" else "bd prime";

  # Tmux agent-indicator hook script path
  agentStateScript =
    "${pkgs.tmux-agent-indicator}/share/tmux-plugins/agent-indicator/scripts/agent-state.sh";

  mkHookEntry = command: [
    {
      matcher = "";
      hooks = [
        {
          type = "command";
          inherit command;
        }
      ];
    }
  ];

  beadsHooks = {
    SessionStart = mkHookEntry beadsHookCommand;
    PreCompact = mkHookEntry beadsHookCommand;
  };

  tmuxHooks = {
    UserPromptSubmit =
      mkHookEntry "${agentStateScript} --agent claude --state running";
    PermissionRequest =
      mkHookEntry "${agentStateScript} --agent claude --state needs-input";
    Stop = mkHookEntry "${agentStateScript} --agent claude --state done";
  };

  # Hardcoded personal configuration
  baseMcpServers = import ../config/mcps.nix;
  personalMemory = ../config/memory.md;

  # Override beads MCP server enable state based on ai-tools.beads.enable
  personalMcpServers =
    baseMcpServers
    // (optionalAttrs (baseMcpServers ? beads) {
      beads = baseMcpServers.beads // {
        enable = cfg.beads.enable;
      };
    });

  # Generate list of disabled MCP servers for claude-code settings
  disabledMcpServers = lib.attrNames (
    lib.filterAttrs (name: server: !(server.enable or false)) personalMcpServers
  );

in
{
  config = mkIf cfg.enable (mkMerge [
    {
      programs.claude-code = {
        enable = true;
        package = mkDefault pkgs.claude-code;
        mcpServers = personalMcpServers;
        settings = {
          theme = lib.mkDefault "dark";
          preferredNotifChannel = "native";
          disabledMcpjsonServers = disabledMcpServers;
        }
        // (let
          enableBeadsHooks = cfg.beads.enable && cfg.beads.hooks.enable;
          enableTmuxHooks =
            cfg.tmux.enable && cfg.tmux.agentIndicator.enable;
          hooks = (optionalAttrs enableBeadsHooks beadsHooks)
            // (optionalAttrs enableTmuxHooks tmuxHooks);
        in optionalAttrs (hooks != { }) { inherit hooks; });
      };
    }
    {
      programs.claude-code.memory.source = personalMemory;
    }
    {
      programs.zsh.shellAliases.cc = "claude --permission-mode bypass";
    }
  ]);
}
