# show_context.ps1
# ==========================================================================
# Affiche l'etat des contextes / tokens des sessions opencode / DeepSeek.
#
# Source : C:\Users\<user>\.claude\projects\<projet>\<session-id>.jsonl
#          (opencode stocke ses sessions au meme endroit que Claude Code)
#
# Pour chaque session, on lit le DERNIER message assistant et on extrait
# message.usage (input + cache_creation + cache_read + output). Le total
# prompt = input + cache_creation + cache_read = ce que l'API voit en entree
# au prochain tour. C'est le chiffre a comparer a la fenetre de contexte.
#
# Fenetre DeepSeek V4 Pro = 1 000 000 tokens.
# ==========================================================================

$ErrorActionPreference = "Stop"
$CONTEXT_WINDOW = 1000000

# Force la culture invariant pour les separateurs de milliers (sinon l'espace
# insecable francais s'affiche mal dans la console Windows par defaut).
$INV = [System.Globalization.CultureInfo]::InvariantCulture

$projectsDir = Join-Path $env:USERPROFILE ".claude\projects"
if (-not (Test-Path $projectsDir)) {
    Write-Host ""
    Write-Host "  [ERR] Aucun dossier opencode/ClaudeCode trouve : $projectsDir" -ForegroundColor Red
    Write-Host ""
    Write-Host "  opencode doit etre utilise au moins une fois pour generer des sessions." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Recupere tous les .jsonl, tries du plus recent au plus ancien
$jsonls = Get-ChildItem -Path $projectsDir -Recurse -Filter *.jsonl `
    | Sort-Object LastWriteTime -Descending

if ($jsonls.Count -eq 0) {
    Write-Host ""
    Write-Host "  [INFO] Aucune session opencode trouvee dans $projectsDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Lance une session opencode pour generer des donnees." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

function Get-LastUsage {
    param([string]$Path)
    $lines = Get-Content -LiteralPath $Path -Encoding UTF8
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        $line = $lines[$i]
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try {
            $obj = $line | ConvertFrom-Json -ErrorAction Stop
        } catch {
            continue
        }
        if ($obj.type -eq "assistant" -and $obj.message -and $obj.message.usage) {
            return $obj.message.usage
        }
    }
    return $null
}

function Decode-ProjectPath {
    param([string]$EncodedDir)
    # Le dossier projet a la forme "C--Users-<user>-path-to-project"
    # On retransforme en chemin Windows lisible.
    $name = Split-Path $EncodedDir -Leaf
    $parts = $name -split '-'
    if ($parts.Count -gt 0 -and $parts[0].Length -eq 1) {
        # Drive letter (C, D, ...) suivi de --
        $drive = $parts[0] + ":"
        $rest = ($parts[1..($parts.Count - 1)] | Where-Object { $_ -ne "" }) -join "\"
        return "$drive\$rest"
    }
    return $name
}

function Format-Tokens {
    param([int]$N)
    return ($N.ToString("N0", $script:INV)).PadLeft(9)
}

function Format-Bar {
    param([double]$Pct, [int]$Width = 20)
    $filled = [Math]::Min($Width, [Math]::Round($Width * $Pct / 100))
    return ("#" * $filled) + ("." * ($Width - $filled))
}

function Format-Age {
    param([datetime]$When)
    $delta = (Get-Date) - $When
    if ($delta.TotalMinutes -lt 1) { return "il y a <1 min" }
    if ($delta.TotalMinutes -lt 60) { return "il y a $([int]$delta.TotalMinutes) min" }
    if ($delta.TotalHours -lt 24)   { return "il y a $([int]$delta.TotalHours) h" }
    return "il y a $([int]$delta.TotalDays) j"
}

# ─── Collecte ─────────────────────────────────────────────────────────────
$sessions = @()
foreach ($f in $jsonls) {
    $usage = Get-LastUsage -Path $f.FullName
    if ($null -eq $usage) { continue }

    $input         = [int]($usage.input_tokens         | ForEach-Object { if ($_) { $_ } else { 0 } })
    $cacheCreation = [int]($usage.cache_creation_input_tokens | ForEach-Object { if ($_) { $_ } else { 0 } })
    $cacheRead     = [int]($usage.cache_read_input_tokens     | ForEach-Object { if ($_) { $_ } else { 0 } })
    $output        = [int]($usage.output_tokens        | ForEach-Object { if ($_) { $_ } else { 0 } })

    $promptTotal = $input + $cacheCreation + $cacheRead
    $pct = [Math]::Round(100.0 * $promptTotal / $CONTEXT_WINDOW, 1)
    $cacheHit = if ($promptTotal -gt 0) {
        [Math]::Round(100.0 * $cacheRead / $promptTotal, 0)
    } else { 0 }

    $sessions += [PSCustomObject]@{
        Project       = Decode-ProjectPath $f.DirectoryName
        SessionId     = $f.BaseName
        LastWrite     = $f.LastWriteTime
        Input         = $input
        CacheCreation = $cacheCreation
        CacheRead     = $cacheRead
        Output        = $output
        PromptTotal   = $promptTotal
        Pct           = $pct
        CacheHit      = $cacheHit
    }
}

if ($sessions.Count -eq 0) {
    Write-Host ""
    Write-Host "  [INFO] Sessions trouvees mais aucune avec des donnees de tokens." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# ─── Affichage ────────────────────────────────────────────────────────────
$top = $sessions | Select-Object -First 1

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  DeepSeek / opencode - Etat des contextes" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Session la plus recente"
Write-Host "  ----------------------------------------------------------------"
Write-Host "  Projet         : $($top.Project)"
Write-Host "  Session ID     : $($top.SessionId)"
Write-Host "  Dernier message: $(Format-Age $top.LastWrite)  ($($top.LastWrite.ToString('yyyy-MM-dd HH:mm')))"
Write-Host ""
Write-Host "  Tokens (dernier tour)"
Write-Host "  ----------------------------------------------------------------"

$bar = Format-Bar -Pct $top.Pct
$pctStr = ($top.Pct.ToString("N1", $INV)).PadLeft(5) + "%"
$ctxStr = $CONTEXT_WINDOW.ToString("N0", $INV)
Write-Host "  Prompt total   : $(Format-Tokens $top.PromptTotal)  [$bar] $pctStr / $ctxStr"
Write-Host "   |- Input frais       : $(Format-Tokens $top.Input)"
Write-Host "   |- Cache creation    : $(Format-Tokens $top.CacheCreation)"
Write-Host "   |- Cache read        : $(Format-Tokens $top.CacheRead)  (cache hit $($top.CacheHit)%)"
Write-Host ""
Write-Host "  Output         : $(Format-Tokens $top.Output)"
Write-Host ""

# Top 5 sessions recentes
$topN = $sessions | Select-Object -First 5
if ($topN.Count -gt 1) {
    Write-Host "  Top sessions recentes"
    Write-Host "  ----------------------------------------------------------------"
    $rank = 1
    foreach ($s in $topN) {
        $shortProject = Split-Path $s.Project -Leaf
        $pctCol = ($s.Pct.ToString("N1", $INV)).PadLeft(5) + "%"
        $line = "  {0}. {1,-15} {2}  ({3})  {4}" -f `
            $rank, $shortProject, (Format-Tokens $s.PromptTotal), $pctCol, (Format-Age $s.LastWrite)
        Write-Host $line
        $rank++
    }
    Write-Host ""
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
