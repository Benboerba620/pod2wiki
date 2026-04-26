# INSTALL-FOR-AI.md

This file is for AI agents installing pod2wiki for a non-technical user.
Default flow: AI agent does everything via the one-click installer. The user only answers two questions and pastes one API key.

## Phase 1. Check Environment

```bash
python --version
git --version
```

Both required. If missing, tell the user to install Python 3.11+ and git.

## Phase 2. Clone The Repo

```bash
git clone https://github.com/Benboerba620/pod2wiki.git
cd pod2wiki
```

Do not create commits or push.

## Phase 3. Ask Two Questions

Ask one at a time:

1. **Where should pod2wiki output go?**
   - If the user already has a `karpathy-claude-wiki` repo: ask for the path to its `wiki/sources` folder.
   - If not: tell them you will create a fresh `wiki/sources/` next to the install (they can move it later).
2. **Which LLM provider do you want to use?**
   - Default: `deepseek` (cheapest, best EN→ZH summarization quality).
   - Other options: `kimi`, `glm` (free tier), `qwen`, `openai`.
   - Once they pick, ask for the API key.

## Phase 4. Run The Installer

Pick the script for the user's OS.

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/install.ps1 -TargetDir <workspace-path> -WikiSourcesPath <wiki-sources-path-or-omit>
```

**macOS/Linux:**
```bash
bash scripts/install.sh --target-dir <workspace-path> --wiki-sources-path <wiki-sources-path-or-omit>
```

`--wiki-sources-path` is optional. Omit it to let the installer create `<workspace>/wiki/sources` from scratch.

The installer:
- copies pod2wiki to `<workspace>/tools/pod2wiki/`
- writes `<workspace>/config/pod2wiki.config.yaml` (defaults to the AI investing 10-source starter pack)
- writes `<workspace>/config/pod2wiki.env`
- writes `<workspace>/.claude/commands/pod2wiki.md` (the `/pod2wiki` slash command)
- writes `<workspace>/.claude/skills/pod2wiki/SKILL.md`
- runs `pip install -r requirements.txt`
- runs a dry-run smoke test

## Phase 5. Fill In The LLM Key

Open `<workspace>/config/pod2wiki.env` and uncomment the `LLM_API_KEY=...` line for the provider the user picked. Replace the placeholder value with the key from Phase 3.

Default DeepSeek example:

```text
LLM_PROVIDER=deepseek
LLM_API_KEY=<paste-user-key-here>
LLM_BASE_URL=https://api.deepseek.com/v1
LLM_MODEL=deepseek-chat
```

Do not leave placeholder values such as `sk-xxx`, `xxx.xxx`, or `your_deepseek_api_key_here`. pod2wiki ignores these placeholders and will treat them as missing keys.

Full transcript translations written by `--translate-full` go to `<wiki-root>/translations/` and `<workspace>/output/pod2wiki/translations/`.

## Phase 6. Confirm

Tell the user:

- pod2wiki is installed at `<workspace>/tools/pod2wiki/`
- they can now type `/pod2wiki` in Claude Code, or say "scan podcasts" / "刷一下播客"
- the default config tracks 10 high-signal AI sources; they can edit `config/pod2wiki.config.yaml` to add more channels, blogs, hypotheses, or change the theme

That's it. Do not run a real scan unless the user asks — first runs cost LLM tokens.
