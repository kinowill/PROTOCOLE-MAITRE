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

## 2026-11-12 — Chantier OpenCode 2 : préparation
- Déviation explicitement demandée : poursuivre sans créer de document maître pour ce dépôt.
- Résultat attendu : adaptateur OpenCode 2 et outils de contrôle actualisés, sans modifier les fournisseurs ou les installations utilisateur.
- À préserver : noyau intégral et garde-fous, indépendance des modèles, absence de publication distante.
- Contrôles prévus : tests automatisés des scripts, vérification syntaxique et CI locale, examen du diff ; chargement et comportement réel multi-modèle à distinguer des tests statiques.

## 2026-11-12 — Édition locale 1.1.0, contrôles exécutés

- **État testé** : base `b32cec219c2fcc49e73426385c8287235d304e29` + fichiers locaux
  de cette édition ; contenu conservé dans `PROTOCOLE-MAITRE-1.1.0-local-2026-11-12.zip`
  et manifeste SHA-256 associé. Aucun commit nécessaire à cet instantané.
- **Environnement** : Windows, PowerShell 7.6.9, Node.js 22.22.2,
  Git 2.52.0.windows.1 ; binaire OpenCode 2.2.7 pour aide/version uniquement.
- **Attendu** : préserver les garde-fous et les fournisseurs, corriger les outils,
  rendre l'installation V2 reproductible, documenter les limites sans succès simulé.
- **Contrôles exécutés et réussis** :
  - `node tests/tools.test.mjs` : 39/39 (secrets factices, index/copie de travail,
    binaires, sous-dossier, erreurs bloquantes, version complète, intégrité,
    doublons, encodages/fins de ligne, absence de divulgation de valeurs/chemins).
  - `node tests/context.test.mjs` : 5/5 (arguments natifs des trois modes,
    propagation d'échec CLI, outil absent ; aucune mesure de contexte inventée).
  - `pwsh -NoProfile -File tools/validate.ps1` : budget noyau, sections,
    cinq adaptateurs, UTF-8, syntaxe PowerShell et JavaScript.
  - `pwsh -NoProfile -File tools/pre-push-audit.ps1` : index et copie suivie,
    aucun motif détecté ; contrôle heuristique, pas certification de sécurité.
  - `git diff --check` : réussi ; noyau inchangé, 3051 octets (< 3072).
  - `opencode --version`, `stats --help`, `session list --help`,
    `debug paths --help` : réussis dans un profil XDG isolé. Options documentées
    confirmées ; aucune requête modèle ni lecture de credentials nécessaire.
- **Seconde passe** : lecture approfondie croisée, contradictions corrigées et
  exemple de permission trop large retiré ; détails dans l'audit daté.
- **Limites** : SM-01 à SM-06 et SM-08 à SM-11 non exécutés avec les fournisseurs ;
  SM-07 couvert par les tests de scripts. Chargement réel, permissions effectives,
  reprise multi-modèles, coûts et performances des agents non démontrés.
  CI distante et exécution Linux non effectuées ; matrice CI préparée seulement.
- **Trois états** : dépôt local modifié ; publication distante non alignée et
  installation utilisateur non effectuée ; validations locales ci-dessus réussies,
  validations comportementales restantes explicitement non exécutées.
- **Autorisation** : pas de commit, push, publication, connexion ou modification
  des fournisseurs. Poursuite sans maître demandée et consignée.
- **Prochaine action** : donner ce dossier local à OpenCode pour une intégration
  autorisée et les scénarios réels ; publier seulement après accord explicite.

- **Demandes complémentaires intégrées** : qualité du résultat prioritaire sur
  vitesse de développement, remise reprenable sans conversation, méta de
  communication adaptée au code et questions critiques conservées. Seconde
  lecture croisée des règles et du parcours d'installation, corrections dans
  l'audit. Les scripts testés n'ont pas changé pendant ces ajouts documentaires.

- **Audit complet final** : 28 fichiers, nouveaux fichiers inclus, placés dans un dépôt Git temporaire séparé ; scanner index/copie de travail et motif additionnel de chemin personnel : aucun motif détecté. Archive et manifeste conservés ; index du dépôt de travail non préparé.

## 2026-11-12 - Dernière revue et alignement autorisé

- **Autorisation** : demande utilisateur de dernière passe, corrections et
  alignement propre du dépôt. Publication de la version revue autorisée ; aucune
  installation globale ni modification des fournisseurs demandée.
- **Résultat attendu** : défauts restants corrigés, tests pertinents exécutés,
  commits séparés par objet, dépôt distant aligné et CI observée.
- **À préserver** : noyau intégral, fournisseurs et données utilisateur,
  distinction validation des scripts / comportement réel des modèles.
- **Contrôles prévus** : régressions supplémentaires du scanner, portabilité des
  fins de ligne, relecture des diffs, scan du contenu destiné à la publication,
  puis statut des deux jobs CI à la révision publiée.
- **État initial** : `main` et `origin/main` à `b32cec2`, aucun écart distant après
  fetch ; corrections locales présentes. Les états sans commit/publication des
  entrées précédentes décrivent les contrôles antérieurs à cette autorisation.

- **Résultats locaux finaux observés** : 43/43 contrôles outils, 5/5 contrôles
  suivi OpenCode et 5/5 contrôles de validation/checkout, soit 53 contrôles.
  Commandes : `node tests/tools.test.mjs`, `node tests/context.test.mjs`,
  `node tests/validate.test.mjs`. `tools/validate.ps1` et `git diff --check`
  réussis également. Environnement Windows/PowerShell/Node/Git inchangé.
- **Défauts reproduits puis corrigés** : audit incomplet sous deux indicateurs
  Git, conversion CRLF dépassant le budget et validation de fichiers privés
  ignorés. Régressions ajoutées ; le noyau reste strictement inchangé.
- **Revue des sources** : commandes OpenCode vérifiées au tag `v2.2.7` ; les
  actions CI v4 ont été épinglées à leurs commits officiels vérifiés.
- **État à ce point** : validations locales réussies ; commits/publication et
  CI distante restent à constater. Aucun scénario fournisseur supplémentaire
  n'a été exécuté, ni aucune configuration utilisateur modifiée.

## 2026-11-12 - Échec Linux observé et correction

- **Révision publiée** : `34605f3`, après les commits séparés `3c6a53e`,
  `2a98668` et `87654bc`. Publication effectuée, état local/distant aligné.
- **Résultat CI réel** : [run 43246782140](https://github.com/kinowill/PROTOCOLE-MAITRE/actions/runs/43246782140)
  échoué sur Ubuntu, réussi sur Windows. Ubuntu ne dépassait pas le contrôle
  statique : `Get-Item` sans `-Force` ne retrouvait pas `.gitattributes`, caché
  sur Linux. Les tests suivants étaient ignorés ; aucun succès Linux n'est revendiqué.
- **Reproduction** : nouveau test avec métadonnée cachée, échec local observé
  avant correction. Ajout de `-Force` uniquement à la lecture des fichiers
  appartenant à l'inventaire Git. Aucun fichier n'est exclu pour contourner le défaut.
- **Après correction** : les 6 contrôles de validation/checkout réussissent,
  dont lecture d'une métadonnée cachée et rejet d'un fichier caché UTF-8 invalide.
  Syntaxe, périmètre et `git diff --check` réussis. Les suites outils (43) et
  contexte (5) sont inchangées et seront aussi rejouées par la CI.
- **État** : correctif local validé sur Windows ; publication du correctif et
  nouveau résultat CI Linux/Windows à constater avant clôture.
