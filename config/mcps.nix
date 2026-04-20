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

}
