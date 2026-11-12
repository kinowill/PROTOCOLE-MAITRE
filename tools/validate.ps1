# Contrôles statiques reproductibles, sans accès réseau ni configuration utilisateur.
param([string]$Path = (Join-Path $PSScriptRoot '..'))
$ErrorActionPreference = 'Stop'
try {
  $root = (Resolve-Path -LiteralPath $Path).Path
  $core = Join-Path $root 'NOYAU.md'
  if ((Get-Item -LiteralPath $core).Length -gt 3072) { throw 'Noyau > 3072 octets.' }
  $reference = Get-Content -Raw -LiteralPath (Join-Path $root 'PROTOCOLE.md')
  if ([regex]::Matches($reference, '(?m)^## ').Count -lt 15) { throw 'Sections de référence manquantes.' }
  foreach ($name in @('opencode', 'harness-dsh', 'codex', 'claude-code', 'generic')) {
    $adapter = Join-Path $root "integrations/$name.md"
    if (-not (Test-Path -LiteralPath $adapter -PathType Leaf)) { throw 'Adaptateur manquant.' }
    if ((Get-Content -Raw -LiteralPath $adapter) -match 'interdit|obligatoire|non négociable|non-negociable') {
      throw "Vocabulaire normatif à examiner dans integrations/$name.md."
    }
  }
  # Fichiers suivis et nouveaux non ignorés ; ne pas parcourir les données privées.
  $git = @(Get-Command git,git.exe -CommandType Application -ErrorAction SilentlyContinue)[0]
  if (-not $git) { throw 'Git requis pour établir le périmètre des contrôles.' }
  $paths = @(& $git.Source -C $root ls-files --cached --others --exclude-standard --deduplicate -z 2>$null)
  if ($LASTEXITCODE -ne 0) { throw 'Inventaire Git impossible.' }
  $files = foreach ($relative in (($paths -join "`n") -split [char]0)) {
    if ([string]::IsNullOrEmpty($relative)) { continue }
    $fullPath = Join-Path $root $relative
    if (Test-Path -LiteralPath $fullPath -PathType Leaf) { Get-Item -LiteralPath $fullPath -Force }
  }
  $utf8 = [System.Text.UTF8Encoding]::new($false, $true)
  foreach ($file in $files) {
    if ($file.Extension -in @('.md', '.ps1', '.mjs', '.yml', '.bat')) {
      $null = $utf8.GetString([System.IO.File]::ReadAllBytes($file.FullName))
    }
    if ($file.Extension -eq '.ps1') {
      $tokens = $null; $parseErrors = $null
      $null = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
      if ($parseErrors.Count -gt 0) { throw "Syntaxe PowerShell invalide : $($file.Name)." }
    }
    if ($file.Extension -eq '.mjs') {
      & node --check $file.FullName
      if ($LASTEXITCODE -ne 0) { throw "Syntaxe JavaScript invalide : $($file.Name)." }
    }
  }
  Write-Host 'OK : budget noyau, sections, 5 adaptateurs, UTF-8 et syntaxe des scripts.'
  exit 0
} catch {
  Write-Host "[ERREUR] $($_.Exception.Message)"
  exit 1
}
