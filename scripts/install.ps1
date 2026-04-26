[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetDir,

    [string]$InstallDirName = "tools/pod2wiki",

    [string]$WikiSourcesPath = "",

    [switch]$SkipPip,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[pod2wiki] $Message" -ForegroundColor Cyan
}

function Write-Utf8File {
    param([string]$Path, [string]$Content)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Get-UsablePythonCommand {
    $candidates = @(
        @{ Name = "py"; VersionArgs = @("--version"); PrefixArgs = @("-3"); DisplayName = "py -3" },
        @{ Name = "python"; VersionArgs = @("--version"); PrefixArgs = @(); DisplayName = "python" },
        @{ Name = "python3"; VersionArgs = @("--version"); PrefixArgs = @(); DisplayName = "python3" }
    )
    foreach ($candidate in $candidates) {
        $command = Get-Command $candidate.Name -ErrorAction SilentlyContinue
        if (-not $command -or -not $command.Source) {
            continue
        }
        try {
            $output = & $command.Source @($candidate.VersionArgs) 2>&1 | Out-String
            if ($LASTEXITCODE -ne 0) {
                continue
            }
            if ($output -notmatch "Python\s+3(\.\d+)+") {
                continue
            }
            return [pscustomobject]@{
                Path = $command.Source
                PrefixArgs = $candidate.PrefixArgs
                DisplayName = $candidate.DisplayName
            }
        }
        catch {
            continue
        }
    }
    return $null
}

function Copy-ProjectTree {
    param([string]$SourceRoot, [string]$DestRoot)

    $excludeDirs = @(".git", "__pycache__", ".pytest_cache", ".venv", "venv", "output")
    $excludeFiles = @(".env", "config.yaml", "*.pyc", "*.pyo", "*.log")

    if (Test-Path $DestRoot) {
        if (-not $Force) {
            throw "Install target already exists: $DestRoot. Re-run with -Force to overwrite pod2wiki tool files."
        }
        Remove-Item -LiteralPath $DestRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $DestRoot | Out-Null

    Get-ChildItem -LiteralPath $SourceRoot -Force | ForEach-Object {
        if ($excludeDirs -contains $_.Name) {
            return
        }
        $target = Join-Path $DestRoot $_.Name
        if ($_.PSIsContainer) {
            Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force -Exclude $excludeFiles
        }
        else {
            $skip = $false
            foreach ($pattern in $excludeFiles) {
                if ($_.Name -like $pattern) {
                    $skip = $true
                    break
                }
            }
            if (-not $skip) {
                Copy-Item -LiteralPath $_.FullName -Destination $target -Force
            }
        }
    }
}

$sourceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$targetRoot = [System.IO.Path]::GetFullPath($TargetDir)
$installRoot = [System.IO.Path]::GetFullPath((Join-Path $targetRoot $InstallDirName))

Write-Step "Target workspace: $targetRoot"
Write-Step "Tool install dir: $installRoot"

New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
Copy-ProjectTree -SourceRoot $sourceRoot.Path -DestRoot $installRoot

$configDir = Join-Path $targetRoot "config"
$claudeCommandsDir = Join-Path $targetRoot ".claude/commands"
$claudeSkillsDir = Join-Path $targetRoot ".claude/skills/pod2wiki"
New-Item -ItemType Directory -Force -Path $configDir, $claudeCommandsDir, $claudeSkillsDir | Out-Null

$configSource = Join-Path $installRoot "examples/config.ai-investing.yaml"
$configTarget = Join-Path $configDir "pod2wiki.config.yaml"
if (-not (Test-Path $configTarget) -or $Force) {
    Copy-Item -LiteralPath $configSource -Destination $configTarget -Force
}

$envTarget = Join-Path $configDir "pod2wiki.env"
if (-not (Test-Path $envTarget)) {
    Copy-Item -LiteralPath (Join-Path $installRoot ".env.example") -Destination $envTarget -Force
}

if ([string]::IsNullOrWhiteSpace($WikiSourcesPath)) {
    $wikiSources = Join-Path $targetRoot "wiki/sources"
}
else {
    $wikiSources = [System.IO.Path]::GetFullPath($WikiSourcesPath)
}
$wikiRoot = Split-Path -Parent $wikiSources
New-Item -ItemType Directory -Force -Path $wikiSources, (Join-Path $wikiRoot "raw/podcasts") | Out-Null

$skillSource = Join-Path $installRoot "skills/pod2wiki/SKILL.md"
Copy-Item -LiteralPath $skillSource -Destination (Join-Path $claudeSkillsDir "SKILL.md") -Force

$commandPath = Join-Path $claudeCommandsDir "pod2wiki.md"
$wikiSourcesForward = $wikiSources.Replace('\','/')
$fence = [string][char]0x60 + [char]0x60 + [char]0x60
$commandTemplate = @'
---
description: Scan podcasts/RSS/YouTube/local transcripts into wiki source-summary pages.
argument-hint: "[--mode rss|youtube|all] [--youtube-url URL] [--youtube-query QUERY] [--input-file PATH] [--no-llm]"
---

# /pod2wiki

Run pod2wiki from this workspace.

__FENCE__bash
python __INSTALL_DIR__/scripts/fetch_podcasts.py --config config/pod2wiki.config.yaml --env-file config/pod2wiki.env --output-dir output/pod2wiki --wiki-out "__WIKI_SOURCES__" --days 7 --write-insight-log $ARGUMENTS
__FENCE__

Use `--no-llm` for a no-key smoke test. Use `--translate-full` when the user asks for full transcript translation.

Report source pages, raw pages, translation pages, insight log path, and verification warnings.
'@
$commandText = $commandTemplate.Replace('__INSTALL_DIR__', $InstallDirName).Replace('__WIKI_SOURCES__', $wikiSourcesForward).Replace('__FENCE__', $fence)
Write-Utf8File -Path $commandPath -Content $commandText

$python = Get-UsablePythonCommand
if ($python -and -not $SkipPip) {
    Write-Step "Installing Python dependencies with $($python.DisplayName)"
    & $python.Path @($python.PrefixArgs) -m pip install -r (Join-Path $installRoot "requirements.txt")
    if ($LASTEXITCODE -ne 0) {
        throw "pip install failed"
    }
}
elseif (-not $python) {
    Write-Step "Python 3 not found. Files were installed, but runtime checks were skipped."
}

if ($python) {
    Write-Step "Running dry-run smoke test"
    $prevPref = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $python.Path @($python.PrefixArgs) (Join-Path $installRoot "scripts/fetch_podcasts.py") --config $configTarget --env-file $envTarget --wiki-out $wikiSources --days 1 --dry-run 2>&1 | ForEach-Object { Write-Host $_ }
    }
    finally {
        $ErrorActionPreference = $prevPref
    }
    if ($LASTEXITCODE -ne 0) {
        throw "dry-run smoke test failed (exit code $LASTEXITCODE)"
    }
}

Write-Step "Installed."
Write-Host "Config: $configTarget"
Write-Host "Env:    $envTarget"
Write-Host "Wiki:   $wikiSources"
Write-Host "Command: $commandPath"
