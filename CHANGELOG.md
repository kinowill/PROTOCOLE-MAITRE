# Changelog — PROTOCOLE MAITRE

## v1.0.0-candidate (2026-09-23)

**Convergence** — un protocole unique remplace trois copies divergentes :
PROTOCOLE-CLAUDE v1.2, PROTOCOLE-CODEX v1.4, PROTOCOLE-DEEPSEEK v1.4
(conservés tels quels).

**Noyau** — `NOYAU.md` : 10 blocs de règles non négociables, 3 004 octets
(≤ 3 Ko), chargé dans chaque session, tout outil. Noms de fichiers exacts
et version inclus. Le noyau prime sur la référence.

**Référence** — `PROTOCOLE.md` : 15 sections, 23 692 octets (v1.4 DeepSeek :
32 197). Redondances éliminées (`gh` unique, surfaces d'instructions uniques),
détails d'outil externalisés, contexte/compaction généralisé, section
« Outils et adaptateurs » nouvelle, déviation consignée ajoutée (section 9).

**Adaptateurs** — opencode, DeepSeek Harness, Codex CLI, Claude Code,
générique. Contenu : surfaces d'injection, fonctionnalités, valeurs propres,
limites. Aucune règle normative (contrôlé par CI).

**Reprise** — blocs REPRISE / DÉCISIONS / ENVIRONNEMENT dans les templates
projet ; scénario « fresh eyes » (SM-02) = critère d'acceptation n°1.

**Vérification** — `tools/install-check.ps1` (intégrité SHA-256, doublons,
version, garde-fou 3 Ko) ; CI GitHub Actions (taille du noyau, sections,
grep anti-règles dans les adaptateurs, présence des adaptateurs).

**Sécurité** — section 8 dédiée dans la référence, bloc 9 du noyau enrichi,
`tools/pre-push-audit.ps1` (audit avant publication), scan de secrets dans
la CI. Ajouté après l'incident « chemins personnels sur dépôt public ».

**SM-01 réel** — 3 exécutions réelles (2026-09-23) : 1re échec (ambiguïté
« délégation »), 2e échec (fixture auto-référentielle), 3e **réussi 6/6**
après durcissement du noyau (bloc 3 « STOP — proposer et attendre la
validation ») et assainissement de la fixture.

**Divergences assumées vs PROTOCOLE-CODEX v1.4** — sections 12-13
généralisées ; « Outils et adaptateurs » remplace l'ancienne section 13 ;
déviation consignée ajoutée ; `gh` dédupliqué. Alignement souple, documenté
ici.
