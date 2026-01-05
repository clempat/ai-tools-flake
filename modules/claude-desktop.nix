# Claude Desktop configuration module
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.ai-tools;
  shared = import ./ai-tools-shared.nix { inherit lib pkgs; };

  # Hardcoded personal configuration
  personalMcpServers = import ../config/mcps.nix { inherit pkgs lib; };

  # Capture PATH from the shell at evaluation time (when home-manager switch runs)
  # This ensures Claude Desktop MCP servers have access to the same binaries as your terminal
  # See: https://emmanuelbernard.com/blog/2025/04/07/mcp-servers-and-claude-desktop-path/
  defaultMcpPath = "/run/current-system/sw/bin:$PATH"; # builtins.getEnv "PATH";

  # Transform MCP server for Claude Desktop
  # IMPORTANT: claude_desktop_config.json ONLY supports stdio servers
  # HTTP/remote servers must be added manually via Claude Desktop UI:
  # Settings → Connectors → Add custom connector
  transformMcpForClaudeDesktop = name: server:
    if server.type == "stdio" then
      let
        # Merge default PATH with any existing env from server config
        defaultEnv = { PATH = defaultMcpPath; };
        serverEnv = server.env or { };
        mergedEnv = defaultEnv // serverEnv;
      in {
        command = server.command;
        args = server.args;
        env = mergedEnv;
      }
    else
    # Skip non-stdio servers (they require manual UI configuration)
      null;

  # Get ALL HTTP MCP servers
  httpMcpServers =
    lib.filterAttrs (name: server: server.type == "http") personalMcpServers;

  # Transform HTTP servers to use mcp-proxy for stdio connection
  httpServersViaProxy = lib.mapAttrs (name: server:
    let
      # Convert headers to mcp-proxy --headers arguments
      headerArgs = lib.flatten
        (lib.mapAttrsToList (key: value: [ "--headers" key value ])
          (server.headers or { }));
    in {
      command = "${pkgs.mcp-proxy}/bin/mcp-proxy";
      args = [ "--transport" "streamablehttp" ] ++ headerArgs ++ [ server.url ];
      env = { PATH = defaultMcpPath; };
    }) httpMcpServers;

  # Generate Claude Desktop config JSON (stdio servers + HTTP via proxy)
  stdioServers = lib.filterAttrs (name: config: config != null)
    (lib.mapAttrs transformMcpForClaudeDesktop personalMcpServers);

  # Combine stdio servers with HTTP servers (via mcp-proxy)
  allServers = stdioServers // httpServersViaProxy;

  claudeDesktopConfig = { mcpServers = allServers; };

  # Detect if running on macOS
  isDarwin = pkgs.stdenv.isDarwin;

in {
  config = mkIf (cfg.enable && isDarwin) {
    # Install mcp-proxy if there are HTTP servers
    home.packages = mkIf (httpMcpServers != { }) [ pkgs.mcp-proxy ];

    # Generate Claude Desktop config
    home.file."Library/Application Support/Claude/claude_desktop_config.json" =
      {
        text = builtins.toJSON claudeDesktopConfig;
      };
  };
}
