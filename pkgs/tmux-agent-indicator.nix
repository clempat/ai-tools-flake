{
  lib,
  fetchFromGitHub,
  tmuxPlugins,
}:

tmuxPlugins.mkTmuxPlugin {
  pluginName = "agent-indicator";
  version = "unstable-2026-03-05";
  src = fetchFromGitHub {
    owner = "accessd";
    repo = "tmux-agent-indicator";
    rev = "01b363c85edc1964cc8707ff2dd3a197fec8c57d";
    hash = "sha256-AFFFrg2ooz4cNhaolx5CrjWT6w7yD2a3TniDom/nV1E=";
  };
  meta = {
    description =
      "Tmux plugin showing AI agent state (running/needs-input/done) in status bar";
    homepage = "https://github.com/accessd/tmux-agent-indicator";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
