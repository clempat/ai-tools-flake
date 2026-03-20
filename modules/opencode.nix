# OpenCode configuration module
{ inputs }:
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.ai-tools;

  # Hardcoded personal configuration
  baseMcpServers = import ../config/mcps.nix;
  personalProviders = import ../config/providers.nix;
  personalMemory = ../config/memory.md;

  # Override beads MCP server enable state based on ai-tools.beads.enable
  personalMcpServers =
    baseMcpServers
    // (optionalAttrs (baseMcpServers ? beads) {
      beads = baseMcpServers.beads // {
        enable = cfg.beads.enable;
      };
    });

  allMcpNames = lib.attrNames personalMcpServers;
  invalidDefaultEnabledMcpTools = lib.filter (
    name: !(lib.elem name allMcpNames)
  ) cfg.opencode.defaultEnabledMcpTools;
  defaultEnabledMcpTools =
    if cfg.opencode.enableAllMcpToolsByDefault then
      allMcpNames
    else
      cfg.opencode.defaultEnabledMcpTools;

  # Transform MCP server for opencode
  # Map internal `enable` to OpenCode `enabled`
  # Add oauth = false for HTTP MCPs with headers (v1.0.137+ auto-enables OAuth)
  transformMcpForOpencode =
    name: server:
    let
      baseServer = builtins.removeAttrs server [ "enable" ];
      serverEnabled = server.enable or true;
      withEnabled = baseServer // {
        enabled = serverEnabled;
      };
    in
    if withEnabled.type == "http" then
      (builtins.removeAttrs withEnabled [ "type" ])
      // {
        type = "remote";
      }
      // (if withEnabled ? headers then { oauth = false; } else { })
    else if withEnabled.type == "stdio" then
      let
        withoutOldFields = builtins.removeAttrs withEnabled [
          "type"
          "command"
          "args"
          "env"
        ];
        withCommand = withoutOldFields // {
          type = "local";
          command = [ withEnabled.command ] ++ withEnabled.args;
        };
      in
      if withEnabled ? env then withCommand // { environment = withEnabled.env; } else withCommand
    else
      withEnabled;

  # Convert mcps list to Opencode tools format ({name}*: true)
  mcpListToOpencodeTools = mcps: lib.listToAttrs (map (name: lib.nameValuePair "${name}*" true) mcps);

  ohMyOpencodeBuiltins = [
    "orchestrator"
    "explorer"
    "oracle"
    "librarian"
    "designer"
    "fixer"
  ];

  recommendedModelByAgent = {
    orchestrator = "openai/gpt-5.3-codex";
    explorer = "openai/gpt-4.1-mini";
    oracle = "openai/gpt-5.3-codex";
    librarian = "openai/gpt-4.1-mini";
    designer = "openai/gpt-5.3-codex";
    fixer = "openai/gpt-4.1-mini";
  };

  effectiveModelByAgent =
    (if cfg.opencode.useRecommendedRouting then recommendedModelByAgent else { })
    // cfg.opencode.modelByAgent;

  resolveOhMyOpencodeModel = name: effectiveModelByAgent.${name} or cfg.opencode.model;

  ohMyOpencodeAgents = lib.genAttrs ohMyOpencodeBuiltins (name: {
    model = resolveOhMyOpencodeModel name;
  });

in
{
  config = mkIf cfg.enable (mkMerge [
    {
      programs.opencode = {
        enable = true;
        package = mkDefault pkgs.opencode;
        settings = {
          model = cfg.opencode.model;
          mcp = lib.mapAttrs transformMcpForOpencode personalMcpServers;
          provider = personalProviders;
          plugin = cfg.opencode.plugins;
          tools = (mcpListToOpencodeTools defaultEnabledMcpTools) // {
            # Vertex (Gemini) rejects unsigned function-call history.
            # OpenCode tools key schema seems to reject ':'; disable whole default_api.
            "default_api*" = false;
          };
          # Disable built-in typescript-language-server (uses tsserver, ~1GB RAM)
          # and replace with tsgo (10x faster, 10% memory)
          lsp.typescript.disabled = true;
          lsp.tsgo = {
            command = [ "${pkgs.typescript-go}/bin/tsgo" "--lsp" "--stdio" ];
            extensions = [ ".ts" ".tsx" ".js" ".jsx" ".mjs" ".cjs" ".mts" ".cts" ];
          };
        };
      };
    }
    {
      assertions = [
        {
          assertion = invalidDefaultEnabledMcpTools == [ ];
          message =
            "programs.ai-tools.opencode.defaultEnabledMcpTools contains unknown MCP names: "
            + (lib.concatStringsSep ", " invalidDefaultEnabledMcpTools);
        }
      ];
    }
    {
      programs.opencode.rules = personalMemory;
      home.file = lib.optionalAttrs (cfg.tmux.enable && cfg.tmux.agentIndicator.enable) {
        ".config/opencode/plugins/opencode-tmux-agent-indicator.js".text = let
          script = "${pkgs.tmux-agent-indicator}/share/tmux-plugins/agent-indicator/scripts/agent-state.sh";
        in ''
          // tmux-agent-indicator + pane title plugin for OpenCode (nix-managed).
          export const TmuxAgentIndicator = async ({ $ }) => {
            const script = "${script}";
            let lastState = "off";
            let idleAt = 0;

            const setState = async (state) => {
              if (state === lastState) return;
              lastState = state;
              try {
                if (state === "running") {
                  await $`bash ${"$"}{script} --agent opencode --state off`;
                }
                await $`bash ${"$"}{script} --agent opencode --state ${"$"}{state}`;
              } catch {}
            };

            return {
              event: async ({ event }) => {
                if (event.type === "session.status"
                    && event.properties.status.type === "busy") {
                  if (Date.now() - idleAt < 2000) return;
                  await setState("running");
                }
                if (event.type === "permission.updated"
                    || event.type === "permission.asked") {
                  await setState("needs-input");
                }
                if (event.type === "session.idle" || event.type === "session.error") {
                  idleAt = Date.now();
                  await setState("done");
                }
                if ((event.type === "session.updated" || event.type === "session.created")
                    && event.properties?.info?.title) {
                  try {
                    const title = event.properties.info.title;
                    await $`tmux select-pane -T ${"$"}{title}`;
                  } catch {}
                }
              },
              "permission.ask": async () => { await setState("needs-input"); },
              "tool.execute.before": async (input) => {
                if (input.tool === "question") await setState("needs-input");
              },
            };
          };
        '';
      } // {
        ".config/opencode/oh-my-opencode-slim.json".text = builtins.toJSON {
          preset = "nix";
          presets.nix = ohMyOpencodeAgents;
        };
      };
    }
  ]);
}
