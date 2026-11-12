# Statistiques natives OpenCode 2 ; aucun calcul du contexte actif.
param(
  [ValidateSet('Stats', 'Sessions', 'Paths')][string]$Mode = 'Stats',
  [string]$OpenCodeCommand = 'opencode'
)
$ErrorActionPreference = 'Stop'
try {
  $command = Get-Command $OpenCodeCommand -CommandType Application,ExternalScript -ErrorAction Stop
  $commandArgs = switch ($Mode) {
    'Stats' { @('stats', '--models', '--cost') }
    'Sessions' { @('session', 'list') }
    'Paths' { @('debug', 'paths', 'db') }
  }
  Write-Host 'OpenCode : données locales ; ne pas partager de sortie contenant des informations privées.'
  Write-Host 'Les statistiques d''usage ne mesurent pas le remplissage exact du contexte actif.'
  & $command.Source @commandArgs
  $code = $LASTEXITCODE
  if ($code -ne 0) {
    Write-Host 'Échec OpenCode : vérifier la version et l''aide de la commande.'
    exit $code
  }
  Write-Host 'Aucun pourcentage estimé : la limite et les compteurs dépendent du modèle actif.'
  exit 0
} catch {
  Write-Host 'OpenCode introuvable ou inexécutable. Vérifier PATH et opencode --help.'
  exit 2
}
