# Contrôles statiques reproductibles, sans accès réseau ni configuration utilisateur.
param([string]$Path = (Join-Path $PSScriptRoot '..'))
$ErrorActionPreference = 'Stop'
$utf8 = [System.Text.UTF8Encoding]::new($false, $true)
function Fail($message) { Write-Host "[ERREUR] $message"; exit 1 }
function Read-Utf8([string]$filePath) {
  try {
    return $utf8.GetString([System.IO.File]::ReadAllBytes($filePath)) -creplace '^\uFEFF', ''
  } catch [System.Text.DecoderFallbackException] {
    Fail "UTF-8 invalide : $([System.IO.Path]::GetFileName($filePath))."
  }
}

function Get-MarkdownHeadings([string]$markdown) {
  # Les exemples délimités par une clôture Markdown ne définissent pas de sections.
  $closingFence = $null
  foreach ($line in ($markdown -split '\r\n?|\n')) {
    if ($closingFence) {
      if ($line -cmatch $closingFence) { $closingFence = $null }
      continue
    }
    if ($line -cmatch '^ {0,3}(`{3,}|~{3,})') {
      $marker = $Matches[1][0]
      $closingFence = '^ {0,3}' + $marker + '{' + $Matches[1].Length + ',}[ \t]*$'
      continue
    }
    if ($line -cmatch '^ {0,3}(#{1,6})[ \t]+(.+?)(?:[ \t]+#+)?[ \t]*$') {
      [pscustomobject]@{ Level = $Matches[1].Length; Title = $Matches[2] }
    }
  }
}

function Test-Adapter([string]$content, [string]$name) {
  if (Get-MarkdownHeadings $content | Where-Object { $_.Title -cmatch '^PROTOCOLE MAITRE[ \t]+[—-][ \t]+Noyau\b' }) {
    Fail "En-tête du noyau repris dans integrations/$name."
  }
  if ($content -match 'interdit|obligatoire|non[- ]n[ée]gociable') {
    Write-Warning "[AVERTISSEMENT] Vocabulaire normatif à examiner dans integrations/$name."
  }
}

function Get-GitPaths([string]$executable, [string]$root) {
  $startInfo = [System.Diagnostics.ProcessStartInfo]::new($executable)
  $startInfo.WorkingDirectory = $root
  $startInfo.UseShellExecute = $false
  $startInfo.RedirectStandardOutput = $true
  $startInfo.RedirectStandardError = $true
  foreach ($argument in @('ls-files', '--cached', '--others', '--exclude-standard', '--deduplicate', '-z')) {
    $startInfo.ArgumentList.Add($argument)
  }
  $buffer = [System.IO.MemoryStream]::new()
  $process = [System.Diagnostics.Process]::Start($startInfo)
  try {
    # Lire les octets de Git sans décodage console ni découpage par lignes.
    $output = $process.StandardOutput.BaseStream.CopyToAsync($buffer)
    $errors = $process.StandardError.BaseStream.CopyToAsync([System.IO.Stream]::Null)
    $process.WaitForExit()
    $output.GetAwaiter().GetResult()
    $errors.GetAwaiter().GetResult()
    if ($process.ExitCode -ne 0) { Fail 'Inventaire Git impossible.' }
    return $utf8.GetString($buffer.ToArray()).Split([char]0, [System.StringSplitOptions]::RemoveEmptyEntries)
  } finally {
    $process.Dispose()
    $buffer.Dispose()
  }
}

try {
  $root = (Resolve-Path -LiteralPath $Path).Path
  $core = Join-Path $root 'NOYAU.md'
  if (-not (Test-Path -LiteralPath $core -PathType Leaf)) { Fail 'Noyau manquant.' }
  $coreLength = (Get-Item -LiteralPath $core -Force).Length
  if ($coreLength -eq 0 -or $coreLength -gt 3072) { Fail 'Noyau vide ou supérieur au budget de 3072 octets.' }
  $coreTitle, $coreBody = (Read-Utf8 $core) -split '\r\n?|\n', 2
  if ($coreTitle -cnotmatch '^# PROTOCOLE MAITRE — Noyau v\d+\.\d+\.\d+$' -or [string]::IsNullOrWhiteSpace($coreBody)) {
    Fail 'Le noyau doit déclarer une version major.minor.patch complète et contenir des règles.'
  }
  $reference = Join-Path $root 'PROTOCOLE.md'
  if (-not (Test-Path -LiteralPath $reference -PathType Leaf)) { Fail 'Référence manquante.' }
  $requiredHeadings = @(
    'Préambule'
    '1. Communication'
    '2. Sources et autorité'
    '3. Protocole de début de session'
    '4. Sources de vérité — règles d''action'
    '5. Distinction repo / prod / validation'
    '6. Mise à jour de la vérité du projet'
    '7. Git et commits'
    '8. Sécurité et secrets'
    '9. Décisions'
    '10. Posture face aux erreurs et obstacles'
    '11. Posture face aux propositions externes'
    '12. Ce qui est interdit'
    '13. Contexte, compaction et continuité'
    '14. Outils et adaptateurs'
    '15. Pourquoi ce protocole tient'
  )
  $headings = @(Get-MarkdownHeadings (Read-Utf8 $reference) | Where-Object Level -eq 2 | ForEach-Object Title)
  foreach ($heading in $requiredHeadings) {
    if (@($headings -ceq $heading).Count -ne 1) { Fail "Section de référence absente ou dupliquée : $heading." }
  }
  $pathComparer = if ($IsWindows) { [System.StringComparer]::OrdinalIgnoreCase } else { [System.StringComparer]::Ordinal }
  $requiredAdapters = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@('opencode.md', 'harness-dsh.md', 'codex.md', 'claude-code.md', 'generic.md'), $pathComparer
  )
  foreach ($name in $requiredAdapters) {
    $adapter = Join-Path $root "integrations/$name"
    if (-not (Test-Path -LiteralPath $adapter -PathType Leaf)) { Fail "Adaptateur manquant : integrations/$name." }
    Test-Adapter (Read-Utf8 $adapter) $name
  }
  # Fichiers suivis et nouveaux non ignorés ; ne pas parcourir les données privées.
  $git = @(Get-Command git,git.exe -CommandType Application -ErrorAction SilentlyContinue)[0]
  if (-not $git) { Fail 'Git requis pour établir le périmètre des contrôles.' }
  foreach ($relative in (Get-GitPaths $git.Source $root)) {
    $fullPath = Join-Path $root $relative
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { continue }
    $file = Get-Item -LiteralPath $fullPath -Force
    if ($file.Extension -in @('.md', '.ps1', '.mjs', '.yml', '.bat')) {
      $content = Read-Utf8 $file.FullName
      if ($file.Extension -eq '.md' -and $pathComparer.Equals([System.IO.Path]::GetDirectoryName($relative), 'integrations') -and
          -not $requiredAdapters.Contains($file.Name)) {
        Test-Adapter $content $file.Name
      }
    }
    if ($file.Extension -eq '.ps1') {
      $tokens = $null; $parseErrors = $null
      $null = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
      if ($parseErrors.Count -gt 0) { Fail "Syntaxe PowerShell invalide : $($file.Name)." }
    }
    if ($file.Extension -eq '.mjs') {
      & node --check $file.FullName 2>$null
      if ($LASTEXITCODE -ne 0) { Fail "Syntaxe JavaScript invalide : $($file.Name)." }
    }
  }
  Write-Host 'OK : budget noyau, sections, 5 adaptateurs, UTF-8 et syntaxe des scripts.'
  exit 0
} catch {
  Write-Host '[ERREUR] Validation impossible : vérifier le dépôt, les accès et les outils.'
  exit 1
}
