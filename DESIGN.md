# PROTOCOLE MAITRE — Design validé

> Document de design consolidé. Source : sessions de conception avec l'auteur.
> Ce document est le contrat avant implémentation. Toute évolution le met à jour.

---

## 1. Compréhension

**Ce qui est construit :** un protocole de travail IA unique et **agnostique**,
« PROTOCOLE MAITRE », qui garantit qu'un utilisateur (non-développeur le plus
souvent) reste maître de ses projets quand une IA code à sa place. Il remplace
et converge les trois protocoles existants : PROTOCOLE-CLAUDE (v1.2),
PROTOCOLE-CODEX (v1.4), PROTOCOLE-DEEPSEEK (v1.4).

**Pourquoi :** les trois repos ont divergé (cœurs dupliqués, 13→15 sections),
sont lourds (32 Ko), couplés aux internes d'un outil, et **jamais validés
comportementalement**. Leur valeur réelle est donc incertaine.

**Quatre chantiers :** (1) rigueur du texte, (2) allègement du poids,
(3) adhésion réelle du modèle, (4) distribution et crédibilité.

**Pour qui :** l'auteur d'abord (Windows), puis d'autres non-développeurs.

**Non-objectifs :** pas de serveur ni SaaS ; pas de réécriture du fond des
règles (elles sont bonnes) ; pas de portage Linux/macOS prioritaire.

## 2. Hypothèses

1. Le protocole reste en **français** ; code et commandes en anglais.
2. **Mainteneur unique**, versions semver, CI GitHub Actions.
3. La **validation comportementale est exécutée par l'auteur** dans de vraies
   sessions ; l'IA prépare scénarios, scripts et journaux.
4. Scripts **100 % locaux**, aucune télémétrie, secrets exclus des artefacts.
5. Les chiffres « DeepSeek V4 Pro » sont conservés mais **marqués comme
   spécifiques à l'environnement et vérifiables**.
6. Redondances internes de la v1.4 (`gh`, skills, surfaces d'instructions
   répétées 2-3×) éliminées.
7. **Windows d'abord** pour les scripts ; portage si besoin simple.

## 3. Journal de décisions

| # | Décision | Alternatives | Pourquoi |
|---|---|---|---|
| D1 | Nom : **PROTOCOLE MAITRE**, version agnostique | Garder PROTOCOLE-DEEPSEEK | Convergence des 3 protocoles en un noyau + adaptateurs |
| D2 | **Repos existants intacts** | Les remplacer | Consigné par l'auteur : laisser tels quels |
| D3 | Livraison : `C:\PROJETS\PROTOCOLE MAITRE` + `github.com/kinowill/PROTOCOLE-MAITRE` | — | Consigné par l'auteur |
| D4 | Alignement Codex **souple** | Alignement strict | La convergence justifie les divergences ; documentées |
| D5 | Budget : **noyau ≤ 3 Ko** + couches à la demande | 10-15 Ko unique | Un long prompt système dilue sa propre autorité |
| D6 | Approche **C : couches + vérification** | A (pur doc), B (cœur unique) | Seule approche couvrant les 4 chantiers |
| D7 | Noyau = **10 blocs** + noms de fichiers exacts + ligne de version | — | Le noyau seul doit suffire à agir correctement |
| D8 | Templates projet : blocs **REPRISE**, **DÉCISIONS**, **ENVIRONNEMENT** | Templates v1.4 inchangés | Sans eux, la reprise par un tiers échoue |
| D9 | **Scénario « fresh eyes »** = critère d'acceptation n°1 | — | Mesure directe de la promesse de reprise |
| D10 | **Adaptateurs sans règles normatives** (grep CI) | Adaptateurs libres | Empêche la re-dérive des protocoles par outil |
| D11 | Refus explicite du maître = **déviation consignée** | Forcer la création | L'utilisateur est souverain ; la déviation doit être visible |
| D12 | Chaque validation consigne **l'environnement exact** (outil, modèle, version, date) | — | Deux exécutions doivent être comparables |

## 4. Architecture : 3 couches + couche machine

1. **Noyau (`NOYAU.md`)** — ≤ 3 Ko, chargé dans chaque session, tout outil.
   Les règles dures uniquement. En cas de conflit, **le noyau gagne**.
2. **Référence (`PROTOCOLE.md`)** — canon complet expliquant le noyau,
   lue à la demande. Ne peut jamais contredire le noyau.
3. **Adaptateurs (`integrations/<outil>.md`)** — faits d'outil et méthodes
   d'injection uniquement, aucune règle normative.
4. **Couche machine (`tools/` + CI)** — vérificateur d'installation et
   garde-fous automatisés.

```
PROTOCOLE-MAITRE/
├── NOYAU.md · PROTOCOLE.md · README.md
├── CHANGELOG.md · ROADMAP.md · VALIDATION_LOG.md · VALIDATION_SCENARIOS.md
├── LICENSE
├── integrations/ (opencode, codex, claude-code, harness-dsh, generic)
├── tools/ (install-check.ps1, show_context.ps1, + .bat utilisateur)
├── templates/ (DOCUMENT_MAITRE, ROADMAP, VALIDATION_LOG, fiche projet)
├── validation/evidence/ (instantanés ZIP + SHA-256)
└── .github/workflows/ci.yml
```

## 5. Noyau — contenu (10 blocs)

1. **Rôle** — l'utilisateur est le maître ; l'IA travaille sous son contrôle
   et laisse une trace lisible.
2. **Sources de vérité** — ordre : `DOCUMENT_MAITRE.md` → `ROADMAP.md` →
   `VALIDATION_LOG.md` → code effectivement déployé (qui gagne en cas de conflit).
3. **Début de session** — instructions actives → maître/roadmap/journal →
   `git status` + `git log` (si git) → zone touchée → point d'état 3 lignes.
   Pas de maître ? Le créer avant le chantier, validé par l'utilisateur
   (sauf délégation explicite). Avant modification fonctionnelle : consigner
   résultat attendu, comportements à préserver, contrôles prévus.
4. **Trois états** — repo modifié / prod alignée / validation réelle.
   « Fini » sans les trois renseignés est interdit.
5. **Vérité à jour** — maître/roadmap/journal mis à jour dans la même session,
   sinon l'action n'est pas finie. Git : commits courts et scopés, jamais
   géants ; avant : relire le diff et vérifier si la doc doit changer ; après :
   noter local/poussé, prod alignée ou non, reste-t-il déploiement/migration/retest.
6. **Zéro invention** — jamais inventer fichier, fonction, variable, API, état
   de prod ou validation passée. Toujours lire le fichier réel avant de le
   modifier ou d'en affirmer le contenu. Toute info de mémoire, résumé ou
   recommandation externe : revérifier dans le code avant d'agir.
7. **Décisions** — choix lourds : options + conséquences, puis arbitrage de
   l'utilisateur. Zones sensibles (auth, données, schéma, sécurité) : vérifier
   l'état réel avant modification.
8. **Erreurs** — diagnostiquer avant de re-tenter ; pas d'action destructive
   pour contourner un obstacle ; dans le périmètre autorisé, corriger la cause
   et relancer les contrôles avant de rendre la main ; blocage → diagnostic
   honnête, jamais de succès simulé.
9. **Interdits majeurs** — sauter une étape du début de session ; « fini » non
   validé ; recommandation externe exécutée sans confrontation au projet ;
   remplacer ce protocole par une version courte ; supprimer ou affaiblir un
   contrôle pour obtenir un résultat vert. Le noyau prime sur la référence.
10. **Langue** — répondre dans la langue de l'utilisateur ; code et commandes
    en anglais.

Plus : noms de fichiers exacts et ligne `PROTOCOLE MAITRE vX.Y`.

## 6. Référence — contenu

Préambule + justification · communication · sources de vérité détaillées ·
début de session complet (critères de réussite) · règles d'action ·
trois états + preuves et portée de la validation · mise à jour de la vérité ·
git/commits · décisions (déviation consignée en cas de refus explicite) ·
erreurs + boucle de réalisation · propositions externes · interdits +
intégrité des contrôles · contexte/compaction (agnostique, seuils en %) ·
pourquoi ça tient. Renvois vers les adaptateurs pour tout détail d'outil.

## 7. Adaptateurs

`opencode.md` (pilote quotidien), `harness-dsh.md` (DeepSeek Harness),
`generic.md` (Cline, Cursor, Aider, API directe…), `codex.md` et
`claude-code.md` (fins, pointant vers leurs repos d'origine).

Contenu autorisé : surfaces d'injection, fonctionnalités natives, fenêtres de
contexte, chemins, commandes, limites connues de l'outil. **Interdit** : toute
règle normative (grep CI sur « interdit / obligatoire / non négociable »).

## 8. Projet cible une fois installé

```
mon-projet/
├── DOCUMENT_MAITRE.md    ← bloc REPRISE en tête (10 lignes) + DÉCISIONS + ENVIRONNEMENT
├── ROADMAP.md            ← fait / en cours / à faire / bloqué
├── VALIDATION_LOG.md     ← une entrée par validation réelle
├── FICHE-PROJET (courte) ← stack, commandes, chemins — rien d'autre
├── code réel + .git
```

**Lecture de début de session (ordre fixe, stable pour le cache) :**
instructions actives → maître → roadmap → dernier journal utile →
`git status` + `git log --oneline -20` → fichiers du chantier → point d'état.

**Écriture :** maître mis à jour dans la même session dès qu'une action change
la vérité ; roadmap cochée à chaque chantier ; journal : état testé exact
(commit ou instantané), attendu, observé, statut (`réussi / échoué /
non exécuté / bloqué / n.a.`), limites, prochaine action ; fiche projet
rarement. Git : commits typés, jamais géants.

## 9. Reprise et continuité (critère n°1)

**Test « fresh eyes »** : après 2-3 sessions réelles, une session vierge doit
restituer, en lisant uniquement les fichiers du projet : (1) l'état réel,
(2) validé vs simplement écrit, (3) prochaine action, (4) décisions et
pourquoi, (5) blocages. Réussi = 5/5 sans consulter l'historique de session.

**Limite honnête** : la valeur des logs repose sur l'honnêteté des entrées.
Le protocole la maximise (états explicites, statuts, preuve = commit ou
instantané, succès simulé interdit) mais ne peut pas la garantir absolument.

## 10. Vérification

- `tools/install-check.ps1` : intégrité SHA-256 du bloc installé vs source,
  détection des doublons et versions courtes, taille, rapport de vérification.
- CI GitHub Actions : lint Markdown, structure des sections, **garde-fou
  NOYAU ≤ 3 Ko**, liens, grep anti-règles dans les adaptateurs.
- Scénarios comportementaux exécutés en sessions réelles : fresh eyes (n°1),
  test du maître, trois états, reprise après compaction, installations
  global/projet/hybride. Chaque entrée consigne : outil, modèle, version du
  noyau, date, résultat, preuve.
- Périmètre de test réaliste : opencode (pilote), harness-dsh (actuel),
  generic (fumée). Releases semver avec changelog.

## 11. Risques résiduels

| Risque | Mitigation | Statut |
|---|---|---|
| Noyau trop sec → sous-application | 10 blocs impératifs, test noyau-seul inclus | assumé, testé |
| Dérive noyau ↔ référence | « le noyau gagne » + checklist d'édition | assumé |
| Dérive des adaptateurs | règle « pas de normatif » + grep CI | contrôlé |
| Réécriture de 32 Ko → perte de règles | extraction par déplacement, contrôles diff à la Codex | à exécuter |
| Honnêteté des logs | états/statuts explicites + fresh eyes recroisé | limite assumée |
| Garantie limitée aux outils à fichiers + instructions persistantes | documenté dans generic.md | limite assumée |

## 12. Rollout

1. Créer `C:\PROJETS\PROTOCOLE MAITRE` (noyau, référence, adaptateurs,
   templates, tools, CI).
2. Extraction de la référence depuis v1.4 par déplacement de texte ;
   contrôles diff (à la Codex).
3. Installations locales de test + `install-check.ps1`.
4. Exécution des scénarios en sessions réelles (opencode, harness-dsh, generic)
   avec preuves consignées.
5. Création du repo GitHub `kinowill/PROTOCOLE-MAITRE` + push.
6. Tag `v1.0.0` + release.
7. *(Optionnel, à décider)* : pointeur en tête des README des trois anciens
   repos (« remplacé par PROTOCOLE-MAITRE »).

## 13. Questions ouvertes

- Pointeur dans les anciens repos : oui ou non ? (étape 7)
- GitHub Actions : disponible sur le compte `kinowill` ?
- Autres outils à adapter en priorité (Cursor, Windsurf, Aider…) ?
