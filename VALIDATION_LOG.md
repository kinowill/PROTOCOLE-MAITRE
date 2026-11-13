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

## 2026-11-12 - Correction publiée et validation distante réussie

- **Révision vérifiée** : `53d49435d3e098d94dc58e5ca4f28cc57c4d3b70`,
  correctif des fichiers cachés publié sur `main`.
- **Preuve distante** : [run 43247447483](https://github.com/kinowill/PROTOCOLE-MAITRE/actions/runs/43247447483),
  terminé avec succès sur Windows et Ubuntu. Chaque plateforme a exécuté les
  contrôles structure/UTF-8/syntaxe, les 43 contrôles outils, les 5 contrôles de
  suivi OpenCode et les 6 contrôles de validation/checkout, ainsi que le scanner.
  Aucun de ces contrôles n'a été ignoré. Le premier échec Linux reste documenté
  dans l'entrée précédente ; il ne décrit plus la révision publiée actuelle.
- **Alignement constaté** : copie de travail propre ; `HEAD` et `origin/main`
  identiques à cette révision. La clôture documentaire consigne ces preuves
  dans un commit distinct, sans modification fonctionnelle.
- **Trois états** : dépôt corrigé et publié ; GitHub aligné, installation globale
  utilisateur non effectuée ; validations automatisées Windows/Linux réussies.
- **Limites conservées** : pas de session réelle Entrim, DeepSeek ou OpenCode
  Free, ni de validation comportementale du chargement, des permissions ou de
  la reprise après compaction. Aucun fournisseur reconfiguré. Le noyau demeure
  inchangé ; sa révision méthodologique reste à arbitrer dans la roadmap.

## 2026-11-12 - Actualisation des actions CI

- **Observation** : la clôture documentaire `d5ebad0` a aussi passé les deux jobs
  ([run 43248092610](https://github.com/kinowill/PROTOCOLE-MAITRE/actions/runs/43248092610)).
  Une annotation GitHub signalait toutefois le moteur Node 20 obsolète des actions v4.
- **Résultat attendu et préservation** : supprimer cette dépendance obsolète sans
  retirer de test, changer la matrice ni augmenter les droits de la CI.
- **Vérification officielle** : notes de version, `action.yml` et exigences de
  migration consultés pour [checkout 7.0.1](https://github.com/actions/checkout/releases/tag/v7.0.1)
  et [setup-node 7.1.0](https://github.com/actions/setup-node/releases/tag/v7.1.0).
  Les deux utilisent Node 24 et sont épinglées à leurs commits vérifiés.
  Les changements de déclencheurs PR privilégiés et d'authentification de registre
  ne concernent pas ce workflow (`push`/`pull_request`, aucun registre configuré).
- **Changements** : credentials Git non persistés après checkout, cache automatique
  désactivé (aucune dépendance à installer). Permissions `contents: read`
  conservées ; Node 22 reste la version utilisée par les tests du projet.
- **Validation observée** : contrôles locaux de structure et audit avant
  publication réussis ; révision technique `02706f4924955189f57578bc99074c02a9bd1286`
  publiée et [run 43248575181](https://github.com/kinowill/PROTOCOLE-MAITRE/actions/runs/43248575181)
  réussi sur Windows et Ubuntu, toutes les étapes exécutées. L'annotation
  Node 20 obsolète a disparu. L'information générale de migration du label
  `ubuntu-latest` vers Ubuntu 26 ne signale pas un échec du dépôt.
- **État de clôture** : code publié et validations des outils réussies sur les
  deux systèmes ; ce journal consigne la preuve de la révision technique dans
  un commit documentaire séparé. Installations utilisateur et essais réels des
  modèles restent non effectués, comme indiqué dans la roadmap.

## 2026-11-12 - Retrait de la release obsolète demandé

- **Autorisation et attendu** : l'utilisateur demande de retirer la release
  ancienne plutôt que d'en publier une nouvelle ; conserver le code courant.
- **Action et preuve** : release GitHub `v1.0.0` du 23 septembre supprimée ;
  `gh release list` renvoie une liste vide après suppression. Aucune nouvelle
  release créée. Le tag historique `v1.0.0` est conservé et vérifié via l'API.
- **Trois états** : code courant inchangé sur `main` (`d3f394a` avant cette trace),
  page Releases sans publication ; CI Windows/Linux de cette révision réussie
  ([run 43248849949](https://github.com/kinowill/PROTOCOLE-MAITRE/actions/runs/43248849949)).
  Installation globale et validations comportementales des modèles non effectuées.

## 2026-11-13 — Délégation vérifiable entre outils

- **Attendu** : scénario commun de traitement direct, délégation et repli,
  puis vérification du modèle effectivement lancé avec les traces de l'outil.
- **À préserver** : noyau et référence inchangés, périmètre de lecture seule,
  réglages utilisateur préservés. La dérogation déjà consignée pour ce dépôt
  s'applique à la préparation de la contribution.
- **Contrôles prévus** : résultats attendus et intégrité des données fictives,
  traces des sessions, validation du dépôt et audit du diff.
- **Codex CLI 0.167.2 sur Windows** : l'exécuteur Windows n'a pas démarré
  pour lire les fichiers en mode lecture seule. Le second essai de lecture
  a rencontré la même erreur. La variante avec le contenu dans la demande
  a répondu EUR sans lancement, puis retrouvé les six constats en délégation
  et en repli. La réponse directe a cité la ligne par son contenu.
- **Routage observé** : sessions neuves avec surcharges temporaires,
  principal `gpt-6.1-sol/high`, deux enfants `gpt-6-luna/high` dans le cas
  de délégation et zéro dans les deux autres. Deux appels de lancement et
  les contextes des enfants ont été lus dans les journaux locaux. Les appels
  n'imposaient aucun modèle ni effort. Chaque enfant a terminé avec les
  références de son lot. Empreintes des lots identiques avant et après.
  Lecture directe depuis Codex, délégation spontanée et économies sur tâches
  réelles restent à vérifier.
- **OpenCode 1.19.5 et Ollama 0.40.15 sous Windows** : principal et deux
  enfants séquentiels en `ollama-local/qwen3.8-opencode:latest`, avec un
  rôle temporaire propre au dossier d'essai. Les deux exports enfants
  montrent le fournisseur et le modèle attendus, une fin normale et aucune
  erreur. Chaque enfant restitue uniquement son lot. Le principal lit les
  deux fichiers et retrouve les six constats avec les bons numéros de ligne.
  Les empreintes correspondent avant et après. Le serveur temporaire a été
  arrêté après le test. Ce test couvre la délégation locale dans OpenCode.
  Les cas direct et repli dans OpenCode, le mélange de fournisseurs dans une
  même session et la surface ChatGPT Work n'ont pas été testés.
- **Contrôles du dépôt** : structure, UTF-8, syntaxe, budget du noyau et audit
  des fichiers suivis réussis. Suites outils (43), contexte (5) et validation
  (6) réussies sur Windows. Aucun changement du noyau ou de la référence.
- **État** : branche locale de contribution et essais ciblés réalisés.
  Publication et CI distante de la branche à faire. Réglages globaux des
  outils et fournisseurs préservés.

## 2026-11-13 — Pertinence de la délégation

- **Attendu** : vérifier que la décision de déléguer et les choix de modèles
  sont adaptés à la demande, aux capacités de l'outil et aux accès autorisés.
  Les réglages du principal relèvent du choix de l'utilisateur. Les profils
  des essais précédents constituent des observations ponctuelles.
- **Contrôles prévus** : relire le scénario dans les cas de modèle choisi,
  hérité ou imposé par l'outil, puis exécuter les contrôles documentaires
  et l'audit du dépôt.
- **Révision** : critères communs ajoutés à la référence et à SM-12.
  Le scénario couvre aussi le choix sur une demande ordinaire. L'exemple
  de commande à profil fixe a été retiré de l'adaptateur Codex. Le noyau
  et les preuves des essais précédents sont préservés.
- **Contrôles locaux** : cohérence des cas, intégrité du noyau, structure,
  UTF-8, syntaxe, audit des fichiers suivis et six contrôles de validation
  réussis sous Windows.
- **État** : documentation révisée sur la branche locale. Validation sur
  des demandes ordinaires et CI distante à faire. Les réglages de session
  et d'installation utilisateur n'ont pas été modifiés.

## 2026-11-13 — SM-12 sur une demande de rapprochement ordinaire

- **Attendu** : traiter deux lots indépendants de rapprochement catalogue
  avec les réglages de session habituels. Observer la décision prise et
  vérifier toutes les lignes à partir d'un corrigé établi avant le lancement.
- **À préserver** : références, prix et données d'essai fictifs, lecture seule,
  demande métier sans consigne de délégation et paramètres du principal
  laissés à la configuration utilisateur.
- **Contrôles prévus** : références couvertes, verdicts, motifs, preuves et
  empreintes des données. Si des agents sont lancés, vérifier leurs missions,
  les modèles observables et les résultats remis.
- **Périmètre réel** : deux lots fictifs inspirés de cas catalogue, 24
  références internes et 30 lignes fournisseur. Le premier lancement a été arrêté
  après des échecs répétés de l'exécuteur Windows en lecture seule. Les lots
  et les documents de cadrage ont été fournis dans la demande de la session
  suivante. Codex CLI 0.167.2 a utilisé le réglage existant
  `gpt-6.1-sol/xhigh`, sans surcharge de modèle ni d'effort.
- **Demande initiale** : aucun sous-agent ni appel d'outil dans la session
  achevée. 24 références couvertes, 23 verdicts corrects. Le cas B06 a été
  confirmé à tort sur un code commun alors que la source fournisseur
  indique V603 et la ligne interne V726. La réponse cite les deux lignes, mais
  attribue le moteur du catalogue interne aux deux sources. Le critère qui
  interdit une liaison sur variante incompatible a échoué. Empreintes identiques.
- **Rejeu** : même réglage dans une nouvelle session, toujours sans
  sous-agent ni appel d'outil. La demande ajoutait les valeurs techniques
  des deux sources pour chaque liaison. La réponse couvre les 24 références,
  mais répète le verdict erroné et la valeur V726 sur BF07. Empreintes
  identiques. La citation et la présentation côte à côte n'ont pas suffi
  à faire respecter ce contrôle dans cet essai.
- **Contrôle indépendant** : une comparaison des champs techniques à code
  égal dans les deux lots retrouve quatre divergences, dont le moteur de
  B06. Cette comparaison repère la divergence sans se prononcer sur les
  autres règles métier, comme l'identification d'un candidat de remplacement.
- **État** : le traitement direct a été observé sur une demande ordinaire
  et sa variante. Le résultat échoue au critère métier dans les deux cas.
  L'essai ne permet pas de conclure à l'intérêt comparé d'une délégation ni
  à un gain de coût. Aucun changement de réglage ni de catalogue. Résultats
  et scénario mis à jour localement, publication et CI distante à faire.

## 2026-11-13 - Bilan de fin de tâche

- **Attendu** : une appréciation brève du travail fondée sur les résultats
  et les contrôles, la prochaine étape logique si elle existe et un
  enseignement général si le travail permet d'en tirer un.
- **À préserver** : les trois états, la concision et l'indépendance de
  l'outil. Contrôles prévus sur la référence, SM-11 et le diff.
- **Contrôles locaux** : structure, syntaxe, budget du noyau et audit des
  fichiers suivis réussis. Le critère de bilan figure dans SM-11.
- **État** : proposition locale. Rejeu comportemental de SM-11 et
  publication à faire.

### Premier rejeu comportemental

- **Conditions** : deux sessions neuves avec Codex CLI 0.167.2 et
  `gpt-6.1-sol/xhigh`. La section Communication, le contexte et les
  exemples fictifs ont été fournis dans le message. Aucun appel d'outil
  par le modèle pendant les deux essais.
- **Cas complet** : cause identifiée et correctif proposé pour accepter
  l'UTF-8 avec ou sans BOM. Le refus d'une colonne inconnue est préservé.
  Le modèle a distingué ses résultats attendus de ses tests non exécutés.
  Les trois exemples ont ensuite été exécutés par le vérificateur et ont
  réussi. La suite d'application et de vérification dans le projet restait
  implicite dans la réponse. Bilan partiellement conforme.
- **Cas ambigu** : effets des options expliqués et question ciblée sur le
  séparateur autorisé. Aucune modification ni autorisation revendiquée.
  La réponse indique l'étape qui débloque le travail.
- **Portée** : comportement observé sur ces deux demandes et cette version.
  Le chargement automatique de la référence et la reproductibilité dans
  d'autres outils restent à vérifier.
