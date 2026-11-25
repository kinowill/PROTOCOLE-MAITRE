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
  return (($text -creplace '^\uFEFF', '') -replace "\r\n?", "`n").TrimEnd([char]10)
}
try {
  if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { Fail 'Source introuvable ou non lisible.' }
  if (-not (Test-Path -LiteralPath $Target -PathType Leaf)) { Fail 'Cible introuvable ou non lisible.' }
  $sourceFile = Get-Item -LiteralPath $Source -Force
  if ($sourceFile.Length -eq 0 -or $sourceFile.Length -gt 3072) { Fail 'Source vide ou supérieure au budget de 3072 octets.' }
  $srcBytes = [System.IO.File]::ReadAllBytes($sourceFile.FullName)
  $srcLen = $srcBytes.Length
  if ($srcLen -ne $sourceFile.Length) { Fail 'La taille de la source a changé pendant le contrôle.' }
  $tgtBytes = [System.IO.File]::ReadAllBytes((Get-Item -LiteralPath $Target -Force).FullName)
  try {
    # ReadAllText peut changer d'encodage selon le BOM ; décoder les octets directement.
    $utf8 = [System.Text.UTF8Encoding]::new($false, $true)
    $src = Normalize-Lines ($utf8.GetString($srcBytes))
    $tgt = Normalize-Lines ($utf8.GetString($tgtBytes))
  } catch [System.Text.DecoderFallbackException] {
    Fail 'La source et la cible doivent être encodées en UTF-8.'
  }
  $header = '(?m)^#{1,6}\s+PROTOCOLE MAITRE\s+[—-]\s+Noyau\b[^\n]*$'
  $sourceHeaders = [regex]::Matches($src, $header)
  $targetHeaders = [regex]::Matches($tgt, $header)
  if ($sourceHeaders.Count -ne 1) { Fail 'La source doit contenir un seul en-tête de noyau.' }
  if ($targetHeaders.Count -ne 1) { Fail 'En-tête absent, doublon ou plusieurs versions du noyau dans la cible.' }
  $version = [regex]::Match($sourceHeaders[0].Value, '^# PROTOCOLE MAITRE — Noyau v(\d+\.\d+\.\d+)$')
  if (-not $version.Success) { Fail 'La source doit déclarer une version major.minor.patch complète.' }
  if ([string]::IsNullOrWhiteSpace($src.Remove($sourceHeaders[0].Index, $sourceHeaders[0].Length))) {
    Fail 'Le corps du noyau source est vide.'
  }
  if ($targetHeaders[0].Value -cne $sourceHeaders[0].Value) { Fail 'Version ou en-tête de cible différent de la source.' }
  # Le bloc doit occuper des lignes entières, même dans un fichier plus long.
  $count = [regex]::Matches($tgt, '(?m)^' + [regex]::Escape($src) + '$').Count
  if ($count -ne 1) { Fail 'Le noyau intégral doit apparaître exactement une fois, sans modification.' }
  $sha256 = [System.Security.Cryptography.SHA256]::Create()
  try {
    $sourceHash = [BitConverter]::ToString($sha256.ComputeHash($srcBytes)).Replace('-', '')
    $targetHash = [BitConverter]::ToString($sha256.ComputeHash($tgtBytes)).Replace('-', '')
  } finally {
    $sha256.Dispose()
  }
  $report = [ordered]@{
    date = (Get-Date -Format o)
    source_sha256 = $sourceHash
    target_sha256 = $targetHash
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
