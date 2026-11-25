# Lecture statique d'une chaîne locale Codex. Le manifeste fournit les paramètres.
param([string]$ManifestPath)

$ErrorActionPreference = 'Stop'
$encoding = [System.Text.Encoding]::UTF8
$strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
$pathComparison = if ($IsWindows) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }

function Stop-Diagnostic([string]$Code) {
  [ordered]@{
    mode = 'STATIC_AUTOMATIC_CANDIDATES'
    status = 'ERROR'
    code = $Code
    session_load = 'UNVERIFIED'
  } | ConvertTo-Json
  exit 1
}

function Assert-PathSegment([string]$Segment) {
  if ($Segment -in '.', '..' -or $Segment.IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -ge 0) {
    Stop-Diagnostic 'INVALID_PATH_SEGMENT'
  }
  if ($IsWindows -and ($Segment -match '[. ]$' -or
      $Segment -match '^(?:CON|PRN|AUX|NUL|COM[0-9¹²³]|LPT[0-9¹²³])(?:[ .]|$)')) {
    Stop-Diagnostic 'INVALID_PATH_SEGMENT'
  }
}

function Get-LocalPath([object]$Value, [switch]$AllowRelative) {
  if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value) -or $Value -match '^[\\/]{2}') {
    Stop-Diagnostic 'LOCAL_PATH_REQUIRED'
  }
  if (-not [IO.Path]::IsPathFullyQualified($Value)) {
    if (-not $AllowRelative -or [IO.Path]::IsPathRooted($Value)) {
      Stop-Diagnostic 'ABSOLUTE_PATH_REQUIRED'
    }
    $location = Get-Location
    if ($location.Provider.Name -ne 'FileSystem' -or $location.ProviderPath -match '^[\\/]{2}') {
      Stop-Diagnostic 'LOCAL_PATH_REQUIRED'
    }
    $Value = [IO.Path]::Combine($location.ProviderPath, $Value)
  }
  $volume = [IO.Path]::GetPathRoot($Value)
  foreach ($segment in $Value.Substring($volume.Length).Split([char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar))) {
    if ($segment -and $segment -ne '.') { Assert-PathSegment $segment }
  }
  $normalized = [IO.Path]::TrimEndingDirectorySeparator([IO.Path]::GetFullPath($Value))
  if ($IsWindows -and [IO.DriveInfo]::new($volume).DriveType -eq [IO.DriveType]::Network) {
    Stop-Diagnostic 'LOCAL_PATH_REQUIRED'
  }
  return $normalized
}

function Test-RegularUnixFile([string]$Path) {
  # Pass the pathname literally, even with the older PowerShell native
  # argument rules. The system probe only checks metadata.
  $probe = [Diagnostics.ProcessStartInfo]::new($regularFileTest)
  $probe.UseShellExecute = $false
  $probe.RedirectStandardOutput = $true
  $probe.RedirectStandardError = $true
  $probe.ArgumentList.Add('-f')
  $probe.ArgumentList.Add($Path)
  $process = [Diagnostics.Process]::Start($probe)
  try {
    $process.WaitForExit()
    if ($process.ExitCode -notin 0, 1) { Stop-Diagnostic 'REGULAR_FILE_PROBE_FAILED' }
    return $process.ExitCode -eq 0
  } finally {
    $process.Dispose()
  }
}

function Get-SafeEntry([string]$Path) {
  try {
    $attributes = [IO.File]::GetAttributes($Path)
  } catch [IO.FileNotFoundException], [IO.DirectoryNotFoundException] {
    return $null
  }
  if ($attributes.HasFlag([IO.FileAttributes]::ReparsePoint)) {
    Stop-Diagnostic 'REDIRECTED_PATH'
  }
  if ($attributes.HasFlag([IO.FileAttributes]::Directory)) {
    return [IO.DirectoryInfo]::new($Path)
  }
  # Unix file attributes alone do not distinguish a FIFO or socket from a file.
  if (-not $IsWindows -and -not (Test-RegularUnixFile $Path)) { return $null }
  return [IO.FileInfo]::new($Path)
}

function Assert-SafeDirectory([string]$Path) {
  $chain = [Collections.Generic.Stack[string]]::new()
  for ($parent = $Path; $parent; $parent = [IO.Path]::GetDirectoryName($parent)) {
    $chain.Push($parent)
  }
  foreach ($directory in $chain) {
    if ((Get-SafeEntry $directory) -isnot [IO.DirectoryInfo]) {
      Stop-Diagnostic 'DIRECTORY_UNAVAILABLE'
    }
  }
}

function Read-Prefix([IO.FileInfo]$File, [long]$Count, [Text.Encoding]$TextEncoding) {
  if ($Count -eq 0) { return '' }
  if ($Count -gt 1048576) { Stop-Diagnostic 'READ_LIMIT_EXCEEDED' }
  $stream = [IO.File]::Open($File.FullName, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
  try {
    if ($stream.Length -ne $File.Length) { Stop-Diagnostic 'FILE_CHANGED' }
    $reader = [IO.BinaryReader]::new($stream)
    $buffer = $reader.ReadBytes([int]$Count)
    if ($buffer.Length -ne $Count) { Stop-Diagnostic 'FILE_CHANGED' }
  } finally {
    $stream.Dispose()
  }
  return $TextEncoding.GetString($buffer)
}

function New-Candidate([string]$Scope, [int]$Level, [string]$Kind, [long]$Length) {
  return [ordered]@{
    scope = $Scope
    level = $Level
    candidate = $Kind
    file_bytes = $Length
    state = 'MASKED'
    budget_bytes = $null
    truncated = $null
  }
}

try {
  if (-not $ManifestPath -or $args.Count -gt 0) { Stop-Diagnostic 'MANIFEST_REQUIRED' }
  if (-not $IsWindows) {
    $regularFileTest = @('/usr/bin/test', '/bin/test') | Where-Object { [IO.File]::Exists($_) } |
      Select-Object -First 1
    if (-not $regularFileTest) { Stop-Diagnostic 'REGULAR_FILE_PROBE_UNAVAILABLE' }
  }
  $manifest = Get-LocalPath $ManifestPath -AllowRelative
  Assert-SafeDirectory ([IO.Path]::GetDirectoryName($manifest))
  $inputFile = Get-SafeEntry $manifest
  if ($inputFile -isnot [IO.FileInfo] -or $inputFile.Length -lt 1 -or $inputFile.Length -gt 65536) {
    Stop-Diagnostic 'MANIFEST_UNAVAILABLE'
  }
  $json = Read-Prefix $inputFile $inputFile.Length $strictUtf8
  $config = ConvertFrom-Json -InputObject ($json.TrimStart([char]0xFEFF)) -AsHashtable -NoEnumerate
  if ($config -isnot [System.Collections.IDictionary] -or $config.client -cne 'codex-cli') {
    Stop-Diagnostic 'UNSUPPORTED_MANIFEST'
  }
  $fields = @('client', 'cwd', 'global_dir', 'project_root', 'project_doc_max_bytes', 'project_doc_fallback_filenames')
  foreach ($key in $config.Keys) {
    if ($key -cnotin $fields) { Stop-Diagnostic 'UNSUPPORTED_MANIFEST_FIELD' }
  }

  $cwd = Get-LocalPath $config.cwd
  $globalDirectory = Get-LocalPath $config.global_dir
  Assert-SafeDirectory $cwd
  Assert-SafeDirectory $globalDirectory

  $rootMode = 'UNKNOWN'
  $root = $cwd
  if ($config.Contains('project_root')) {
    $rootMode = 'CWD_ONLY'
    if ($null -ne $config.project_root) {
      $rootMode = 'DECLARED'
      $root = Get-LocalPath $config.project_root
    }
  }
  $projectChain = [Collections.Generic.Stack[string]]::new()
  for ($directory = $cwd; $directory; $directory = [IO.Path]::GetDirectoryName($directory)) {
    $projectChain.Push($directory)
    if ($directory.Equals($root, $pathComparison)) { break }
  }
  if (-not $projectChain.Peek().Equals($root, $pathComparison)) { Stop-Diagnostic 'ROOT_OUTSIDE_CWD_CHAIN' }

  $budget = $config.project_doc_max_bytes
  if ($null -ne $budget -and (($budget -isnot [long] -and $budget -isnot [int]) -or $budget -lt 0)) {
    Stop-Diagnostic 'INVALID_PROJECT_BUDGET'
  }
  $fallbacks = $config.project_doc_fallback_filenames
  $names = [Collections.Generic.List[string]]::new()
  $names.AddRange([string[]]@('AGENTS.override.md', 'AGENTS.md'))
  if ($null -ne $fallbacks) {
    if ($fallbacks -isnot [array]) { Stop-Diagnostic 'INVALID_FALLBACK_LIST' }
    foreach ($candidate in $fallbacks) {
      if ($candidate -isnot [string] -or [string]::IsNullOrWhiteSpace($candidate)) {
        Stop-Diagnostic 'INVALID_FALLBACK_NAME'
      }
      Assert-PathSegment $candidate
      if (-not $names.Contains($candidate)) { $names.Add($candidate) }
    }
  }
  $knownProject = $rootMode -ne 'UNKNOWN' -and $null -ne $budget -and $null -ne $fallbacks
  $remaining = $budget
  $rows = [Collections.Generic.List[object]]::new()

  $globalSelected = $false
  for ($i = 0; $i -lt 2; $i++) {
    $file = Get-SafeEntry ([IO.Path]::Combine($globalDirectory, $names[$i]))
    if ($file -isnot [IO.FileInfo]) { continue }
    $kind = if ($i -eq 0) { 'override' } else { 'standard' }
    $row = New-Candidate global 0 $kind $file.Length
    if (-not $globalSelected) {
      $body = Read-Prefix $file $file.Length $encoding
      if ([string]::IsNullOrWhiteSpace($body)) {
        $row.state = 'EMPTY'
      } else {
        $row.state = 'INCLUDED'
        $globalSelected = $true
      }
    }
    $rows.Add($row)
  }

  $level = 0
  foreach ($directory in $projectChain) {
    $sourceSelected = $false
    for ($i = 0; $i -lt $names.Count; $i++) {
      $file = Get-SafeEntry ([IO.Path]::Combine($directory, $names[$i]))
      if ($file -isnot [IO.FileInfo]) { continue }
      $kind = switch ($i) {
        0 { 'override' }
        1 { 'standard' }
        default { 'fallback_' + ($i - 1) }
      }
      $row = New-Candidate project $level $kind $file.Length
      if (-not $sourceSelected) {
        $sourceSelected = $true
        $row.state = 'SELECTED_BUDGET_UNKNOWN'
        if ($knownProject) {
          if ($remaining -eq 0) {
            $row.state = 'SKIPPED_BUDGET'
            $row.budget_bytes = 0
          } else {
            $count = [Math]::Min([long]$remaining, $file.Length)
            $body = Read-Prefix $file $count $encoding
            $row.truncated = $count -lt $file.Length
            $row.budget_bytes = 0
            $row.state = 'EMPTY'
            if (-not [string]::IsNullOrWhiteSpace($body)) {
              $row.state = 'INCLUDED'
              $row.budget_bytes = $count
              $remaining -= $count
            }
          }
        }
      }
      $rows.Add($row)
    }
    $level++
  }

  [ordered]@{
    mode = 'STATIC_AUTOMATIC_CANDIDATES'
    status = if ($knownProject) { 'SIMULATED' } else { 'PARTIAL' }
    configuration_effective = 'UNVERIFIED'
    project_root = $rootMode
    project_fallbacks = if ($null -ne $fallbacks) { 'DECLARED' } else { 'UNKNOWN' }
    project_budget_bytes = $budget
    project_remaining_bytes = if ($knownProject) { $remaining } else { $null }
    session_load = 'UNVERIFIED'
    manual_reference = 'NOT_ASSESSED'
    candidates = $rows.ToArray()
  } | ConvertTo-Json -Depth 4
} catch {
  # Exceptions can include private paths, JSON payloads or filenames.
  Stop-Diagnostic 'DIAGNOSTIC_UNAVAILABLE'
}
