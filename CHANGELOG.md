# Changelog

## Unreleased

- No unreleased changes.

## v0.1.0 - 2026-04-26

Initial public draft for pod2wiki, extracted from a private podcast tracking workflow.

### Features

- Config-driven podcast and blog RSS ingestion
- YouTube discovery modes: channel scan, search queries, explicit URLs
- YouTube transcript extraction via `youtube-transcript-api` with `yt-dlp` subtitle fallback
- Local Markdown/text input via `--input-file`
- No-LLM extractive fallback via `--no-llm`
- OpenAI-compatible LLM summarization via DeepSeek, Kimi, GLM, Qwen, or OpenAI
- Full-text translation option via `--translate-full`
- Run-level insight log append via `--write-insight-log`
- `--wiki-out` direct integration with karpathy-claude-wiki `wiki/sources/`
- Raw text archive under `raw/podcasts/`
- Reversal-narrative red-flag detection
- 30-day-style seen-history file for deduplication
- AI investing example config
- Minimal GitHub Actions lint workflow

### Notes

- YouTube availability depends on the user's network and YouTube rate limits. RSS and local transcript input remain the most stable paths.
- Runtime warnings now remind users to keep YouTube runs small and use RSS or local transcripts for large backfills.
- MP3 transcription is optional through `scripts/podcast_rss_transcribe.py` and `faster-whisper`.

### Fixed

- Ignore placeholder API key values such as `sk-xxx`, so provider-specific keys like `DEEPSEEK_API_KEY` still work in existing installs.
- Document full-text translation output under `translations/` consistently.
