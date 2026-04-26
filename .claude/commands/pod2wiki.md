---
description: Scan podcast/RSS/local transcript sources and write pod2wiki source-summary pages.
argument-hint: "[--mode rss|youtube|all] [--youtube-url URL] [--youtube-query QUERY] [--input-file PATH] [--no-llm]"
---

# /pod2wiki

Use the installed pod2wiki tool to ingest podcasts, RSS/blog feeds, YouTube transcripts, or local transcript files into a karpathy-style wiki.

Default installed command shape (assumes pod2wiki cloned at `tools/pod2wiki/` of the host repo, with config/env at `config/pod2wiki.config.yaml` / `config/pod2wiki.env`):

```bash
python tools/pod2wiki/scripts/fetch_podcasts.py \
  --config config/pod2wiki.config.yaml \
  --env-file config/pod2wiki.env \
  --output-dir output/pod2wiki \
  --wiki-out wiki/sources \
  --days 7 \
  --write-insight-log \
  $ARGUMENTS
```

If pod2wiki is the host repo itself (cloned standalone), drop the `tools/pod2wiki/` prefix and point `--config` / `--env-file` at the repo root.

Before using LLM features, make sure the env file contains one provider API key. Use `--no-llm` for a no-key smoke test.

Always report:

- source pages written
- raw pages written
- translation pages written
- insight log path
- verification warnings
