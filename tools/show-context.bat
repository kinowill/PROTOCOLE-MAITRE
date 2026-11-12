@echo off
rem Affiche des statistiques OpenCode, pas le remplissage exact du contexte.
rem Garder ce lanceur avec show_context.ps1 ; un raccourci peut pointer ici.
pwsh.exe -NoProfile -File "%~dp0show_context.ps1"
set "audit_exit=%ERRORLEVEL%"
pause
exit /b %audit_exit%
