# codex-network-mode

## 中文说明

`codex-network-mode` 是一个面向 macOS 的小工具，适合以下场景使用：你在本机无法稳定连接 Codex、ChatGPT 或其他 OpenAI 服务，尤其是在代理、VPN、PAC 模式、透明代理或其他翻墙环境下。

它的作用是帮助你在 `显式固定代理` 和 `直连` 两种模式之间快速切换，而不必每次手动修改 shell 配置文件。

### 适用场景

- 本地代理关闭后，Codex 无法连接。
- ChatGPT 或 OpenAI 服务在 PAC 模式下连接不稳定。
- 你已经能通过路由器级代理访问互联网，但 Codex 仍然需要显式指定本地代理。
- 你需要在强制代理和直连之间快速切换，方便排障。
- 你希望 Codex 使用的代理环境通过 `launchctl` 持续生效，并在重启后更稳定。

### 功能说明

- 为 Codex 设置显式代理环境变量。
- 第一次启用 `proxy` 模式时，提示你填写本机代理地址和不同服务端口。
- 切换到 `direct` 模式时清除这些代理环境变量。
- 将当前模式保存在 `~/.config/codex/` 下。
- 通过 macOS 的 `launchctl setenv` 应用环境变量。

### 相关本地 Skill

如果你也在维护本地 Codex skills，这台 Mac 上还有一个相关 skill：[`$prompt-contract-review`](/Users/harry/.codex/skills/prompt-contract-review/SKILL.md)。

它适用于只审阅 prompt、不执行 prompt 任务本身的场景。

```text
$prompt-contract-review
<your prompt here>
```

### 安装

```bash
chmod +x ./install-codex-network-mode.sh
./install-codex-network-mode.sh
```

第一次使用 `proxy` 模式时，工具会提示你填写：

- 代理主机地址或 IP
- HTTP 代理端口
- HTTPS 代理端口
- SOCKS5 代理端口
- `NO_PROXY` 值

如果你希望在安装时直接预置这些值，也可以使用环境变量进行非交互安装：

### 可选：非交互安装

```bash
HTTP_PROXY_URL=http://127.0.0.1:7890 \
HTTPS_PROXY_URL=http://127.0.0.1:7890 \
ALL_PROXY_URL=socks5://127.0.0.1:7891 \
./install-codex-network-mode.sh
```

### 使用方式

```bash
~/.local/bin/codex-network-mode
~/.local/bin/codex-network-mode proxy
~/.local/bin/codex-network-mode direct
~/.local/bin/codex-network-mode status
~/.local/bin/codex-network-mode config
```

其中 `config` 用于后续重新填写并覆盖已保存的代理地址和端口设置。

### 注意事项

- 仅适用于 macOS，因为它依赖 `launchctl setenv`。
- 会写入 `~/.config/codex/` 和 `~/.local/bin/`。
- 切换模式后，建议完整重启 Codex，以确保新环境变量稳定生效。

---

## English

`codex-network-mode` is a small macOS helper for users who cannot connect to Codex, ChatGPT, or other OpenAI services reliably, especially when proxy, VPN, PAC mode, transparent proxy, or other network-circumvention setups are involved.

It helps you switch between `explicit proxy` mode and `direct` mode without manually editing shell configuration files every time.

### When this is useful

- Codex cannot connect when your local proxy is off.
- ChatGPT or OpenAI access is unstable under PAC mode.
- You can already reach the internet through a router-level proxy, but Codex still needs an explicit local proxy.
- You need a quick way to switch between forced proxy mode and direct mode for troubleshooting.
- You want the proxy environment used by Codex to persist more reliably through `launchctl`.

### What it does

- Sets explicit proxy environment variables for Codex.
- Prompts for your own proxy host and per-service ports the first time you enable `proxy` mode.
- Clears those proxy environment variables when you switch to `direct` mode.
- Stores the active mode under `~/.config/codex/`.
- Applies the environment through macOS `launchctl setenv`.

### Related local skill

If you also maintain local Codex skills, a related skill on this Mac is [`$prompt-contract-review`](/Users/harry/.codex/skills/prompt-contract-review/SKILL.md).

Use it when you want to audit a prompt without executing the prompt's task.

```text
$prompt-contract-review
<your prompt here>
```

### Install

```bash
chmod +x ./install-codex-network-mode.sh
./install-codex-network-mode.sh
```

On first use of `proxy` mode, the tool will ask for:

- Proxy host or IP
- HTTP proxy port
- HTTPS proxy port
- SOCKS5 proxy port
- `NO_PROXY` value

If you want to preseed these values during installation, you can still use environment variables for a non-interactive setup:

### Optional non-interactive install

```bash
HTTP_PROXY_URL=http://127.0.0.1:7890 \
HTTPS_PROXY_URL=http://127.0.0.1:7890 \
ALL_PROXY_URL=socks5://127.0.0.1:7891 \
./install-codex-network-mode.sh
```

### Usage

```bash
~/.local/bin/codex-network-mode
~/.local/bin/codex-network-mode proxy
~/.local/bin/codex-network-mode direct
~/.local/bin/codex-network-mode status
~/.local/bin/codex-network-mode config
```

`config` lets you rewrite the saved proxy host and port settings later.

### Notes

- macOS only, because it relies on `launchctl setenv`.
- It writes files under `~/.config/codex/` and `~/.local/bin/`.
- After switching modes, fully restart Codex so the new environment variables take effect reliably.
