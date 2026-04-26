[中文](#中文) | [English](#english)

[![Latest Release](https://img.shields.io/github/v/release/Benboerba620/pod2wiki?display_name=tag)](https://github.com/Benboerba620/pod2wiki/releases/latest)
[![Podcast Lint](https://github.com/Benboerba620/pod2wiki/actions/workflows/podcast-lint.yml/badge.svg)](https://github.com/Benboerba620/pod2wiki/actions/workflows/podcast-lint.yml)

> **"零代码 AI 投研四件套" 之一** | Part of the zero-code AI investment research toolkit
> 知识库底座 [karpathy-claude-wiki](https://github.com/Benboerba620/karpathy-claude-wiki) · 每日盯盘 [daily-watchlist](https://github.com/Benboerba620/daily-watchlist) · 假设追踪 [hypothesis-tracker](https://github.com/Benboerba620/hypothesis-tracker) · 播客/长文输入端 pod2wiki

---

# 中文

pod2wiki 把高质量播客和长文 RSS 自动转成 `karpathy-claude-wiki` 兼容的 `source-summary` 页面。它是 wiki 的信息输入端：订阅源负责发现材料，脚本负责转录/摘要/写入，wiki 负责长期沉淀。

**默认开箱**：AI 投研主题 + 10 个精选高质量来源（Dwarkesh / Lex Fridman / Latent Space / Karpathy / Dylan Patel / Leopold / Doug O'Laughlin / Sam Altman / Jensen Huang / SemiAnalysis）。后续按需自己加频道、博主、假设。

## 推荐：让 AI agent 帮你装

复制下面这句话给 Claude Code、Codex、Cursor 或任何能读写文件的 AI agent：

> 帮我按这个协议安装 pod2wiki：https://github.com/Benboerba620/pod2wiki/blob/main/INSTALL-FOR-AI.md

Agent 会问你两个问题（wiki 路径、用哪家 LLM），然后自动跑一次 dry-run 验证，给你装好 slash command 和 skill。装完后在 Claude Code 里输入 `/pod2wiki` 或者「刷一下播客」就能跑。

## 装完了，怎么改成"我自己的"关注领域？

打开 `config/pod2wiki.config.yaml`，3 个地方决定你看到什么：

### 1. 关注领域 — `theme` + `hypotheses`

`theme` 只是个标签（影响 insight log 文件名）。真正决定"AI 帮你筛什么"的是 `hypotheses` 关键词列表——脚本会用它给摘要做主题归属。

默认是 AI 投资。要换成能源投资就改成：

```yaml
theme: energy-investing

hypotheses:
  H1:
    title: 数据中心电力瓶颈
    keywords: [data center power, grid, transformer, 变压器, 电网]
  H2:
    title: 核电复兴
    keywords: [nuclear, SMR, 核电, uranium, 铀]
  H3:
    title: 天然气作为 AI 过渡能源
    keywords: [natural gas, LNG, gas turbine, peaker]
```

### 2. 核心人物 — `people_searches` / `exec_searches`

这两个字段就是 YouTube 搜索词。脚本拿每条字符串去搜 YouTube，抓最近 N 天的视频。`people_searches` 给研究员/分析师用，`exec_searches` 给 CEO/创始人用——区分只是为了你自己查 config 时一眼看清。

```yaml
people_searches:
  - "Doug O'Laughlin semiconductor interview"
  - "Dylan Patel SemiAnalysis interview"
  - "Leopold Aschenbrenner AI interview"

exec_searches:
  - "Jensen Huang interview"
  - "Sam Altman interview"
```

> 想追谁就照葫芦画瓢加一行。搜索词写得越具体越好（带"interview"、"podcast"等限定词）。

### 3. 优质频道 — `channels` + `blog_feeds`

`channels` 是 YouTube 频道首页 + 可选 RSS（双轨抓取，避免单点失败）。`blog_feeds` 是纯文字博客 RSS。

```yaml
channels:
  - name: Dwarkesh Podcast
    youtube: "https://www.youtube.com/@DwarkeshPatel/videos"
    rss: "https://www.dwarkesh.com/feed"
    keywords: [AI, AGI, compute, scaling]
  - name: Latent Space
    youtube: "https://www.youtube.com/@LatentSpaceTV/videos"
    rss: "https://api.substack.com/feed/podcast/1084089.rss"
    keywords: [LLM, agents, AI engineering]

blog_feeds:
  - name: SemiAnalysis
    url: "https://www.semianalysis.com/feed"
    author: Dylan Patel
```

**怎么挖优质频道？** 两个起点：
- 你已经在听的播客 → 找它的 RSS（多数 Substack/Apple Podcasts/Spotify 的页面底部都有）
- 你常读的研究员/博主 → 翻他的 X / 个人博客，找 RSS 链接（一般在 `/feed`、`/rss` 路径）

> 不知道该追谁？看 `examples/config.ai-investing.yaml` 里默认追的 10 个 AI 信息源（Dwarkesh / Lex Fridman / Latent Space / Karpathy / Dylan Patel / Leopold / Doug O'Laughlin / Sam Altman / Jensen Huang / SemiAnalysis），照葫芦画瓢替换成你领域的对标人物即可。

改完保存，下次跑 `/pod2wiki` 就按你的新配置抓。

## 抓完之后，文件去哪了？

每次 `/pod2wiki` 跑完，会在 wiki 目录下生成两份文件：

- `wiki/sources/{date}-{channel}-{slug}.md` — 中文摘要 + 关键数据 + 引文（喂给 karpathy-claude-wiki 当知识页用）
- `wiki/raw/podcasts/{date}-{channel}-{slug}.md` — **完整英文原文**（Whisper 转录或 RSS 全文）

可选：加 `--translate-full` 还会写 `wiki/translations/` 下的全文中译。

> 🔑 **raw 永远保留**——意味着如果你后续想要全文中译（不只是摘要），不需要重新抓 mp3、不需要重新跑 Whisper、不需要再消耗一次网络流量，**直接拿 raw 文件喂任何 LLM 翻译就行**：
>
> ```bash
> # 示例：把某一集英文 raw 喂给本地 LLM 二次翻译
> cat wiki/raw/podcasts/2026-04-26-dwarkesh-leopold-aschenbrenner.md \
>   | your-llm-cli --prompt "翻译成中文，保留所有数字和公司名"
> ```

## 完整数据流

```text
订阅源 (channels.youtube / channels.rss / blog_feeds / people_searches / exec_searches)
   |
   v  抓最近 N 天（days_lookback，默认 7 天）
mp3 / 视频字幕 / RSS 全文
   |
   v  Whisper transcribe（mp3）或 直接拿（字幕 / RSS 全文）
英文全文  ----->  wiki/raw/podcasts/        (永久归档，二次复用)
   |
   v  DeepSeek (or Kimi/GLM/Qwen/OpenAI) 摘要 + 翻译
中文 source-summary  ----->  wiki/sources/  (karpathy-claude-wiki 兼容)
   |
   v  insight log 汇总
output/pod2wiki/{theme}-insights-log.md     (本次扫描的主线整理)
```

LLM 提供商在 `config/pod2wiki.env` 里切（DeepSeek / Kimi / GLM / Qwen / OpenAI 任选其一，OpenAI 兼容协议）。

## 不包含什么

- 没有 GUI
- 没有内置股票观点
- 没有付费数据源绑定
- 不保证 YouTube 在所有网络环境都可用（有代理设 `PODCAST_PROXY` 环境变量；无代理时 RSS 部分仍可用）

## License

MIT.

---

# English

pod2wiki turns high-signal podcasts and long-form RSS feeds into `source-summary` pages compatible with `karpathy-claude-wiki`. It is the ingestion layer for a markdown-first research wiki.

**Default starter pack**: AI investing theme + 10 curated high-signal sources (Dwarkesh, Lex Fridman, Latent Space, Karpathy, Dylan Patel, Leopold, Doug O'Laughlin, Sam Altman, Jensen Huang, SemiAnalysis). Add your own channels / blogs / hypotheses as you go.

## Recommended: have an AI agent install it

Paste this to Claude Code, Codex, Cursor, or any agent that can read/write files:

> Install pod2wiki for me using this protocol: https://github.com/Benboerba620/pod2wiki/blob/main/INSTALL-FOR-AI.md

The agent asks two questions (wiki path, LLM provider), runs a dry-run to verify, and wires up the slash command and skill. After install, type `/pod2wiki` or "scan podcasts" inside Claude Code to run it.

## How do I switch to my own topic?

Open `config/pod2wiki.config.yaml`. Three fields decide what you see:

### 1. Topic — `theme` + `hypotheses`

`theme` is just a label (affects the insight-log filename). What actually drives "what gets surfaced" is the `hypotheses` keyword list — the script uses it to bucket each summary into a thesis.

Default is AI investing. To switch to energy investing:

```yaml
theme: energy-investing

hypotheses:
  H1:
    title: Data center power bottleneck
    keywords: [data center power, grid, transformer]
  H2:
    title: Nuclear renaissance
    keywords: [nuclear, SMR, uranium]
  H3:
    title: Natural gas as AI bridge fuel
    keywords: [natural gas, LNG, gas turbine, peaker]
```

### 2. People to follow — `people_searches` / `exec_searches`

Both fields are literal YouTube search strings. The script searches each one and pulls videos from the last N days. `people_searches` is for researchers/analysts, `exec_searches` is for CEOs/founders — the split is purely for your own readability.

```yaml
people_searches:
  - "Doug O'Laughlin semiconductor interview"
  - "Dylan Patel SemiAnalysis interview"
  - "Leopold Aschenbrenner AI interview"

exec_searches:
  - "Jensen Huang interview"
  - "Sam Altman interview"
```

> Add a line per person you want to track. The more specific the search string ("interview", "podcast"), the better the hit rate.

### 3. Channels & blogs — `channels` + `blog_feeds`

`channels` takes a YouTube channel page plus an optional RSS (dual-track ingest, so a single source going dark doesn't drop the channel). `blog_feeds` is for text-only blogs.

```yaml
channels:
  - name: Dwarkesh Podcast
    youtube: "https://www.youtube.com/@DwarkeshPatel/videos"
    rss: "https://www.dwarkesh.com/feed"
    keywords: [AI, AGI, compute, scaling]
  - name: Latent Space
    youtube: "https://www.youtube.com/@LatentSpaceTV/videos"
    rss: "https://api.substack.com/feed/podcast/1084089.rss"
    keywords: [LLM, agents, AI engineering]

blog_feeds:
  - name: SemiAnalysis
    url: "https://www.semianalysis.com/feed"
    author: Dylan Patel
```

**How do I find good channels?** Two starting points:
- Podcasts you already listen to → look up their RSS (most Substack / Apple Podcasts / Spotify pages have it in the footer)
- Researchers/bloggers you already read → check their X profile or personal blog for an RSS link (usually at `/feed` or `/rss`)

> No idea who to follow? Look at `examples/config.ai-investing.yaml` — the 10 default AI sources (Dwarkesh, Lex Fridman, Latent Space, Karpathy, Dylan Patel, Leopold, Doug O'Laughlin, Sam Altman, Jensen Huang, SemiAnalysis). Mirror that pattern and swap in the equivalents for your domain.

Save the file. Next `/pod2wiki` run uses the new config.

## Where do my files go after a scan?

Each `/pod2wiki` run produces two files per episode under your wiki directory:

- `wiki/sources/{date}-{channel}-{slug}.md` — Chinese summary + key data + quotes (consumed by karpathy-claude-wiki as a knowledge page)
- `wiki/raw/podcasts/{date}-{channel}-{slug}.md` — **full English raw text** (Whisper transcript or RSS full text)

Optional: with `--translate-full`, you also get a full Chinese translation under `wiki/translations/`.

> 🔑 **Raw is kept forever** — meaning if you later want a different translation (not just the summary), you do **not** need to re-download mp3, re-run Whisper, or re-spend bandwidth. Just feed the raw file to any LLM:
>
> ```bash
> # Example: re-translate one episode using your local LLM
> cat wiki/raw/podcasts/2026-04-26-dwarkesh-leopold-aschenbrenner.md \
>   | your-llm-cli --prompt "Translate to Chinese, keep all numbers and company names"
> ```

## Full data flow

```text
Subscriptions (channels.youtube / channels.rss / blog_feeds / people_searches / exec_searches)
   |
   v  fetch last N days (days_lookback, default 7)
mp3 / video subtitles / RSS full text
   |
   v  Whisper transcribe (mp3) or direct (subtitles / RSS)
English full text  ----->  wiki/raw/podcasts/    (permanent archive, reusable)
   |
   v  DeepSeek (or Kimi/GLM/Qwen/OpenAI) summarize + translate
Chinese source-summary  ----->  wiki/sources/    (karpathy-claude-wiki compatible)
   |
   v  insight log roll-up
output/pod2wiki/{theme}-insights-log.md          (this scan's narrative thread)
```

LLM provider is set in `config/pod2wiki.env` (DeepSeek / Kimi / GLM / Qwen / OpenAI — any OpenAI-compatible endpoint).

## What this is not

- No GUI
- No built-in stock opinions
- No paid data source lock-in
- No guarantee YouTube works on every network (set `PODCAST_PROXY` for SOCKS5; RSS path still works without a proxy)

## License

MIT.
