# Audit des fichiers suivis : index et copie de travail, depuis la racine Git.
# Codes : 0 aucun motif, 1 correspondances, 2 contrôle impossible.
# Ne remplace pas un scanner spécialisé ni l'audit de l'historique avant push.
param([string]$Path = '', [string[]]$ExtraPatterns = @())
$ErrorActionPreference = 'Stop'
if (-not $Path) { $Path = Join-Path $PSScriptRoot '..' }
$pushed = $false
try {
  $git = @(Get-Command git,git.exe -CommandType Application -ErrorAction SilentlyContinue)[0]
  if (-not $git) { throw 'Git introuvable.' }
  Push-Location -LiteralPath $Path
  $pushed = $true
  $inside = & $git.Source rev-parse --is-inside-work-tree 2>$null
  if ($LASTEXITCODE -ne 0 -or $inside -ne 'true') { throw 'Dépôt Git requis.' }
  $root = & $git.Source rev-parse --show-toplevel 2>$null
  if ($LASTEXITCODE -ne 0) { throw 'Racine Git inaccessible.' }
  Set-Location -LiteralPath $root
  $unmerged = @(& $git.Source ls-files --unmerged 2>$null)
  if ($LASTEXITCODE -ne 0 -or $unmerged.Count -gt 0) { throw 'Index inaccessible ou conflits non résolus.' }
  # Git grep peut lire l'index à la place de la copie de travail pour ces flags.
  # Refuser un audit incomplet sans modifier les indicateurs de l'utilisateur.
  $flags = @(& $git.Source ls-files -v 2>$null)
  if ($LASTEXITCODE -ne 0) { throw 'Indicateurs index inaccessibles.' }
  if (@($flags | Where-Object { $_ -cmatch '^[a-zS] ' }).Count -gt 0) {
    throw 'Fichiers assume-unchanged ou skip-worktree : copie de travail non vérifiable.'
  }
  # POSIX ERE ; fragments pour éviter l'auto-détection.
  $patterns = @(
    ('gh' + '[op]_[A-Za-z0-9]{20,}'),
    ('github' + '_pat_[A-Za-z0-9_]{20,}'),
    ('sk' + '-[A-Za-z0-9_-]{20,}'),
    ('AK' + 'IA[0-9A-Z]{16}'),
    ('AI' + 'za[0-9A-Za-z_-]{35}'),
    ('BEGIN ' + '[A-Z ]*PRIVATE KEY'),
    ('password' + '["'']?[[:space:]]*[:=][[:space:]]*["'']?[^[:space:]"''#]+')
  )
  $failed = $false
  foreach ($scope in @('index', 'worktree')) {
    # -a inclut les binaires ; -l évite de capturer les lignes sensibles.
    $argsList = @('grep', '-l', '-a', '-i', '-E')
    if ($scope -eq 'index') { $argsList += '--cached' }
    foreach ($pattern in $patterns) { $argsList += @('-e', $pattern) }
    $files = @(& $git.Source @argsList -- . 2>&1)
    $code = $LASTEXITCODE
    if ($code -notin @(0, 1)) { throw 'Recherche Git impossible.' }
    if ($code -eq 0) {
      $failed = $true
      Write-Host "[SENSIBLE $scope] $($files.Count) fichier(s), valeurs et chemins masqués."
    }
    foreach ($literal in $ExtraPatterns) {
      if ([string]::IsNullOrEmpty($literal)) { continue }
      $argsList = @('grep', '-l', '-a', '-F')
      if ($scope -eq 'index') { $argsList += '--cached' }
      $files = @(& $git.Source @argsList -e $literal -- . 2>&1)
      $code = $LASTEXITCODE
      if ($code -notin @(0, 1)) { throw 'Recherche littérale Git impossible.' }
      if ($code -eq 0) {
        $failed = $true
        Write-Host "[SENSIBLE $scope] Motif additionnel détecté, valeurs et chemins masqués."
      }
    }
  }
  if ($failed) { Write-Host 'Correspondances trouvées ; vérifier avant publication.'; exit 1 }
  Write-Host 'Aucun motif détecté dans les fichiers suivis (index et copie de travail, binaires inclus). Les fichiers non suivis, sous-modules et l''historique ne sont pas analysés.'
  exit 0
} catch {
  # Les exceptions peuvent contenir un chemin ou une valeur sensible.
  Write-Host '[ERREUR] Audit incomplet : vérifier Git, le répertoire, les accès, les conflits et les indicateurs Git. Ne pas publier.'
  exit 2
} finally {
  if ($pushed) { Pop-Location }
}
