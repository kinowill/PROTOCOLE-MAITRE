@echo off
rem Affiche la consommation de contexte de la session en cours.
rem Place ce fichier sur le Bureau pour un acces en deux clics.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0show_context.ps1"
pause
