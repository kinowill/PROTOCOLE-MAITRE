# Journal de validation — PROTOCOLE MAITRE

## 2026-09-23 — Création du dépôt (candidate v1.0)

- **Demande explicite** : concevoir et implémenter PROTOCOLE MAITRE,
  convergence agnostique des protocoles CLAUDE/CODEX/DEEPSEEK, dans
  `C:\PROJETS\PROTOCOLE MAITRE` puis sur GitHub `kinowill/PROTOCOLE-MAITRE`.
- **État testé** : dépôt local neuf, fichiers écrits, aucun commit créé au
  moment de la rédaction de cette entrée. Environnement Windows / PowerShell.
- **Contrôles exécutés** :

| Contrôle | Attendu | Observé | Statut |
|---|---|---|---|
| Taille de `NOYAU.md` | ≤ 3 072 octets | 2 904 octets | réussi |
| Taille de `PROTOCOLE.md` | < 32 197 octets (v1.4 DeepSeek) | 23 692 octets | réussi |
| Adaptateurs présents | 5 fichiers | opencode, harness-dsh, codex, claude-code, generic | réussi |
| UTF-8 / accents des adaptateurs | français correct | 77 lignes accentuées, fichiers UTF-8 | réussi |
| Structure du dépôt | dossiers prévus | integrations, templates, tools, validation, .github | réussi |

- **Reproduction des contrôles** : `Get-Item NOYAU.md | Select Length` ;
  comparaison de tailles avec les sources v1.4 locales.
- **Limites** : contrôles documentaires uniquement. Les scénarios de
  `VALIDATION_SCENARIOS.md` (SM-01…SM-07) sont préparés mais **non exécutés** ;
  le chargement du noyau en session réelle, le scénario fresh eyes et
  l'installation par outil ne sont pas démontrés. Aucune publication GitHub,
  aucune release. La candidate n'est pas une version validée.
- **Prochaine action** : commits locaux, publication GitHub, puis exécution
  des scénarios (SM-01 d'abord) avant de déclarer v1.0.0 stable.
