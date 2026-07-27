# codex-network-mode

## 中文说明

这个工具适用于 macOS。若你无法直接连接 Codex、ChatGPT 或其他 OpenAI 服务，或者需要在代理与直连之间切换排障，可以使用它。

在另一台 Mac 上安装：

```bash
chmod +x ./install-codex-network-mode.sh
./install-codex-network-mode.sh
```

第一次启用 `proxy` 模式时，工具会提示你填写本机代理地址和各端口，而不是假定固定值。

可选：非交互安装：

```bash
HTTP_PROXY_URL=http://127.0.0.1:7890 \
HTTPS_PROXY_URL=http://127.0.0.1:7890 \
ALL_PROXY_URL=socks5://127.0.0.1:7891 \
./install-codex-network-mode.sh
```

安装后的用法：

```bash
~/.local/bin/codex-network-mode
~/.local/bin/codex-network-mode proxy
~/.local/bin/codex-network-mode direct
~/.local/bin/codex-network-mode status
~/.local/bin/codex-network-mode config
```

注意：

- 仅适用于 macOS，因为使用了 `launchctl setenv`。
- 会写入 `~/.config/codex/` 和 `~/.local/bin/`。
- 切换模式后，建议完整重启 Codex。

---

## English

Use this on a Mac when Codex, ChatGPT, or other OpenAI services are not reachable directly, or when you need to switch between proxy and direct networking during troubleshooting.

Install on another Mac:

```bash
chmod +x ./install-codex-network-mode.sh
./install-codex-network-mode.sh
```

The first time `proxy` mode is enabled, the tool will ask for the local proxy host and ports instead of assuming fixed values.

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
- After switching modes, fully restart Codex.
