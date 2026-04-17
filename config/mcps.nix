# Default MCP server configurations (claude-code format)
#
# Architecture:
# - Bifrost Code Mode: primary MCP gateway (4 meta-tools, lazy discovery)
#   Servers in Bifrost: slack, exa, refs, ha-extended, mensa, schoolfox, matrix, honcho
# - Local servers: stdio-based, run on workstation directly
# - mcp.patout.app: legacy gateway, to be migrated into Bifrost (follow-up)
#
# Claude Desktop Integration:
# - ALL servers included in claude_desktop_config.json
# - stdio servers: Direct stdio connection
# - http servers: Via mcp-proxy (as stdio)
# - Toggle state controlled manually in Claude Desktop UI
#
# OpenCode Integration:
# - ALL servers included in config.json
# - enable = false → Disabled via tools section (lazy loading)
# - enable = true → Enabled and active
{
  # ── Bifrost Code Mode (platform-level lazy MCP discovery) ──────────
  # All MCP servers registered in Bifrost are accessible through 4 meta-tools:
  # listToolFiles, readToolFile, getToolDocs, executeToolCode
  # No per-server schema bloat — tools discovered on demand.
  bifrost = {
    enable = true;
    type = "http";
    url = "https://bifrost.patout.xyz/mcp";
    # Auth: OneCLI MITM proxy injects Bifrost virtual key on ai-workstation-01
    # No key in config — agentic work only runs on ai-workstation-01
  };

  # ── Local servers (stdio, run on workstation) ──────────────────────
  nixos = {
    enable = false;
    type = "stdio";
    command = "/run/current-system/sw/bin/nix";
    args = [
      "run"
      "github:utensils/mcp-nixos"
      "--"
    ];
  };

  figma-desktop = {
    enable = false;
    type = "http";
    url = "http://127.0.0.1:3845/mcp";
  };

  chrome-devtools = {
    enable = false;
    type = "stdio";
    command = "npx";
    args = [
      "-y"
      "chrome-devtools-mcp@latest"
    ];
  };

  beads = {
    enable = true; # Can be overridden by ai-tools.beads.enable
    type = "stdio";
    command = "uv";
    args = [
      "run"
      "--with"
      "beads-mcp"
      "beads-mcp"
    ];
    env = { };
  };

  # ── Legacy mcp.patout.app (migrate into Bifrost as follow-up) ─────
  atlassian = {
    enable = false;
    type = "http";
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

  n8n-official = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/n8n-official";
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

  grep_app = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/grep_app";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };

  unifi = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/unifi";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };

  youtube-transcript = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/youtube-transcript";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };

  youtube = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/youtube";
    headers = {
      Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj";
    };
  };
}
