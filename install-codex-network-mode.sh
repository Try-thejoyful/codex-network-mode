#!/bin/zsh
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
CODEX_DIR="$HOME/.config/codex"
SCRIPT_PATH="$BIN_DIR/codex-network-mode"
ACTIVE_ENV="$CODEX_DIR/active-env.sh"
PROXY_ENV="$CODEX_DIR/proxy-env.sh"
DIRECT_ENV="$CODEX_DIR/direct-env.sh"

HTTP_PROXY_URL="${HTTP_PROXY_URL:-http://127.0.0.1:1087}"
HTTPS_PROXY_URL="${HTTPS_PROXY_URL:-$HTTP_PROXY_URL}"
ALL_PROXY_URL="${ALL_PROXY_URL:-socks5://127.0.0.1:1080}"
NO_PROXY_VALUE="${NO_PROXY_VALUE:-localhost,127.0.0.1,::1}"
DEFAULT_MODE="${DEFAULT_MODE:-proxy}"

mkdir -p "$BIN_DIR" "$CODEX_DIR"

cat > "$SCRIPT_PATH" <<'EOF'
#!/bin/zsh
set -euo pipefail

CODEX_DIR="$HOME/.config/codex"
ACTIVE_ENV="$CODEX_DIR/active-env.sh"
PROXY_ENV="$CODEX_DIR/proxy-env.sh"
DIRECT_ENV="$CODEX_DIR/direct-env.sh"

set_launchctl_proxy() {
  source "$PROXY_ENV"
  launchctl setenv HTTP_PROXY "$HTTP_PROXY"
  launchctl setenv HTTPS_PROXY "$HTTPS_PROXY"
  launchctl setenv ALL_PROXY "$ALL_PROXY"
  launchctl setenv NO_PROXY "$NO_PROXY"
  launchctl setenv http_proxy "$http_proxy"
  launchctl setenv https_proxy "$https_proxy"
  launchctl setenv all_proxy "$all_proxy"
  launchctl setenv no_proxy "$no_proxy"
}

unset_launchctl_proxy() {
  for key in HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY http_proxy https_proxy all_proxy no_proxy; do
    launchctl unsetenv "$key" || true
  done
}

set_mode_proxy() {
  cat > "$ACTIVE_ENV" <<'INNER'
source "$HOME/.config/codex/proxy-env.sh"
INNER
  set_launchctl_proxy
  echo "Codex network mode: proxy"
}

set_mode_direct() {
  cat > "$ACTIVE_ENV" <<'INNER'
source "$HOME/.config/codex/direct-env.sh"
INNER
  unset_launchctl_proxy
  echo "Codex network mode: direct"
}

show_status() {
  local mode="unknown"
  if command -v rg >/dev/null 2>&1; then
    if rg -q 'proxy-env\.sh' "$ACTIVE_ENV" 2>/dev/null; then
      mode="proxy"
    elif rg -q 'direct-env\.sh' "$ACTIVE_ENV" 2>/dev/null; then
      mode="direct"
    fi
  else
    if grep -q 'proxy-env\.sh' "$ACTIVE_ENV" 2>/dev/null; then
      mode="proxy"
    elif grep -q 'direct-env\.sh' "$ACTIVE_ENV" 2>/dev/null; then
      mode="direct"
    fi
  fi

  echo "Current mode: $mode"
  echo "launchctl HTTP_PROXY: $(launchctl getenv HTTP_PROXY || true)"
  echo "launchctl HTTPS_PROXY: $(launchctl getenv HTTPS_PROXY || true)"
  echo "launchctl ALL_PROXY: $(launchctl getenv ALL_PROXY || true)"
}

interactive_menu() {
  echo "Choose Codex network mode:"
  echo "1. Explicit proxy"
  echo "2. Direct"
  echo "3. Status"
  printf "> "
  read -r choice
  case "$choice" in
    1) set_mode_proxy ;;
    2) set_mode_direct ;;
    3) show_status ;;
    *) echo "Invalid choice: $choice" >&2; exit 1 ;;
  esac
}

case "${1:-}" in
  proxy) set_mode_proxy ;;
  direct) set_mode_direct ;;
  status) show_status ;;
  "") interactive_menu ;;
  *)
    echo "Usage: codex-network-mode [proxy|direct|status]" >&2
    exit 1
    ;;
esac
EOF

chmod +x "$SCRIPT_PATH"

cat > "$PROXY_ENV" <<EOF
export HTTP_PROXY="$HTTP_PROXY_URL"
export HTTPS_PROXY="$HTTPS_PROXY_URL"
export ALL_PROXY="$ALL_PROXY_URL"
export NO_PROXY="$NO_PROXY_VALUE"

export http_proxy="\$HTTP_PROXY"
export https_proxy="\$HTTPS_PROXY"
export all_proxy="\$ALL_PROXY"
export no_proxy="\$NO_PROXY"
EOF

cat > "$DIRECT_ENV" <<'EOF'
unset HTTP_PROXY
unset HTTPS_PROXY
unset ALL_PROXY
unset NO_PROXY

unset http_proxy
unset https_proxy
unset all_proxy
unset no_proxy
EOF

case "$DEFAULT_MODE" in
  proxy)
    cat > "$ACTIVE_ENV" <<'EOF'
source "$HOME/.config/codex/proxy-env.sh"
EOF
    "$SCRIPT_PATH" proxy >/dev/null
    ;;
  direct)
    cat > "$ACTIVE_ENV" <<'EOF'
source "$HOME/.config/codex/direct-env.sh"
EOF
    "$SCRIPT_PATH" direct >/dev/null
    ;;
  *)
    echo "Unsupported DEFAULT_MODE: $DEFAULT_MODE" >&2
    exit 1
    ;;
esac

echo "Installed codex-network-mode to $SCRIPT_PATH"
echo "Current mode: $DEFAULT_MODE"
echo "Run: $SCRIPT_PATH status"
