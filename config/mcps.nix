# Default MCP server configurations (claude-code format)
# 
# Claude Desktop Integration:
# - ALL servers included in claude_desktop_config.json
# - stdio servers: Direct stdio connection ✓
# - http servers: Via mcp-proxy (as stdio) ✓
# - Toggle state controlled manually in Claude Desktop UI (persists across restarts)
# - enable flag has no effect on Claude Desktop (only affects OpenCode)
# 
# OpenCode Integration:
# - ALL servers included in config.json
# - enable = false → Disabled via tools section (lazy loading)
# - enable = true → Enabled and active
{ pkgs, ... }: {
  nixos = {
    enable = false;
    type = "stdio";
    command = "/run/current-system/sw/bin/nix";
    args = [ "run" "github:utensils/mcp-nixos" "--" ];
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
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };

  github = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/github";
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };

  brave-search = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/brave-search";
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };

  sentry = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/sentry";
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };

  n8n = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/n8n";
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };

  n8n-official = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/n8n-official";
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };

  todoist = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/todoist";
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };

  context7 = {
    enable = true;
    type = "http";
    url = "https://mcp.patout.app/mcp/context7";
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };

  chrome-devtools = {
    enable = false;
    type = "stdio";
    command = "${pkgs.nodejs}/bin/npx";
    args = [ "-y" "chrome-devtools-mcp@latest" ];
    env = { PATH = "${pkgs.nodejs}/bin:/run/current-system/sw/bin"; };
  };

  unifi = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/unifi";
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };

  youtube-transcript = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/youtube-transcript";
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };

  youtube = {
    enable = false;
    type = "http";
    url = "https://mcp.patout.app/mcp/youtube";
    headers = { Authorization = "Bearer wH0wuvH41jffjE1aFO7qlcl0OX7TtvWj"; };
  };
}
