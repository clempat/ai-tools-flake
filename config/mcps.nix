# Default MCP server configurations (claude-code format)
# 
# Claude Desktop Integration:
# - stdio servers: Auto-configured via claude_desktop_config.json ✓
# - http servers: Must be added manually via Claude Desktop UI ⚠
#   (Settings → Connectors → Add custom connector → Enter URL)
{
  nixos = {
    enable = false; # Per-agent only
    type = "stdio"; # ✓ Auto-configured for Claude Desktop
    command = "nix";
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
