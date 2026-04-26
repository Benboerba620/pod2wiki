[中文](#中文) | [English](#english)

[![Latest Release](https://img.shields.io/github/v/release/Benboerba620/pod2wiki?display_name=tag)](https://github.com/Benboerba620/pod2wiki/releases/latest)
[![Podcast Lint](https://github.com/Benboerba620/pod2wiki/actions/workflows/podcast-lint.yml/badge.svg)](https://github.com/Benboerba620/pod2wiki/actions/workflows/podcast-lint.yml)

> **"零代码 AI 投研四件套" 之一** | Part of the zero-code AI investment research toolkit
> 知识库底座 [karpathy-claude-wiki](https://github.com/Benboerba620/karpathy-claude-wiki) · 每日盯盘 [daily-watchlist](https://github.com/Benboerba620/daily-watchlist) · 假设追踪 [hypothesis-tracker](https://github.com/Benboerba620/hypothesis-tracker) · 播客/长文输入端 pod2wiki

# 中文

pod2wiki 把高质量播客和长文 RSS 自动转成 `karpathy-claude-wiki` 兼容的 `source-summary` 页面。它是 wiki 的信息输入端：订阅源负责发现材料，脚本负责转录/摘要/写入，wiki 负责长期沉淀。

**默认开箱**：AI 投研主题 + 10 个精选高质量来源（Dwarkesh / Lex Fridman / Latent Space / Karpathy / Dylan Patel / Leopold / Doug O'Laughlin / Sam Altman / Jensen Huang / SemiAnalysis）。后续按需自己加频道、博主、假设。

## 数据流

```text
RSS / YouTube / blog feeds
        |
        v
fetch_podcasts.py
        |
        +--> wiki/raw/podcasts/    原始转录
        +--> wiki/sources/         source-summary 摘要
        +--> wiki/translations/    可选全文翻译（--translate-full）
                ↓
        karpathy-claude-wiki 自动消费
```

## 安装：把这句话给 AI agent

复制下面这句话给 Claude Code、Codex、Cursor 或任何能读写文件的 AI agent：

> 帮我按这个协议安装 pod2wiki：https://github.com/Benboerba620/pod2wiki/blob/main/INSTALL-FOR-AI.md

Agent 会问你两个问题（wiki 路径、用哪家 LLM），然后自动跑一次 dry-run 验证，给你装好 slash command 和 skill。

## 用：一个 slash command 搞定

装完后在 Claude Code 里输入：

```
/pod2wiki
```

或者自然语言：「刷一下播客」「scan podcasts」「追踪一下本周 AI 播客」。

Claude 会自动：
1. 读 skill → 跑 fetch pipeline
2. 写摘要到 `wiki/sources/`、原始转录到 `wiki/raw/podcasts/`
3. 如果加 `--translate-full`，写全文翻译到 `wiki/translations/`
4. 报告这次发现了什么、有几条反转叙事红灯需要你人工核查

## 不包含什么

- 没有 GUI
- 没有内置股票观点
- 没有付费数据源绑定
- 不保证 YouTube 在所有网络环境都可用（有代理设 `PODCAST_PROXY` 环境变量；无代理时 RSS 部分仍可用）

# English

pod2wiki turns high-signal podcasts and long-form RSS feeds into `source-summary` pages compatible with `karpathy-claude-wiki`. It is the ingestion layer for a markdown-first research wiki.

**Default starter pack**: AI investing theme + 10 curated high-signal sources (Dwarkesh, Lex Fridman, Latent Space, Karpathy, Dylan Patel, Leopold, Doug O'Laughlin, Sam Altman, Jensen Huang, SemiAnalysis). Add your own channels / blogs / hypotheses as you go.

## Install: hand this to an AI agent

```
Install pod2wiki for me using this protocol: https://github.com/Benboerba620/pod2wiki/blob/main/INSTALL-FOR-AI.md
```

The agent asks two questions (wiki path, LLM provider), runs a dry-run to verify, and wires up the slash command and skill.

## Use: one slash command

In Claude Code:

```
/pod2wiki
```

Or natural language: "scan podcasts", "track AI podcasts this week".

Claude reads the skill, runs the pipeline, writes summaries to `wiki/sources/`, raw transcripts to `wiki/raw/podcasts/`, optional full translations to `wiki/translations/`, and surfaces any reversal-narrative warnings that need manual transcript verification.

## License

MIT.
