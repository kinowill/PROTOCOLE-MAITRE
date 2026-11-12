# install-check.ps1 — Contrôle statique, sans modifier l'installation.
# Usage : .\install-check.ps1 -Target ~/.config/opencode/AGENTS.md
# Rapport console sans chemin personnel ; code 0 conforme, 1 sinon.
param(
  [Parameter(Mandatory=$true)][string]$Target,
  [string]$Source = ''
)
$ErrorActionPreference = 'Stop'
if (-not $Source) { $Source = Join-Path (Join-Path $PSScriptRoot '..') 'NOYAU.md' }
function Fail($message) { Write-Host "[ERREUR] $message"; exit 1 }
function Normalize-Lines([string]$text) {
  return ($text.TrimStart([char]0xFEFF) -replace "\r\n?", "`n").TrimEnd([char]10)
}
try {
  if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { Fail 'Source introuvable ou non lisible.' }
  if (-not (Test-Path -LiteralPath $Target -PathType Leaf)) { Fail 'Cible introuvable ou non lisible.' }
  $srcLen = (Get-Item -LiteralPath $Source).Length
  if ($srcLen -eq 0 -or $srcLen -gt 3072) { Fail 'Source vide ou supérieure au budget de 3072 octets.' }
  $utf8 = [System.Text.UTF8Encoding]::new($false, $true)
  $src = Normalize-Lines ([System.IO.File]::ReadAllText((Get-Item -LiteralPath $Source).FullName, $utf8))
  $tgt = Normalize-Lines ([System.IO.File]::ReadAllText((Get-Item -LiteralPath $Target).FullName, $utf8))
  $header = '(?m)^#{1,6}\s+PROTOCOLE MAITRE\s+[—-]\s+Noyau\b[^\n]*$'
  $sourceHeaders = [regex]::Matches($src, $header)
  $targetHeaders = [regex]::Matches($tgt, $header)
  if ($sourceHeaders.Count -ne 1) { Fail 'La source doit contenir un seul en-tête de noyau.' }
  if ($targetHeaders.Count -ne 1) { Fail 'En-tête absent, doublon ou plusieurs versions du noyau dans la cible.' }
  $version = [regex]::Match($sourceHeaders[0].Value, '^# PROTOCOLE MAITRE — Noyau v(\d+\.\d+\.\d+)$')
  if (-not $version.Success) { Fail 'La source doit déclarer une version major.minor.patch complète.' }
  if ($targetHeaders[0].Value -cne $sourceHeaders[0].Value) { Fail 'Version ou en-tête de cible différent de la source.' }
  # Seuls BOM et fins de ligne sont normalisés : contenu et espaces préservés.
  $count = [regex]::Matches($tgt, [regex]::Escape($src)).Count
  if ($count -ne 1) { Fail 'Le noyau intégral doit apparaître exactement une fois, sans modification.' }
  $report = [ordered]@{
    date = (Get-Date -Format o)
    source_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $Source).Hash
    target_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $Target).Hash
    version_noyau = $version.Groups[1].Value
    source_bytes = $srcLen
    occurrences = $count
    statut = 'OK_STATIQUE'
    chargement_session = 'NON_VERIFIE'
  }
  $report | ConvertTo-Json
  Write-Host 'Contrôle statique conforme. Le chargement effectif et le comportement en nouvelle session restent à vérifier.'
  exit 0
} catch {
  # Ne jamais recopier une exception brute : elle peut révéler un chemin personnel.
  Write-Host '[ERREUR] Contrôle impossible : vérifier les accès et les fichiers source/cible.'
  exit 1
}
