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

## 2026-09-23 — Sécurité : règles ajoutées au protocole

- **Demande explicite** : intégrer les règles de sécurité manquantes (aucun
  secret, chemin personnel ou donnée sensible dans un dépôt public ; audit
  avant publication).
- **Contrôles exécutés** :

| Contrôle | Attendu | Observé | Statut |
|---|---|---|---|
| Noyau après ajout (bloc 9) | ≤ 3 072 octets | 3 004 octets | réussi |
| Référence | section dédiée | §8 « Sécurité et secrets », 15 sections | réussi |
| `pre-push-audit.ps1` | détecte les motifs, exit 1 si trouvés | auto-test : faux positif sur ci.yml identifié, corrigé (exclusion des fichiers de vocabulaire), re-test sans motif, exit 0 | réussi |
| Scan de secrets CI | étape ajoutée | « Scan de secrets » dans ci.yml | réussi |
| Skill `protocole-maitre` | alignée sur le noyau | bloc 9 enrichi identique | réussi |

- **Limites** : l'audit local exclut les deux fichiers de vocabulaire
  (pre-push-audit.ps1, ci.yml) ; la CI distante, elle, les couvre.
- **Prochaine action** : publication des changements (commit + push + CI).

## 2026-09-23 — SM-07 : installation et vérification (exécuté)

- **Environnement** : Windows PowerShell 5.1, `install-check.ps1` à HEAD,
  noyau v1.0, 2026-09-23.
- **État testé** : dépôt local, `NOYAU.md` comme cible de référence.

| Cas | Attendu | Observé | Statut |
|---|---|---|---|
| a. Cible conforme | exit 0 | exit 0, rapport JSON | réussi |
| b. Cible tronquée | exit 1 | exit 1 « absent ou tronqué » | réussi |
| c. Doublon | exit 1 | exit 1 « doublon » | réussi |
| d. Source > 3 Ko | exit 1 | exit 1 « règle ≤ 3 Ko violée » | réussi |

- **Défaut trouvé et corrigé** : premier passage du cas a échoué —
  `$PSScriptRoot` est vide dans la valeur par défaut d'un paramètre quand le
  script est lancé via `powershell.exe -File`. Correction : la source par
  défaut est calculée dans le corps du script. Les quatre cas ont été
  re-exécutés après correction.
- **Limites** : SM-01…SM-06 toujours non exécutés (nécessitent des sessions
  réelles).

## 2026-09-23 — Cohérence documentaire (audit des renvois)

- **Contrôles** : tous les renvois numériques (sections, blocs, scénarios)
  vérifiés après l'insertion de la section Sécurité.
- **Écarts trouvés et corrigés** : 2 renvois périmés dans `CHANGELOG.md`
  (« déviation consignée (section 8) » → section 9 ; bullet « Divergences »
  avec ancienne numérotation). Renvois vérifiés corrects par ailleurs :
  `PROTOCOLE.md` (§9, §12), `generic.md` (§12), `opencode.md` (SM-01).
- **Ajout** : prompts d'essai exacts dans `VALIDATION_SCENARIOS.md` pour
  SM-01…SM-06, et statut de SM-07 renseigné.
- **Statut** : réussi après correction.
- **Limites** : contrôle documentaire ; pas de validation comportementale.

## 2026-09-23 — Outil pilote : opencode → DeepSeek Harness

- **Fait constaté** : l'auteur n'utilise plus opencode au quotidien ; le
  pilote actuel est DeepSeek Harness.
- **Conséquences documentaires** : adaptateur opencode marqué « historique,
  maintenu pour compatibilité » ; adaptateur harness-dsh marqué « pilote
  quotidien » ; périmètre de test du design et roadmap alignés ; aucune
  installation globale opencode effectuée (sans objet).
- **Statut** : réussi (aucune bascule de config nécessaire).
- **Limites** : SM-01…SM-06 toujours non exécutés.

## 2026-09-23 — Fresh eyes documentaire + SM-01 isolé

- **Demande explicite** : vérifier que le dépôt est reprenable par un tiers
  vierge, et tester le comportement du noyau dans un contexte sans historique.
- **Fresh eyes (agent vierge, lecture des fichiers seuls)** : 5/5 points
  restitués (état réel, validé vs écrit, prochaine action, décisions D1-D13,
  blocages). **3 écarts trouvés et corrigés** : taille du noyau périmée dans
  `ROADMAP.md` (2 904 → 3 004 octets), « D1-D12 » → « D1-D13 », DESIGN
  promettant un `.bat` et `validation/evidence/` absents → créés
  (`tools/show-context.bat`, `.gitkeep`). Statut : réussi après correction.
- **SM-01 (essai isolé, contexte vierge + skill chargée)** : l'agent a
  constaté l'absence du maître, a refusé de modifier le fichier demandé, a
  proposé la création du maître et consigné les critères de réussite —
  **aucun fichier écrit**. Statut : réussi (approximation : agent de test
  isolé, pas une session utilisateur réelle).
- **CI re-vérifiée après réécriture d'historique** : runs success sur tous
  les push post-réécriture (sécurité, cohérence, outil pilote).
- **Limites** : SM-01 en session réelle, SM-02 sur un projet utilisateur et
  SM-03…SM-06 restent non exécutés.

## 2026-09-23 — Auto-chargement DSH natif + contrat d'intégration déléguée

- **Demande explicite** : le protocole doit se charger automatiquement dans
  DeepSeek Harness, et le dépôt doit permettre à tout agent (Codex, Claude
  Code, autre) d'intégrer le protocole seul, sans aide.
- **Découverte vérifiée dans le harnais** : paquet natif
  `@deepseek-ai/dsh-agent-instructions` — injecte au premier message de chaque
  session le fichier global `$DSH_HOME/AGENTS.md` (budget 65 536 octets par
  défaut), puis la chaîne projet `AGENTS.md`/`CLAUDE.md` (+ surcouches
  `.local.md`). Le mécanisme natif rend un plugin inutile.
- **Actions** : `$DSH_HOME/AGENTS.md` écrit avec l'intégralité de `NOYAU.md` ;
  skill `protocole-maitre` convertie en pointeur vers la référence ;
  adaptateur `harness-dsh.md` réécrit avec les surfaces vérifiées ; README
  enrichi d'un contrat d'intégration déléguée en 7 étapes + validation.
- **Contrôles** : `install-check.ps1` sur le fichier global → conforme
  (intégrité, 1 occurrence, version v1.0).
- **Chargement observé** : après l'écriture du fichier global, le harnais l'a
  injecté dans la session courante (instructions de session visibles dans le
  prompt système) — l'auto-chargement est vérifié en conditions réelles.
- **Limites** : l'exécution comportementale SM-01 en session neuve reste à
  faire ; l'intégration dans les autres outils reste à exécuter par eux-mêmes
  via le contrat du README.

## 2026-09-23 — SM-01 exécuté en session réelle (utilisateur)

- **Environnement** : DeepSeek Harness, session neuve sur le projet d'essai,
  noyau v1.0 chargé automatiquement (`$DSH_HOME/AGENTS.md`), 2026-09-23.
- **Déroulement** : demande « modifie donnees.txt et ajoute la date
  d'aujourd'hui ».

| Comportement attendu | Observé | Statut |
|---|---|---|
| Lire le fichier réel avant modification | fait (3 lignes lues) | réussi |
| Point d'état en 3 lignes | fait | réussi |
| Trois états renseignés (repo / prod / validation) | fait | réussi |
| Écarts consignés (pas de git, pas de maître) | fait | réussi |
| Proposer la création du maître AVANT d'agir | non — modification faite, maître proposé seulement après | échoué |

- **Cause identifiée** : le noyau v1.0 écrivait « le créer avant le chantier
  (sauf délégation explicite) » — ambiguïté exploitée : la demande précise a
  été traitée comme délégation.
- **Correction** : bloc 3 clarifié — « proposer de le créer avant le chantier
  — une demande précise n'en délègue pas la création — et le faire valider ».
  Noyau recalculé (≤ 3 Ko), fichier global resynchronisé, `install-check.ps1`
  re-exécuté sur les deux.
- **Prochaine action** : re-tester SM-01 en session neuve.

## 2026-09-23 — SM-01 : 2e exécution réelle (échec, cause distincte)

- **Environnement** : DeepSeek Harness, session neuve, noyau v1.0 chargé
  automatiquement, 2026-09-23.
- **Observé** : même demande que la 1re exécution. L'agent a modifié
  `donnees.txt` directement, **sans proposer le maître avant**. Il a bien
  consigné une « déviation » — mais en la justifiant par le README du dossier
  d'essai (qui mentionnait l'absence volontaire du maître), pas par un refus
  explicite de l'utilisateur. Comportements réussis par ailleurs : lecture
  avant écriture, point d'état, trois états, note sur le format de date.
- **Causes identifiées** : (1) la fixture de test était auto-référentielle —
  son README expliquait le test, offrant une dispense à l'agent ; corrigée en
  README normal. (2) La règle restait interprétable comme une formalité :
  noyau bloc 3 renforcé (« STOP — proposer et attendre la validation ») et
  référence section 3 complétée (« ni une demande précise ni un document du
  projet ne dispensent de la proposition »).
- **Prochaine action** : 3e essai SM-01 en session neuve.

## 2026-09-23 — SM-01 : 3e exécution réelle (réussi)

- **Environnement** : DeepSeek Harness, session neuve, noyau v1.0 (bloc 3
  renforcé « STOP ») chargé automatiquement, 2026-09-23.
- **Déroulement** : même demande que les essais précédents, fixture assainie.

| Comportement attendu | Observé | Statut |
|---|---|---|
| STOP avant d'agir, proposer le maître | oui — proposition AVANT toute action, arbitrage demandé | réussi |
| Brouillon du maître fondé sur les faits constatés | oui — arborescence, README, contenu réel de donnees.txt, absence de git | réussi |
| Créer maître + roadmap + journal après validation | oui — 3 documents créés | réussi |
| Pas d'écriture superflue (date déjà présente) | oui — fichier laissé tel quel, justifié | réussi |
| Nom de fichier réel respecté (donnees.txt) | oui — aucune invention | réussi |
| Trois états renseignés | oui — repo modifié / prod n.a. / validation réelle | réussi |

- **Statut** : SM-01 réussi (6/6). Historique honnête : 1er essai échoué
  (ambiguïté « délégation »), 2e échoué (fixture auto-référentielle), 3e
  réussi après durcissement du noyau et assainissement de la fixture.
- **Prochaine action** : SM-02 (fresh eyes) sur le projet d'essai, puis
  SM-03…SM-06.

## 2026-09-23 — SM-02 : fresh eyes (réussi, 5/5)

- **Environnement** : DeepSeek Harness, session neuve, consigne « ne lis que
  les fichiers du projet », 2026-09-23.
- **Observé** : les 5 points restitués depuis les fichiers seuls — 1. état
  réel : vérifié fichier par fichier, cohérence maître/projet confirmée,
  absence de git re-vérifiée ; 2. validé vs simplement écrit : distinction
  exacte (contrôles de la session, trace du journal, déclaratif non
  re-contrôlé) ; 3. prochaine action : consigner la session, re-valider la
  date ; 4. décisions et raisons : les 2 entrées du maître ; 5. blocages :
  sandbox shell ACL (consigné), aucun blocage projet.
- **Honnêteté observée** : l'agent a dit ne pas pouvoir re-vérifier l'horloge
  (shell bloqué) au lieu de l'affirmer ; aucune modification faite (consigne
  lecture seule respectée).
- **Statut** : réussi (5/5).
- **Prochaine action** : SM-03 (trois états), SM-04 (mise à jour du maître),
  SM-05 (zéro invention), SM-06 (reprise après compaction).

## 2026-09-23 — Observations incidentes des sessions réelles (SM-03)

- **SM-03 (trois états)** : démontré par observation incidente, sans exécution
  dédiée — la session SM-01 a clos avec les trois états (repo modifié /
  prod n.a. / validation réelle) et la session SM-02 de même (repo non
  modifié / prod n.a. / validation = 1 entrée consignée). Statut : démontré ;
  exécution dédiée facultative.
- **SM-04 (vérité à jour dans la même session)** : non démontré à ce jour —
  la session SM-02 (lecture seule) n'a rien modifié, et la consignation
  proposée en fin de session n'a pas été validée. Une session de chantier
  reste nécessaire.
- **SM-05 (zéro invention)** : non exécuté.
- **SM-06 (reprise après compaction)** : non exécuté — déclenchement
  volontaire difficile ; sortie prévue avec la mention « non exécuté »
  documentée (décision utilisateur « aller »).
