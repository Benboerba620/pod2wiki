# Contributing

## Basic Rules

- Keep each PR small and easy to review.
- Preserve the zero-code / AI-agent install path; do not require users to become Python package maintainers.
- Do not commit real transcripts, generated output, `.env` files, API keys, or private wiki content.
- Before publishing or opening a PR, run:

```bash
python scripts/preflight_public_repo.py
python -m unittest discover -s tests -p "test_*.py" -v
python scripts/fetch_podcasts.py --config examples/config.ai-investing.yaml --days 1 --dry-run
```

CI runs the same public-repo preflight and smoke checks.
