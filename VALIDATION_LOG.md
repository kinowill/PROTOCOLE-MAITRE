# Journal de validation — PROTOCOLE MAITRE

## 2026-09-23 — Création et publication

- **Contrôles exécutés** : tailles du noyau et de la référence, UTF-8 des
  fichiers, structure du dépôt, syntaxe PowerShell, blocs Markdown — tous
  réussis.
- **Vérificateur d'installation** (`install-check.ps1`) : cible conforme et
  cibles défectueuses (tronquée, doublon, source hors budget) testées —
  comportements conformes.
- **Publication** : dépôt public `kinowill/PROTOCOLE-MAITRE`, branche `main`,
  CI GitHub Actions verte.
- **Limites** : la validation comportementale d'une installation incombe à
  l'intégrateur (méthode SM-01…SM-07 dans `VALIDATION_SCENARIOS.md`).
