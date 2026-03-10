#!/usr/bin/env bash
# ~/.agents/statusline-command.sh
# Claude Code status line: model, context %, git/jj diff stats, rate limit bars

set -euo pipefail

# --------------------------------------------------------------------------
# ANSI color helpers
# --------------------------------------------------------------------------
ansi_rgb() {
  # Usage: ansi_rgb R G B "text"
  printf "\033[38;2;%d;%d;%dm%s\033[0m" "$1" "$2" "$3" "$4"
}

# Palette
GREEN_R=151;  GREEN_G=201;  GREEN_B=195   # #97C9C3
YELLOW_R=229; YELLOW_G=192; YELLOW_B=123  # #E5C07B
RED_R=224;    RED_G=108;    RED_B=117     # #E06C75
GRAY_R=123;   GRAY_G=143;   GRAY_B=150    # #7B8F96

color_for_pct() {
  local pct="$1"
  if   (( pct < 50 )); then echo "$GREEN_R $GREEN_G $GREEN_B"
  elif (( pct < 80 )); then echo "$YELLOW_R $YELLOW_G $YELLOW_B"
  else                      echo "$RED_R $RED_G $RED_B"
  fi
}

colored_pct() {
  local pct="$1"
  read -r r g b <<< "$(color_for_pct "$pct")"
  ansi_rgb "$r" "$g" "$b" "${pct}%"
}

SEP="$(ansi_rgb $GRAY_R $GRAY_G $GRAY_B " │ ")"

# --------------------------------------------------------------------------
# Read stdin JSON
# --------------------------------------------------------------------------
INPUT="$(cat)"

model_display="$(echo "$INPUT" | jq -r '.model.display_name // "Unknown"')"
context_pct_raw="$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0')"
context_pct="$(printf '%.0f' "$context_pct_raw")"
context_size="$(echo "$INPUT" | jq -r '.context_window.context_window_size // 0')"
cwd="$(echo "$INPUT" | jq -r '.workspace.current_dir // .cwd // ""')"

# cost
total_cost="$(echo "$INPUT" | jq -r '.cost.total_cost_usd // 0')"

format_tokens() {
  local n="$1"
  if (( n >= 1000 )); then
    awk "BEGIN{printf \"%.0fk\", ${n}/1000}"
  else
    echo "$n"
  fi
}

# --------------------------------------------------------------------------
# Line 1: Model name
# --------------------------------------------------------------------------
LINE1="$(ansi_rgb $GREEN_R $GREEN_G $GREEN_B "🤖 ${model_display}")"

# --------------------------------------------------------------------------
# Line 2: context usage + cost
# --------------------------------------------------------------------------
context_used=$(( context_size * context_pct / 100 ))
ctx_display="$(ansi_rgb $GRAY_R $GRAY_G $GRAY_B "📊 ")$(colored_pct "$context_pct")$(ansi_rgb $GRAY_R $GRAY_G $GRAY_B " $(format_tokens $context_used)/$(format_tokens $context_size)")"
cost_str="$(printf '$%.2f' "$total_cost")"
cost_display="$(ansi_rgb $GREEN_R $GREEN_G $GREEN_B "💰 ${cost_str}")"

LINE2="${ctx_display}${SEP}${cost_display}"

# --------------------------------------------------------------------------
# Line 3: diff stats + VCS info (jj or git)
# --------------------------------------------------------------------------
added=0; deleted=0
vcs_info="?"
is_jj=0

if [[ -n "$cwd" ]] && cd "$cwd" 2>/dev/null; then
  # Detect jj repo
  if [[ -d ".jj" ]] || jj root >/dev/null 2>&1; then
    is_jj=1

    # diff stats from jj
    jj_diff="$(jj diff --stat --no-pager 2>/dev/null | tail -1 || true)"
    if [[ -n "$jj_diff" && "$jj_diff" == *"changed"* ]]; then
      added="$(echo "$jj_diff" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)"
      deleted="$(echo "$jj_diff" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)"
    fi

    # change ID (shortest)
    change_id="$(jj log -r @ --no-graph -T 'change_id.shortest()' --no-pager 2>/dev/null || echo "?")"

    # bookmarks on current change
    bookmarks="$(jj log -r @ --no-graph -T 'bookmarks' --no-pager 2>/dev/null || true)"

    # working copy status: empty or modified
    wc_empty="$(jj log -r @ --no-graph -T 'if(empty, "empty", "modified")' --no-pager 2>/dev/null || echo "?")"

    # Build vcs_info: "jj <change_id> <bookmark> (<status>)"
    vcs_info="jj ${change_id}"
    if [[ -n "$bookmarks" ]]; then
      vcs_info+=" ${bookmarks}"
    fi
    vcs_info+=" (${wc_empty})"
  else
    # Fall back to git
    branch="$(git -c core.hooksPath=/dev/null rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")"
    diff_stat="$(git -c core.hooksPath=/dev/null diff --shortstat HEAD 2>/dev/null || true)"
    if [[ -n "$diff_stat" ]]; then
      added="$(echo "$diff_stat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)"
      deleted="$(echo "$diff_stat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)"
    fi
    vcs_info="🔀 ${branch}"
  fi
fi

[[ -z "$added" ]]   && added=0
[[ -z "$deleted" ]] && deleted=0

diff_colored="$(ansi_rgb $GREEN_R $GREEN_G $GREEN_B "✏️ +${added}/-${deleted}")"
vcs_colored="$(ansi_rgb $GREEN_R $GREEN_G $GREEN_B "$vcs_info")"
LINE3="${diff_colored}${SEP}${vcs_colored}"

# --------------------------------------------------------------------------
# Output
# --------------------------------------------------------------------------
printf "%s\n%s\n%s\n" "$LINE1" "$LINE2" "$LINE3"
