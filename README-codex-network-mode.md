# codex-network-mode

Use this on a Mac when Codex, ChatGPT, or other OpenAI services are not reachable directly, or when you need to switch between proxy and direct networking during troubleshooting.

Install on another Mac:

```bash
chmod +x ./install-codex-network-mode.sh
./install-codex-network-mode.sh
```

The first time proxy mode is enabled, the tool will ask for the local proxy host and ports instead of assuming fixed values.

Optional non-interactive install:

```bash
HTTP_PROXY_URL=http://127.0.0.1:7890 \
HTTPS_PROXY_URL=http://127.0.0.1:7890 \
ALL_PROXY_URL=socks5://127.0.0.1:7891 \
./install-codex-network-mode.sh
```

Usage after install:

```bash
~/.local/bin/codex-network-mode
~/.local/bin/codex-network-mode proxy
~/.local/bin/codex-network-mode direct
~/.local/bin/codex-network-mode status
~/.local/bin/codex-network-mode config
```

Notes:

- This is for macOS only because it uses `launchctl setenv`.
- It writes files under `~/.config/codex/` and `~/.local/bin/`.
- After switching modes, fully restart Codex for the change to take effect reliably.
