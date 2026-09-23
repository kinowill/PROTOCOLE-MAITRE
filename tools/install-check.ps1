# install-check.ps1 — Vérificateur d'installation du protocole MAITRE
# Usage :
#   .\install-check.ps1 -Target C:\Users\<toi>\.claude\CLAUDE.md
#   .\install-check.ps1 -Target ~/.codex/AGENTS.md -Source "C:\PROJETS\PROTOCOLE MAITRE\NOYAU.md"
# Sortie : rapport texte + JSON dans <Target>.verification.json ; code 0 si conforme, 1 sinon.

param(
  [Parameter(Mandatory=$true)][string]$Target,
  [string]$Source = "C:\PROJETS\PROTOCOLE MAITRE\NOYAU.md"
)
$ErrorActionPreference = 'Stop'
function Fail($msg) { Write-Host "[ERREUR] $msg"; exit 1 }

if (-not (Test-Path -LiteralPath $Source)) { Fail "Source introuvable : $Source" }
if (-not (Test-Path -LiteralPath $Target)) { Fail "Cible introuvable : $Target" }

$src = Get-Content -Raw -Encoding UTF8 -LiteralPath $Source
$tgt = Get-Content -Raw -Encoding UTF8 -LiteralPath $Target

# 1. Intégralité : la cible contient le noyau complet (normalisation des espaces)
$srcNorm = ($src -replace '\s+', ' ').Trim()
$tgtNorm = ($tgt -replace '\s+', ' ').Trim()
if (-not $tgtNorm.Contains($srcNorm)) {
  Fail "Le bloc du noyau n'est pas présent intégralement dans la cible (absent ou tronqué)."
}

# 2. Doublons
$count = ([regex]::Matches($tgtNorm, [regex]::Escape($srcNorm))).Count
if ($count -gt 1) { Fail "Le bloc du noyau apparaît $count fois dans la cible (doublon)." }

# 3. Version
if ($tgt -notmatch 'PROTOCOLE MAITRE — Noyau v(\d+\.\d+)') { Fail "Ligne de version du noyau absente de la cible." }
$ver = $Matches[1]
$srcVer = if ($src -match 'Noyau v(\d+\.\d+)') { $Matches[1] } else { '?' }
if ($ver -ne $srcVer) { Fail "Version installée ($ver) différente de la source ($srcVer)." }

# 4. Taille de la source (garde-fou ≤ 3 Ko)
$srcLen = (Get-Item -LiteralPath $Source).Length
if ($srcLen -gt 3072) { Fail "NOYAU.md dépasse 3072 octets ($srcLen) : règle du noyau ≤ 3 Ko violée." }

$report = [ordered]@{
  date = (Get-Date -Format o)
  source = (Resolve-Path -LiteralPath $Source).Path
  source_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $Source).Hash
  target = (Resolve-Path -LiteralPath $Target).Path
  version_noyau = $ver
  source_bytes = $srcLen
  occurrences = $count
  statut = 'OK'
}
$report | ConvertTo-Json | Tee-Object -FilePath "$Target.verification.json"
Write-Host "Installation conforme : noyau v$ver présent 1 fois, intégral, taille source $srcLen octets."
exit 0
