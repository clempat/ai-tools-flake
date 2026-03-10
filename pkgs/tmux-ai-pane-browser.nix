{
  lib,
  writeShellScriptBin,
  tmux,
  fzf,
  gawk,
}:

(writeShellScriptBin "tmux-ai-pane-browser" ''
  set -euo pipefail

  if [ -z "''${TMUX:-}" ]; then
    echo "Not inside a tmux session" >&2
    exit 1
  fi

  state_icon() {
    case "$1" in
      running)      printf '⚙️ ' ;;
      needs-input)  printf '⏳' ;;
      done)         printf '✅' ;;
      *)            printf '  ' ;;
    esac
  }

  # List panes running claude or opencode, with agent state
  entries=""
  while IFS= read -r line; do
    pane_id=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $1}')
    session=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $3}')
    window_idx=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $5}')
    pane_idx=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $6}')
    pane_title=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $7}')

    state=$(${tmux}/bin/tmux show-environment -g "TMUX_AGENT_PANE_''${pane_id}_STATE" 2>/dev/null | sed 's/^[^=]*=//' || true)
    icon=$(state_icon "$state")

    entry="$icon $session  [$pane_title] ($window_idx.$pane_idx) | $pane_id"
    if [ -z "$entries" ]; then
      entries="$entry"
    else
      entries="$entries"$'\n'"$entry"
    fi
  done < <(${tmux}/bin/tmux list-panes -a -F '#{pane_id}|#{pane_current_command}|#{session_name}|#{window_name}|#{window_index}|#{pane_index}|#{pane_title}' \
    | grep -iE 'claude|opencode')

  if [ -z "$entries" ]; then
    ${tmux}/bin/tmux display-message "No AI agent panes found"
    exit 0
  fi

  selected=$(echo "$entries" | ${fzf}/bin/fzf --ansi --reverse --prompt="AI Panes> " --header="Select an AI agent pane")

  if [ -n "$selected" ]; then
    target_pane=$(echo "$selected" | ${gawk}/bin/awk -F'| ' '{print $NF}')
    ${tmux}/bin/tmux switch-client -t "$target_pane"
  fi
'').overrideAttrs (oldAttrs: {
  meta = {
    description = "Fzf-based tmux pane browser for AI agent sessions";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "tmux-ai-pane-browser";
  };
})
