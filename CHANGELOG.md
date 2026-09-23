# Changelog — PROTOCOLE MAITRE

## v1.0.0 (2026-09-23)

**Convergence** — un protocole unique remplace trois copies divergentes :
PROTOCOLE-CLAUDE v1.2, PROTOCOLE-CODEX v1.4, PROTOCOLE-DEEPSEEK v1.4
(conservés tels quels).

**Noyau** — `NOYAU.md` : 10 blocs de règles non négociables (≤ 3 Ko), chargé
dans chaque session, tout outil. Sécurité incluse (bloc 9 : secrets, chemins
personnels, audit avant publication). Le noyau prime sur la référence.

**Référence** — `PROTOCOLE.md` : 15 sections, dont « Sécurité et secrets »
(§8). Redondances éliminées, détails d'outil externalisés dans les
adaptateurs.

**Adaptateurs** — opencode, DeepSeek Harness, Codex CLI, Claude Code,
générique. Faits d'outil uniquement : aucune règle normative.

**Templates projet** — document maître (REPRISE / DÉCISIONS /
ENVIRONNEMENT), roadmap, journal de validation, fiche projet.

**Outils** — `install-check.ps1` (intégrité, doublons, version, taille),
`pre-push-audit.ps1` (détection de secrets avant publication),
`show_context.ps1` + `show-context.bat` (monitoring du contexte).

**CI GitHub Actions** — garde-fou noyau ≤ 3 Ko, sections de la référence,
adaptateurs sans règles normatives, scan de secrets.

**Validation** — méthode comportementale SM-01…SM-07 documentée dans
`VALIDATION_SCENARIOS.md`.
