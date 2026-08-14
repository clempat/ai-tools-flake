# MCP server configurations (claude-code format)
#
# Architecture:
# - MCPHub smart routing: single gateway with lazy tool discovery
#   All remote MCP servers accessed through MCPHub (mcp.patout.xyz)
# - Local servers: stdio-based, run on workstation directly
# - CLI tools: atlassian (acli), github (gh) — no MCP needed
{
  # ── MCPHub smart routing (platform-level lazy MCP discovery) ───────
  mcphub_shared = {
    enable = true;
    type = "http";
    url = "https://mcp.patout.xyz/mcp/$smart/Shared";
    headers = {
      Authorization = "Bearer {env:MCPHUB_API_KEY}";
    };
  };

}
