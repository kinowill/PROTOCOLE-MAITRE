# Journal de validation — PROTOCOLE MAITRE

## 2026-09-23 — Création du dépôt (candidate v1.0)

- **Demande explicite** : concevoir et implémenter PROTOCOLE MAITRE,
  convergence agnostique des protocoles CLAUDE/CODEX/DEEPSEEK, dans
  `C:\...\PROTOCOLE MAITRE` puis sur GitHub `kinowill/PROTOCOLE-MAITRE`.
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
  l'installation par outil ne sont pas démontrés. La publication GitHub a été
  effectuée après cette entrée (voir entrées suivantes). La candidate n'est
  pas une version validée.
- **Prochaine action** : commits locaux, publication GitHub, puis exécution
  des scénarios (SM-01 d'abord) avant de déclarer v1.0.0 stable.

## 2026-09-23 — Publication GitHub et contrôles machine

- **Demande explicite** : publier le dépôt sur `github.com/kinowill/PROTOCOLE-MAITRE`.
- **État testé** : `main` local, commits `cc51d8a..b411154` (7 commits typés).
- **Contrôles exécutés** :

| Contrôle | Attendu | Observé | Statut |
|---|---|---|---|
| `install-check.ps1` cible conforme | exit 0, rapport JSON | rapport OK, SHA-256 calculé, noyau v1.0, 1 occurrence | réussi |
| `install-check.ps1` cible tronquée | exit 1, message clair | « absent ou tronqué », exit 1 | réussi |
| Blocs de code Markdown | nombre pair par fichier | tous pairs | réussi |
| UTF-8 de tous les fichiers | décodables | 0 échec | réussi |
| Syntaxe PowerShell (install-check, show_context) | parse sans erreur | 0 erreur | réussi |
| CI GitHub Actions | succès sur push `main` + tag | 2 runs success (9 s) | réussi |
| Push `main` + tag | branche et tag sur GitHub | `main` → origin/main, `v1.0.0-candidate` poussé | réussi |

- **Publication** : repo public `kinowill/PROTOCOLE-MAITRE`, branche `main`,
  tag `v1.0.0-candidate`. Aucune release stable : le tag v1.0.0 attend
  l'exécution des scénarios SM-01…SM-07.
- **Limites** : toujours aucune validation comportementale ; le chargement du
  noyau dans une session réelle n'est pas démontré.
- **Prochaine action** : exécuter SM-01 (chargement du noyau) dans opencode et
  DeepSeek Harness, puis SM-02 (fresh eyes).

## 2026-09-23 — Hygiène de publication

- **Demande explicite** : aucun chemin personnel ni donnée sensible sur le
  dépôt public.
- **Contrôles exécutés** : grep des motifs sensibles (emails, tokens, clés)
  sur les fichiers suivis → 0 occurrence réelle ; chemins locaux
  remplacés par des formes génériques ; licence attribuée à `kinowill` ;
  historique réécrit avec l'email `kinowill@users.noreply.github.com` ;
  `install-check.ps1` utilise une source par défaut relative à `$PSScriptRoot`
  au lieu d'un chemin absolu.
- **Statut** : réussi (audit re-exécuté après modifications : aucun motif).
- **Limites** : `main` et le tag `v1.0.0-candidate` re-poussés après
  réécriture ; CI à re-vérifier sur les nouveaux commits.
