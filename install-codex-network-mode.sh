#!/bin/zsh
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
CODEX_DIR="$HOME/.config/codex"
SCRIPT_PATH="$BIN_DIR/codex-network-mode"
ACTIVE_ENV="$CODEX_DIR/active-env.sh"
PROXY_ENV="$CODEX_DIR/proxy-env.sh"
DIRECT_ENV="$CODEX_DIR/direct-env.sh"

HTTP_PROXY_URL="${HTTP_PROXY_URL:-}"
HTTPS_PROXY_URL="${HTTPS_PROXY_URL:-}"
ALL_PROXY_URL="${ALL_PROXY_URL:-}"
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

prompt_with_default() {
  local prompt="$1"
  local default_value="${2:-}"
  local value=""
  if [[ -n "$default_value" ]]; then
    printf "%s [%s]: " "$prompt" "$default_value" >&2
  else
    printf "%s: " "$prompt" >&2
  fi
  read -r value
  if [[ -z "$value" ]]; then
    value="$default_value"
  fi
  printf '%s' "$value"
}

validate_port() {
  local port="$1"
  [[ "$port" =~ '^[0-9]+$' ]] || return 1
  (( port >= 1 && port <= 65535 ))
}

write_proxy_env() {
  local host="$1"
  local http_port="$2"
  local https_port="$3"
  local socks_port="$4"
  local no_proxy_value="$5"

  cat > "$PROXY_ENV" <<INNER
export HTTP_PROXY="http://$host:$http_port"
export HTTPS_PROXY="http://$host:$https_port"
export ALL_PROXY="socks5://$host:$socks_port"
export NO_PROXY="$no_proxy_value"

export http_proxy="\$HTTP_PROXY"
export https_proxy="\$HTTPS_PROXY"
export all_proxy="\$ALL_PROXY"
export no_proxy="\$NO_PROXY"
INNER
}

configure_proxy() {
  local host=""
  local http_port=""
  local https_port=""
  local socks_port=""
  local no_proxy_value=""
  local same_https=""

  echo "Configure explicit proxy for Codex"
  host="$(prompt_with_default 'Proxy host or IP' '127.0.0.1')"

  while true; do
    http_port="$(prompt_with_default 'HTTP proxy port' '7890')"
    if validate_port "$http_port"; then
      break
    fi
    echo "Invalid port: $http_port" >&2
  done

  same_https="$(prompt_with_default 'Use the same HTTPS proxy port as HTTP? (Y/n)' 'Y')"
  case "${same_https:l}" in
    ""|y|yes)
      https_port="$http_port"
      ;;
    n|no)
      while true; do
        https_port="$(prompt_with_default 'HTTPS proxy port' "$http_port")"
        if validate_port "$https_port"; then
          break
        fi
        echo "Invalid port: $https_port" >&2
      done
      ;;
    *)
      echo "Invalid choice: $same_https" >&2
      return 1
      ;;
  esac

  while true; do
    socks_port="$(prompt_with_default 'SOCKS5 proxy port' '7891')"
    if validate_port "$socks_port"; then
      break
    fi
    echo "Invalid port: $socks_port" >&2
  done

  no_proxy_value="$(prompt_with_default 'NO_PROXY value' 'localhost,127.0.0.1,::1')"
  write_proxy_env "$host" "$http_port" "$https_port" "$socks_port" "$no_proxy_value"
  echo "Saved proxy settings to $PROXY_ENV"
}

ensure_proxy_config() {
  if [[ ! -f "$PROXY_ENV" ]]; then
    configure_proxy
  fi
}

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
  ensure_proxy_config
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
  if [[ -f "$PROXY_ENV" ]]; then
    echo "Proxy config file: $PROXY_ENV"
  else
    echo "Proxy config file: not configured yet"
  fi
}

interactive_menu() {
  echo "Choose Codex network mode:"
  echo "1. Explicit proxy"
  echo "2. Direct"
  echo "3. Status"
  echo "4. Configure proxy"
  printf "> "
  read -r choice
  case "$choice" in
    1) set_mode_proxy ;;
    2) set_mode_direct ;;
    3) show_status ;;
    4) configure_proxy ;;
    *) echo "Invalid choice: $choice" >&2; exit 1 ;;
  esac
}

case "${1:-}" in
  proxy) set_mode_proxy ;;
  direct) set_mode_direct ;;
  status) show_status ;;
  config) configure_proxy ;;
  "") interactive_menu ;;
  *)
    echo "Usage: codex-network-mode [proxy|direct|status|config]" >&2
    exit 1
    ;;
esac
EOF

chmod +x "$SCRIPT_PATH"

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

if [[ -n "$HTTP_PROXY_URL" && -n "$HTTPS_PROXY_URL" && -n "$ALL_PROXY_URL" ]]; then
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
fi

case "$DEFAULT_MODE" in
  proxy)
    "$SCRIPT_PATH" proxy >/dev/null
    ;;
  direct)
    "$SCRIPT_PATH" direct >/dev/null
    ;;
  *)
    echo "Unsupported DEFAULT_MODE: $DEFAULT_MODE" >&2
    exit 1
    ;;
esac

echo "Installed codex-network-mode to $SCRIPT_PATH"
if [[ -f "$PROXY_ENV" ]]; then
  echo "Proxy configuration file: $PROXY_ENV"
else
  echo "Proxy configuration file will be created on first proxy setup."
fi
echo "Current mode: $DEFAULT_MODE"
echo "Run: $SCRIPT_PATH status"
