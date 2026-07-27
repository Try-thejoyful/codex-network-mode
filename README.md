# codex-network-mode

`codex-network-mode` is a small macOS helper for switching Codex between explicit proxy mode and direct mode.

## Install

```bash
chmod +x ./install-codex-network-mode.sh
./install-codex-network-mode.sh
```

## Custom proxy ports

```bash
HTTP_PROXY_URL=http://127.0.0.1:7890 \
HTTPS_PROXY_URL=http://127.0.0.1:7890 \
ALL_PROXY_URL=socks5://127.0.0.1:7891 \
./install-codex-network-mode.sh
```

## Usage

```bash
~/.local/bin/codex-network-mode
~/.local/bin/codex-network-mode proxy
~/.local/bin/codex-network-mode direct
~/.local/bin/codex-network-mode status
```

## Notes

- macOS only. It uses `launchctl setenv`.
- It writes files under `~/.config/codex/` and `~/.local/bin/`.
- After switching modes, fully restart Codex so the change takes effect reliably.
