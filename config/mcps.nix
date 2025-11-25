# Default MCP server configurations (claude-code format)
# 
# Claude Desktop Integration:
# - ALL servers included in claude_desktop_config.json (regardless of enable flag)
# - stdio servers: Direct stdio connection ✓
# - http servers: Via mcp-proxy (as stdio) ✓
# - Toggle servers on/off manually in Claude Desktop UI
# 
# OpenCode Integration:
# - ALL servers included in config.json
# - enable = false → Disabled via tools section (lazy loading)
# - enable = true → Enabled and active
{
  nixos = {
    enable = false; # Per-agent only
    type = "stdio"; # ✓ Auto-configured for Claude Desktop
    command = "/run/current-system/sw/bin/nix";
    args = [
      "run"
      "github:utensils/mcp-nixos"
      "--"
    ];
  };

  figma-desktop = {
    enable = false;
    type = "http"; # ⚠ Add manually: http://127.0.0.1:3845/mcp
    url = "http://127.0.0.1:3845/mcp";
  };

  atlassian = {
    enable = false;
    type = "http"; # ⚠ Add manually: https://mcp.patout.app/mcp/atlassian
    url = "https://mcp.patout.app/mcp/atlassian";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };

  github = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/github";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };

  brave-search = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/brave-search";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };

  sentry = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/sentry";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };

  n8n = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/n8n";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };

  todoist = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/todoist";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };

  playwright = {
    enable = false;
    type = "stdio"; # ✓ Auto-configured for Claude Desktop
    command = "npx";
    args = [
      "@playwright/mcp@latest "
      "--headless"
    ];
  };

  context7 = {
    enable = true; # Enabled globally for all agents
    type = "http"; # ⚠ Add manually: https://mcp.patout.app/mcp/context7
    url = "https://mcp.patout.app/mcp/context7";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };
}
