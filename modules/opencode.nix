# OpenCode configuration module
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

  # Hardcoded personal configuration
  baseMcpServers = import ../config/mcps.nix;
  personalAgents = import ../config/agents.nix;
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

  enabledMcpList = lib.attrNames (
    lib.filterAttrs (name: server: server.enable or false) personalMcpServers
  );

  # Transform MCP server for opencode
  # Remove 'enable' field - we control availability via tools section
  # Add oauth = false for HTTP MCPs with headers (v1.0.137+ auto-enables OAuth)
  transformMcpForOpencode =
    name: server:
    let
      baseServer = builtins.removeAttrs server [ "enable" ];
    in
    if baseServer.type == "http" then
      (builtins.removeAttrs baseServer [ "type" ])
      // {
        type = "remote";
      }
      // (if baseServer ? headers then { oauth = false; } else { })
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

  # Convert mcps list to Opencode tools format ({name}*: true)
  mcpListToOpencodeTools = mcps: lib.listToAttrs (map (name: lib.nameValuePair "${name}*" true) mcps);

  renderYaml =
    indent: attrs:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        key: value:
        if builtins.isAttrs value then
          "${indent}${key}:\n${renderYaml (indent + "  ") value}"
        else
          "${indent}${key}: ${
            if value == true then
              "true"
            else if value == false then
              "false"
            else
              toString value
          }"
      ) attrs
    );

  # Generate opencode agent frontmatter
  generateOpencodeFrontmatter =
    name: agent:
    let
      # Compute tools section
      opcodeTools =
        let
          agentTools =
            if (agent.mcps or null) != null then
              mcpListToOpencodeTools agent.mcps
            else if (agent.opencodeTools or null) != null then
              agent.opencodeTools
            else
              { };
          enabledTools = mcpListToOpencodeTools enabledMcpList;
        in
        agentTools // enabledTools;

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

      permissionSection = lib.optionalString ((agent.permission or null) != null) ''
        permission:
        ${renderYaml "  " agent.permission}
      '';
    in
    ''
      ---
      ${lib.concatStringsSep "\n" fields}
      ${toolsSection}
      ${permissionSection}
      ---
    '';

  # Generate opencode agent file with frontmatter + content
  generateOpencodeAgentFile =
    name: agent:
    let
      frontmatter = generateOpencodeFrontmatter name agent;
      content = builtins.readFile agent.content;
    in
    ''
      ${frontmatter}
      ${content}
    '';

  # Convert agents for OpenCode
  opencodeAgents = lib.mapAttrs (name: agent: generateOpencodeAgentFile name agent) (
    lib.filterAttrs (name: agent: !(agent.disable or false)) personalAgents
  );

  ohMyOpencodeBuiltins = [
    "librarian"
    "explore"
    "oracle"
    "metis"
    "momus"
    "atlas"
    "multimodal-looker"
    "sisyphus-junior"
  ];

  qualifyModel = model: if lib.hasInfix "/" model then model else "google/${model}";

  recommendedModelByAgent = {
    explore = "opencode/kimi-k2.5-free";
    librarian = "opencode/kimi-k2.5-free";
    atlas = "opencode/kimi-k2.5-free";
    oracle = "openai/gpt-5.3-codex";
    metis = "openai/gpt-5.3-codex";
    momus = "openai/gpt-5.3-codex";
    "multimodal-looker" = "openai/gpt-5.3-codex";
    "sisyphus-junior" = "opencode/kimi-k2.5-free";
  };

  recommendedModelByCategory = {
    quick = "opencode/kimi-k2.5-free";
    writing = "opencode/kimi-k2.5-free";
    "unspecified-low" = "opencode/kimi-k2.5-free";
    "visual-engineering" = "openai/gpt-5.3-codex";
    deep = "openai/gpt-5.3-codex";
    "unspecified-high" = "openai/gpt-5.3-codex";
    ultrabrain = "openai/gpt-5.3-codex";
    artistry = "openai/gpt-5.3-codex";
  };

  effectiveModelByAgent =
    (if cfg.opencode.useRecommendedRouting then recommendedModelByAgent else { })
    // cfg.opencode.modelByAgent;

  effectiveModelByCategory =
    (if cfg.opencode.useRecommendedRouting then recommendedModelByCategory else { })
    // cfg.opencode.modelByCategory;

  resolveOhMyOpencodeModel = name: qualifyModel (effectiveModelByAgent.${name} or cfg.opencode.model);

  ohMyOpencodeAgents = lib.genAttrs ohMyOpencodeBuiltins (name: {
    model = resolveOhMyOpencodeModel name;
  });

  ohMyOpencodeCategories = lib.mapAttrs (_: model: { model = qualifyModel model; }) effectiveModelByCategory;

in
{
  config = mkIf cfg.enable (mkMerge [
    {
      programs.opencode = {
        enable = true;
        package = mkDefault pkgs.opencode;
        settings = {
          model = qualifyModel cfg.opencode.model;
          mcp = lib.mapAttrs transformMcpForOpencode personalMcpServers;
          provider = personalProviders;
          plugin = cfg.opencode.plugins;
          tools =
            (
              # Disable per-agent MCP tools globally (those with enable = false)
              lib.mapAttrs' (name: server: lib.nameValuePair "${name}*" false) (
                lib.filterAttrs (name: server: !(server.enable or false)) personalMcpServers
              )
            )
            // {
              # Vertex (Gemini) rejects unsigned function-call history.
              # OpenCode tools key schema seems to reject ':'; disable whole default_api.
              "default_api*" = false;
            };
        };
      };
    }
    (mkIf (opencodeAgents != { }) {
      programs.opencode.agents = opencodeAgents;
    })
    {
      programs.opencode.rules = personalMemory;
        programs.opencode.commands = shared.commandsAttrSet;
        home.file = {
          ".config/opencode/skills".source = ../config/skills;
          ".config/opencode/oh-my-opencode.json".text = builtins.toJSON (
            {
              disabled_hooks = [
                # Home Manager manages ~/.config/opencode as immutable symlinks.
                # oh-my-opencode auto-update tries to rewrite opencode config and can hit EACCES.
                "auto-update-checker"
              ];
              agents = ohMyOpencodeAgents;
            }
            // lib.optionalAttrs (ohMyOpencodeCategories != { }) {
              categories = ohMyOpencodeCategories;
            }
          );
        };
      }
  ]);
}
