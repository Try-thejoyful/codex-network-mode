# codex-network-mode

`codex-network-mode` is a small macOS helper for users who cannot connect to Codex, ChatGPT, or other OpenAI services reliably from a Mac, especially when proxy, VPN, PAC mode, or other network-circumvention setups are involved.

It helps you switch Codex between explicit proxy mode and direct mode without manually editing shell files every time.

## When this is useful

- Codex cannot connect when your local proxy is off.
- ChatGPT or OpenAI access is unstable under PAC mode.
- You can reach the internet through a router-level proxy, but Codex still needs an explicit local proxy.
- You need a quick switch between forced proxy mode and direct mode for troubleshooting.
- You want the proxy environment for Codex to survive restarts more reliably through `launchctl`.

## What it does

- Sets explicit proxy environment variables for Codex.
- Prompts for your own proxy host and ports the first time you enable proxy mode.
- Clears those variables when you want direct connection mode.
- Stores the active mode under `~/.config/codex/`.
- Applies the environment through `launchctl setenv` on macOS.

## Related local skill

If you also maintain local Codex skills, a related skill on this Mac is [`$prompt-contract-review`](/Users/harry/.codex/skills/prompt-contract-review/SKILL.md).

Use it when you want to audit a prompt without executing the prompt's task.

```text
$prompt-contract-review
<your prompt here>
```

## Install

```bash
chmod +x ./install-codex-network-mode.sh
./install-codex-network-mode.sh
```

On first use of proxy mode, the tool will ask for:

- Proxy host or IP
- HTTP proxy port
- HTTPS proxy port
- SOCKS5 proxy port
- `NO_PROXY` value

If you want to preseed these values during install, you can still do that with environment variables:

## Optional non-interactive install

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
~/.local/bin/codex-network-mode config
```

`config` lets you rewrite the saved proxy host and port settings later.

## Notes

- macOS only. It uses `launchctl setenv`.
- It writes files under `~/.config/codex/` and `~/.local/bin/`.
- After switching modes, fully restart Codex so the change takes effect reliably.
