{
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
}
