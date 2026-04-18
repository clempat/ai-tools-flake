# MCP server configurations (claude-code format)
#
# Architecture:
# - Bifrost Code Mode: single MCP gateway with lazy tool discovery
#   4 meta-tools: listToolFiles, readToolFile, getToolDocs, executeToolCode
#   All remote MCP servers accessed through Bifrost (no mcp.patout.app)
# - Local servers: stdio-based, run on workstation directly
# - CLI tools: atlassian (acli), github (gh) — no MCP needed
{
  # ── Bifrost Code Mode (platform-level lazy MCP discovery) ──────────
  bifrost = {
    enable = true;
    type = "http";
    url = "https://bifrost.patout.xyz/mcp";
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
    enable = true;
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
}
