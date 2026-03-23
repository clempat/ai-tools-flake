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

  # List panes running AI agents.
  # Detection: match by command/title pattern OR by tmux agent state env var.
  entries=""
  while IFS= read -r line; do
    pane_id=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $1}')
    cmd=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $2}')
    session=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $3}')
    window_idx=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $5}')
    pane_idx=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $6}')
    pane_title=$(echo "$line" | ${gawk}/bin/awk -F'|' '{print $7}')

    state=$(${tmux}/bin/tmux show-environment -g "TMUX_AGENT_PANE_''${pane_id}_STATE" 2>/dev/null | sed 's/^[^=]*=//' || true)

    # Include pane if:
    #  1. command/title matches known AI patterns (claude, opencode, π), OR
    #  2. agent state env var is set, OR
    #  3. 'pi' is a child process of this pane (covers pi with base64 image titles)
    is_ai=false
    if echo "$line" | grep -qiE 'claude|opencode|π'; then
      is_ai=true
    elif [ -n "$state" ]; then
      is_ai=true
    else
      pane_pid=$(${tmux}/bin/tmux display-message -t "$pane_id" -p '#{pane_pid}' 2>/dev/null || true)
      if [ -n "$pane_pid" ] && pgrep -P "$pane_pid" -x pi >/dev/null 2>&1; then
        is_ai=true
      fi
    fi

    if [ "$is_ai" = false ]; then
      continue
    fi

    icon=$(state_icon "$state")

    # Extract display title from pane_title.
    # Pane title is set by auto-title extension: "π <project> · <topic>"
    # Or legacy: "π - <project>" or raw base64 garbage.
    display_title=""
    if echo "$pane_title" | grep -q ' · '; then
      # New format: "π project · topic" → extract topic
      display_title=$(echo "$pane_title" | sed 's/^.*· //')
    fi

    # Skip if pane_title is base64 junk or too long
    if [ -z "$display_title" ] && [ ''${#pane_title} -lt 80 ] \
       && ! echo "$pane_title" | grep -qE '[A-Za-z0-9+/=]{20,}'; then
      display_title=$(echo "$pane_title" | sed 's/^π - //; s/^π //')
    fi

    # Format: "icon session · topic | pane_id"
    if [ -n "$display_title" ] && [ "$display_title" != "$session" ]; then
      entry="$icon $session · $display_title | $pane_id"
    else
      entry="$icon $session | $pane_id"
    fi
    if [ -z "$entries" ]; then
      entries="$entry"
    else
      entries="$entries"$'\n'"$entry"
    fi
  done < <(${tmux}/bin/tmux list-panes -a -F '#{pane_id}|#{pane_current_command}|#{session_name}|#{window_name}|#{window_index}|#{pane_index}|#{pane_title}')

  if [ -z "$entries" ]; then
    ${tmux}/bin/tmux display-message "No AI agent panes found"
    exit 0
  fi

  selected=$(echo "$entries" | ${fzf}/bin/fzf \
    --ansi --reverse \
    --prompt="AI Panes> " \
    --header="↑↓ navigate · enter switch · ^p preview · esc cancel" \
    --preview='pane_id=$(echo {} | ${gawk}/bin/awk -F"| " "{print \$NF}"); ${tmux}/bin/tmux capture-pane -t "$pane_id" -p -S -80' \
    --preview-window='right,60%,wrap,border-left,hidden' \
    --preview-label=' Preview ' \
    --color='preview-border:grey' \
    --bind='ctrl-/:toggle-preview' \
    --bind='ctrl-p:toggle-preview')

  if [ -n "$selected" ]; then
    target_pane=$(echo "$selected" | ${gawk}/bin/awk -F'| ' '{print $NF}')
    ${tmux}/bin/tmux switch-client -t "$target_pane"
  fi
'').overrideAttrs
  (oldAttrs: {
    meta = {
      description = "Fzf-based tmux pane browser for AI agent sessions";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
      mainProgram = "tmux-ai-pane-browser";
    };
  })
