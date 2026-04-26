#!/usr/bin/env bash
set -euo pipefail

target_dir=""
install_dir_name="tools/pod2wiki"
wiki_sources_path=""
skip_pip=0
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-dir) target_dir="$2"; shift 2 ;;
    --install-dir-name) install_dir_name="$2"; shift 2 ;;
    --wiki-sources-path) wiki_sources_path="$2"; shift 2 ;;
    --skip-pip) skip_pip=1; shift ;;
    --force) force=1; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$target_dir" ]]; then
  echo "--target-dir is required" >&2
  exit 2
fi

source_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_root="$(python -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$target_dir")"
install_root="$target_root/$install_dir_name"

echo "[pod2wiki] Target workspace: $target_root"
echo "[pod2wiki] Tool install dir: $install_root"

if [[ -e "$install_root" ]]; then
  if [[ "$force" != "1" ]]; then
    echo "Install target already exists: $install_root. Re-run with --force." >&2
    exit 1
  fi
  rm -rf "$install_root"
fi

mkdir -p "$install_root" "$target_root/config" "$target_root/.claude/commands" "$target_root/.claude/skills/pod2wiki"

copy_tree() {
  local src="$1"
  local dst="$2"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a \
      --exclude '.git' \
      --exclude '__pycache__' \
      --exclude '.pytest_cache' \
      --exclude '.venv' \
      --exclude 'venv' \
      --exclude 'output' \
      --exclude '.env' \
      --exclude 'config.yaml' \
      --exclude '*.pyc' \
      "$src/" "$dst/"
  else
    python - "$src" "$dst" <<'PY'
import os, shutil, sys
src, dst = sys.argv[1], sys.argv[2]
EXCLUDE_DIRS = {'.git', '__pycache__', '.pytest_cache', '.venv', 'venv', 'output'}
EXCLUDE_FILES = {'.env', 'config.yaml'}
def keep(name, is_dir):
    if is_dir and name in EXCLUDE_DIRS: return False
    if not is_dir and (name in EXCLUDE_FILES or name.endswith(('.pyc', '.pyo'))): return False
    return True
for root, dirs, files in os.walk(src):
    dirs[:] = [d for d in dirs if keep(d, True)]
    rel = os.path.relpath(root, src)
    out = dst if rel == '.' else os.path.join(dst, rel)
    os.makedirs(out, exist_ok=True)
    for f in files:
        if keep(f, False):
            shutil.copy2(os.path.join(root, f), os.path.join(out, f))
PY
  fi
}

copy_tree "$source_root" "$install_root"

config_source="$install_root/examples/config.ai-investing.yaml"
config_target="$target_root/config/pod2wiki.config.yaml"
if [[ ! -e "$config_target" || "$force" == "1" ]]; then
  cp "$config_source" "$config_target"
fi

env_target="$target_root/config/pod2wiki.env"
if [[ ! -e "$env_target" ]]; then
  cp "$install_root/.env.example" "$env_target"
fi

if [[ -z "$wiki_sources_path" ]]; then
  wiki_sources="$target_root/wiki/sources"
else
  wiki_sources="$(python -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$wiki_sources_path")"
fi
wiki_root="$(dirname "$wiki_sources")"
mkdir -p "$wiki_sources" "$wiki_root/raw/podcasts"

cp "$install_root/skills/pod2wiki/SKILL.md" "$target_root/.claude/skills/pod2wiki/SKILL.md"
cat > "$target_root/.claude/commands/pod2wiki.md" <<EOF
---
description: Scan podcasts/RSS/YouTube/local transcripts into wiki source-summary pages.
argument-hint: "[--mode rss|youtube|all] [--youtube-url URL] [--youtube-query QUERY] [--input-file PATH] [--no-llm]"
---

# /pod2wiki

Run pod2wiki from this workspace.

\`\`\`bash
python $install_dir_name/scripts/fetch_podcasts.py --config config/pod2wiki.config.yaml --env-file config/pod2wiki.env --output-dir output/pod2wiki --wiki-out "$wiki_sources" --days 7 --write-insight-log \$ARGUMENTS
\`\`\`

Use \`--no-llm\` for a no-key smoke test. Use \`--translate-full\` when the user asks for full transcript translation.

Report source pages, raw pages, translation pages, insight log path, and verification warnings.
EOF

if [[ "$skip_pip" != "1" ]]; then
  python -m pip install -r "$install_root/requirements.txt"
fi

python "$install_root/scripts/fetch_podcasts.py" --config "$config_target" --env-file "$env_target" --wiki-out "$wiki_sources" --days 1 --dry-run

echo "[pod2wiki] Installed."
echo "Config: $config_target"
echo "Env:    $env_target"
echo "Wiki:   $wiki_sources"
echo "Command: $target_root/.claude/commands/pod2wiki.md"
