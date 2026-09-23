# pre-push-audit.ps1 — Audit de publication du protocole MAITRE
# Vérifie les fichiers suivis par git avant toute publication : secrets et
# motifs sensibles. Usage :
#   .\pre-push-audit.ps1
#   .\pre-push-audit.ps1 -ExtraPatterns 'C:\Users\moi','mon-secret'
# Sortie : correspondances ou « aucun motif » ; code 0 si propre, 1 sinon.

param(
  [string]$Path = '',
  [string[]]$ExtraPatterns = @()
)
if (-not $Path) { $Path = Join-Path $PSScriptRoot '..' }
Set-Location $Path

# Motifs construits par concaténation pour ne pas apparaître littéralement ici.
$gho = 'gh' + 'o_'
$ghp = 'gh' + 'p_'
$sk  = 'sk' + '-'
$aws = 'AKIA[0-9A-Z]{16}'
$gcp = 'AIza[0-9A-Za-z_-]{35}'
$pem = 'BEGIN [A-Z ]*PRIVATE KEY'
$pw  = 'password\s*=\s*[^\s"''#]+'

$patterns = @($gho, $ghp, $sk, $aws, $gcp, $pem, $pw) + $ExtraPatterns
$pattern = ($patterns | ForEach-Object { [regex]::Escape($_) }) -join '|'

$files = git ls-files
$hits = 0
foreach ($f in $files) {
  if ($f -eq 'tools/pre-push-audit.ps1' -or $f -eq '.github/workflows/ci.yml') { continue }
  $content = Get-Content -Raw -Encoding UTF8 -ErrorAction SilentlyContinue $f
  if (-not $content) { continue }
  $m = [regex]::Matches($content, $pattern, 'IgnoreCase')
  foreach ($x in $m) {
    $line = ($content.Substring(0, $x.Index) -split "`n").Count
    Write-Host "[SENSIBLE] $f : ligne $line"
    $hits++
  }
}
if ($hits -gt 0) {
  Write-Host "ERREUR : $hits correspondance(s) sensible(s). Ne pas publier sans vérification."
  exit 1
}
Write-Host 'Aucun motif sensible dans les fichiers suivis.'
exit 0
