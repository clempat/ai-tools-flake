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
  personalMcpServers = import ../config/mcps.nix { inherit pkgs lib; };
  personalAgents = import ../config/agents.nix;
  personalMemory = ../config/memory.md;

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

in
{
  config = mkIf cfg.enable (mkMerge [
    {
      programs.opencode = {
        enable = true;
        package = mkDefault pkgs.opencode;
        settings = {
          theme = "dark";
          mcp = lib.mapAttrs transformMcpForOpencode personalMcpServers;
          plugin = [
            "opencode-antigravity-auth@beta"
            "opencode-openai-codex-auth"
            "@tarquinen/opencode-dcp@latest"
            "@mohak34/opencode-notifier@latest"
          ];
          provider = {
            google = {
              models = {
                # Antigravity Gemini 3 Pro
                "antigravity-gemini-3-pro" = {
                  name = "Gemini 3 Pro (Antigravity)";
                  limit = {
                    context = 1048576;
                    output = 65535;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                      "pdf"
                    ];
                    output = [ "text" ];
                  };
                  variants = {
                    low = {
                      thinkingLevel = "low";
                    };
                    high = {
                      thinkingLevel = "high";
                    };
                  };
                };
                # Antigravity Gemini 3 Flash
                "antigravity-gemini-3-flash" = {
                  name = "Gemini 3 Flash (Antigravity)";
                  limit = {
                    context = 1048576;
                    output = 65536;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                      "pdf"
                    ];
                    output = [ "text" ];
                  };
                  variants = {
                    minimal = {
                      thinkingLevel = "minimal";
                    };
                    low = {
                      thinkingLevel = "low";
                    };
                    medium = {
                      thinkingLevel = "medium";
                    };
                    high = {
                      thinkingLevel = "high";
                    };
                  };
                };
                # Antigravity Claude Sonnet 4.5
                "antigravity-claude-sonnet-4-5" = {
                  name = "Claude Sonnet 4.5 (Antigravity)";
                  limit = {
                    context = 200000;
                    output = 64000;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                      "pdf"
                    ];
                    output = [ "text" ];
                  };
                };
                # Antigravity Claude Sonnet 4.5 Thinking
                "antigravity-claude-sonnet-4-5-thinking" = {
                  name = "Claude Sonnet 4.5 Thinking (Antigravity)";
                  limit = {
                    context = 200000;
                    output = 64000;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                      "pdf"
                    ];
                    output = [ "text" ];
                  };
                  variants = {
                    low = {
                      thinkingConfig = {
                        thinkingBudget = 8192;
                      };
                    };
                    max = {
                      thinkingConfig = {
                        thinkingBudget = 32768;
                      };
                    };
                  };
                };
                # Antigravity Claude Opus 4.5 Thinking
                "antigravity-claude-opus-4-5-thinking" = {
                  name = "Claude Opus 4.5 Thinking (Antigravity)";
                  limit = {
                    context = 200000;
                    output = 64000;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                      "pdf"
                    ];
                    output = [ "text" ];
                  };
                  variants = {
                    low = {
                      thinkingConfig = {
                        thinkingBudget = 8192;
                      };
                    };
                    max = {
                      thinkingConfig = {
                        thinkingBudget = 32768;
                      };
                    };
                  };
                };
                # Gemini CLI models (existing, included for completeness)
                "gemini-2.5-flash" = {
                  name = "Gemini 2.5 Flash (Gemini CLI)";
                  limit = {
                    context = 1048576;
                    output = 65536;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                      "pdf"
                    ];
                    output = [ "text" ];
                  };
                };
                "gemini-2.5-pro" = {
                  name = "Gemini 2.5 Pro (Gemini CLI)";
                  limit = {
                    context = 1048576;
                    output = 65536;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                      "pdf"
                    ];
                    output = [ "text" ];
                  };
                };
                "gemini-3-flash-preview" = {
                  name = "Gemini 3 Flash Preview (Gemini CLI)";
                  limit = {
                    context = 1048576;
                    output = 65536;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                      "pdf"
                    ];
                    output = [ "text" ];
                  };
                };
                "gemini-3-pro-preview" = {
                  name = "Gemini 3 Pro Preview (Gemini CLI)";
                  limit = {
                    context = 1048576;
                    output = 65535;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                      "pdf"
                    ];
                    output = [ "text" ];
                  };
                };
              };
            };
            ollama = {
              npm = "@ai-sdk/openai-compatible";
              name = "Ollama (local)";
              options = {
                baseURL = "http://localhost:11434/v1";
              };
              models = {
                "nemotron-3-nano" = {
                  name = "nemotron-3-nano";
                };
                "gpt-oss" = {
                  name = "gpt-oss";
                };
                "qwen3-coder" = {
                  name = "qwen3-coder";
                };
              };
            };
          };
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
      programs.opencode.commands = shared.commandsAttrSet;
    }
  ]);
}
