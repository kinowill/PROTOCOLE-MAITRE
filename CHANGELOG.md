# Changelog — PROTOCOLE MAITRE

## v1.2.0 proposée (2026-11-25)

- Noyau v1.1.0 : démarrage proportionné, analyse seule possible sans maître,
  reprise des autorisations dans leur portée et distinction exigences / faits
  déployés / droits effectifs. Les modifications sans maître gardent leur
  préalable ou la déviation explicite, et les effets hors portée leur accord.
- Référence organisée par besoin ; carte du projet et contrats détaillés liés,
  historiques datés distincts des règles actives et lectures utiles réutilisables.
- Conservation des ajouts de la PR #1 sur délégation, repli et bilan.
- Contrôles d'intégrité UTF-8 sur octets et lignes complètes ; noyau non vide,
  version complète et sections attendues. Avertissement lexical des adaptateurs
  distinct de la revue normative, sans bloquer une citation des permissions.
- Diagnostic statique facultatif de chaîne Codex déclarée, sans lecture de
  secrets ou modification du client ; paramètres et chargement non attestés
  restent explicitement inconnus. Méthode commune dans tous les adaptateurs.
- Adaptateurs revus sur les sources officielles au 25/11/2026, indépendamment
  des fournisseurs et modèles. Migration locale documentée, sans mise à jour
  automatique des installations ni garantie comportementale multi-modèle.
- Scénarios SM-01, SM-09 et SM-11 couvrant aussi les faux arrêts et les refus ;
  SM-12 conservé. Résultats réellement exécutés dans `VALIDATION_LOG.md`.

## v1.1.0 (2026-11-12)

- OpenCode 2 : AGENTS natif, skill de référence, permissions/politiques V2,
  conservation des fournisseurs et modèles existants.
- Contexte : CLI native, retrait des traces Claude et de la fenêtre fixe ;
  limites du cache, de la compaction et du warming explicitées.
- Sécurité : scanner index/copie de travail, erreurs bloquantes et sorties
  sans valeurs secrètes ; vérification stricte du noyau et de sa version complète.
- Tests isolés et CI Windows/Linux, scénarios multi-fournisseurs distincts.
- CI : actions officielles checkout 7.0.1 et setup-node 7.1.0 sur moteur Node 24,
  sans persistance des credentials Git ni cache automatique de dépendances.
- Audit bloquant sur index partiel, noyau LF stable sous Windows/Linux, validation
  limitée aux fichiers du dépôt et actions CI figées sur des révisions vérifiées.
- Audit de fond documenté ; noyau v1.0.0 conservé, sans refonte normative implicite.
- Installation globale distincte de la publication du dépôt ; configurations utilisateur préservées.

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
