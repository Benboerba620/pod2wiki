---
name: pod2wiki
description: Scan high-signal podcasts and long-form RSS feeds, summarize them, and write karpathy-claude-wiki compatible source-summary pages.
---

# pod2wiki Skill

Use this skill when the user says "scan podcasts", "刷播客", "刷一下播客", "podcast tracking", "播客追踪", "track podcasts this week", or asks to feed podcasts/blog RSS into a karpathy-style wiki.

## How pod2wiki is laid out after install

The one-click installer puts everything under the user's workspace:

```
<workspace>/
├── tools/pod2wiki/scripts/fetch_podcasts.py
├── config/pod2wiki.config.yaml      # the one the user actually edits
├── config/pod2wiki.env              # contains LLM_API_KEY
├── output/pod2wiki/                 # default local output if no wiki path
└── wiki/sources/                    # if user supplied a wiki, this points there
```

If the user invokes `/pod2wiki`, the slash command already has the right paths baked in — just run it.

## Steps for the natural-language path (no slash command)

1. Find `config/pod2wiki.config.yaml`. If missing, the user hasn't installed yet — point them at INSTALL-FOR-AI.md.
2. Run a dry-run first to confirm config parses:

```bash
python tools/pod2wiki/scripts/fetch_podcasts.py --config config/pod2wiki.config.yaml --env-file config/pod2wiki.env --days 1 --dry-run
```

3. Run the real scan with `--wiki-out` if the user has a wiki:

```bash
python tools/pod2wiki/scripts/fetch_podcasts.py \
  --config config/pod2wiki.config.yaml \
  --env-file config/pod2wiki.env \
  --output-dir output/pod2wiki \
  --wiki-out wiki/sources \
  --days 7 \
  --write-insight-log
```

4. Parse stdout JSON and report to the user:

- `items_found`
- `source_pages_written`
- `raw_pages_written`
- `insight_log`
- `verification_warnings`

## Reversal Narrative Verification Rule

If `verification_warnings` is non-empty, do **not** reuse the flagged bullets in downstream research until the user has checked the raw transcript. These warnings catch LLM-added "X rather than Y" framings that often hallucinate the reversal.
