# PROTOCOLE MAITRE

> Protocole de travail IA, agnostique, pour qu'un utilisateur reste maître
> de ses projets quand une IA code à sa place.
> Il converge et remplace PROTOCOLE-CLAUDE, PROTOCOLE-CODEX et
> PROTOCOLE-DEEPSEEK — conservés tels quels pour l'historique.

## Le constat

Quand un non-développeur fait travailler une IA sur son projet, le risque
principal n'est pas le mauvais code : c'est que l'IA avance sans laisser de
trace lisible, jusqu'au moment où plus personne ne sait dans quel état est le
projet. Ce protocole transforme ce risque en processus contrôlable.

## Les fichiers du dépôt

| Fichier | Rôle |
|---|---|
| `NOYAU.md` | Les règles communes (≤ 3 Kio), chargées intégralement dans **chaque session**, quel que soit l'outil. Leur priorité porte sur la référence et les adaptateurs, dans les permissions du client. |
| `PROTOCOLE.md` | La référence complète : elle explique et détaille le noyau. Lue à la demande. |
| `integrations/<outil>.md` | L'adaptateur de chaque outil : surfaces d'injection, fonctionnalités, valeurs propres. Aucune règle normative. |
| `tools/install-check.ps1` | Vérificateur d'installation : intégrité, doublons, version, taille. |
| `tools/check-instruction-context.ps1` | Simulation en lecture seule d'une chaîne locale Codex déclarée ; configuration effective et chargement restent à vérifier. |
| `tools/pre-push-audit.ps1` | Audit de publication : détecte secrets et motifs sensibles avant push. |
| `templates/` | Squelettes pour les projets gouvernés. |
| `skills/protocole-maitre/` | Modèle de skill de référence à la demande. |
| `tools/validate.ps1` et `tests/` | Contrôles et tests isolés (PowerShell 7, Node.js 22+, Git). |
| `AUDIT_2026-11-12.md` | Corrections, sources et propositions sur les mécanismes du protocole. |
| `AUDIT_2026-11-25.md` | Révision portable, garanties conservées, migration et limites de validation. |
| `VALIDATION_SCENARIOS.md` | Méthode de validation comportementale (SM-01…SM-12). |
| `VALIDATION_LOG.md` | Ce qui a été réellement vérifié, et les limites. |

## Démarrage rapide (délégué à l'IA)

Dans une session de ton outil, envoie :

> Regarde https://github.com/kinowill/PROTOCOLE-MAITRE et intègre ce protocole
> dans mon outil et mes projets. Préserve mes consignes existantes, propose la création des documents
> factuels manquants et vérifie l'installation.

Précise « installe-le globalement » ou « installe-le globalement et complète
les consignes de ce projet » (hybride recommandé). L'utilisateur n'a rien à
copier ni remplir.

### Contrat d'intégration déléguée (pour l'IA qui intègre)

1. Lire `NOYAU.md` (la loi) et `PROTOCOLE.md` (la référence) depuis une même
   révision identifiée, puis l'adaptateur de l'outil actif
   (`integrations/<outil>.md` — sinon `integrations/generic.md`).
2. Identifier le client actif, sa version, ses surfaces d'injection et ses
   consignes existantes. Vérifier les priorités, budgets et éventuelles
   troncatures avec les moyens propres à ce client. Le fournisseur et le
   modèle ne déterminent pas seuls les fichiers chargés. Préserver leurs réglages.
3. Intégrer l'**intégralité** de `NOYAU.md` dans la surface autorisée :
   globale ou propre au projet selon la demande et les capacités du client.
   Par projet, intégrer la fiche courte (`templates/FICHE_PROJET.md` remplie)
   à une surface reconnue du client, ou en établir le chargement explicite.
   Le seul nom `FICHE_PROJET.md` ne garantit aucun chargement. Garder les
   contrats détaillés liés, accessibles et lus avant l'action concernée.
   Jamais de version courte du noyau ni de doublon créé à la réinstallation.
4. Sauvegarder les fichiers modifiés avant de les toucher ; une réinstallation
   ne crée aucun doublon.
5. Si le maître manque, l'analyse bornée en lecture seule peut avancer.
   Avant une modification, proposer sa création et attendre la validation,
   sauf autorisation explicite déjà acquise. Un refus explicite de créer le
   maître, avec demande de correction maintenue, permet la poursuite dans
   cette portée avec déviation consignée. Un retrait de la demande arrête
   le chantier. Documenter uniquement les faits vérifiés.
6. Vérifier : `tools/install-check.ps1 -Target <fichier injecté>` (intégrité,
   doublons, version, taille), puis les cas SM-01 en nouvelle session :
   lecture seule possible, modification sans maître suspendue, accord
   réutilisé, déviation consignée et chargement tronqué signalé.
7. Rendre un bilan : version source, cible, sauvegardes, changements, contrôles
   passés, chargement observé, limites. Si le chargement en nouvelle session
   n'a pas pu être observé, le dire : « installation vérifiée, chargement en
   nouvelle session non vérifié ». Après le seul vérificateur statique,
   dire « intégrité statique vérifiée, chargement non vérifié ».

### Validation de l'installation

La présence d'un fichier d'instructions ne prouve pas le chargement : le
test SM-01 fournit une observation comportementale limitée (voir `VALIDATION_SCENARIOS.md`). `install-check.ps1`
vérifie un bloc complet de lignes en UTF-8 (seuls BOM UTF-8 et fins de ligne
sont normalisés), les doublons, la version complète et le budget du noyau ;
il affiche les SHA-256 sans chemins personnels. Un résultat `OK_STATIQUE`
ne prouve ni les paramètres actifs du client ni le chargement de ce fichier.

Le principe est commun à tous les clients : distinguer le contenu installé,
les sources effectivement chargées et le comportement observé. Les méthodes
propres à Codex, Claude Code, OpenCode, DSH ou un client API figurent dans
leurs adaptateurs. Le diagnostic Codex est facultatif ; il n'introduit aucun
paramètre Codex dans les règles communes. Voir [son contrat](integrations/codex.md).

## Installation manuelle

1. Choisis ton adaptateur dans `integrations/`.
2. Colle l'intégralité de `NOYAU.md` dans la surface globale ou projet
   que tu as choisie et que ce client charge.
3. Ouvre une session neuve, puis exécute SM-01 dans ses différents cas.
   Observe aussi les sources chargées quand le client les expose.

Vérifier une installation : `tools/install-check.ps1 -Target <fichier>`.

### Mettre à jour une installation existante

Lire noyau, référence et adaptateur depuis la même révision. Sauvegarder
les consignes locales, identifier le bloc de noyau installé et remplacer
ce seul bloc dans la surface active. Préserver les autres décisions et les
réglages du client, des modèles et des fournisseurs. Si le bloc est modifié
ou ambigu, comparer ses différences avant de préparer le remplacement.

Relire le diff, contrôler le nouveau noyau et vérifier une session neuve.
Conserver la sauvegarde et la révision précédente pour un retour arrière
qui préserve aussi les retouches intervenues depuis. La publication d'une
PR ou d'une version ne met à jour aucune installation automatiquement.

## Ce que devient un projet gouverné

```
mon-projet/
├── DOCUMENT_MAITRE.md    ← REPRISE (10 lignes) + DÉCISIONS + ENVIRONNEMENT
├── ROADMAP.md            ← fait / en cours / à faire / bloqué
├── VALIDATION_LOG.md     ← une entrée par validation réelle
├── FICHE_PROJET.md       ← fiche courte à raccorder aux consignes du client
└── code + .git           ← l'état du dépôt
```

La cible déployée et la méthode qui permet d'observer sa version sont
référencées séparément dans le maître.

Un repreneur — humain ou IA — retrouve, en lisant ces fichiers seuls :
l'état réel, ce qui est validé vs simplement écrit, la prochaine action,
les décisions et pourquoi, les blocages. C'est le critère « fresh eyes »
(scénario SM-02), critère d'acceptation n°1 du protocole.

## État du dépôt

Édition 1.2.0 proposée le 25/11/2026, noyau v1.1.0. Cette contribution
prolonge la PR #1 et conserve ses ajouts sur la délégation et le bilan.
Les versions installées gardent leur révision jusqu'à une mise à jour
autorisée. Publication, installation, tests des scripts et comportement
des modèles sont distincts : consulter `VALIDATION_LOG.md` et les scénarios
SM-01 à SM-12 avant de revendiquer une validation.

## OpenCode 2 et vérification locale

Le [parcours natif](integrations/opencode.md) utilise `AGENTS.md`, une référence
en skill à la demande et les permissions V2. Les fournisseurs et modèles restent
indépendants du protocole. Utiliser une révision Git identifiée et consulter le
journal pour connaître sa validation ; des modifications locales non publiées
ne sont pas accessibles depuis le lien GitHub.

Depuis un checkout Git du dépôt :

```powershell
pwsh -NoProfile -File tools/validate.ps1
node tests/tools.test.mjs
node tests/context.test.mjs
node tests/validate.test.mjs
node --test tests/instruction-context.test.mjs
pwsh -NoProfile -File tools/pre-push-audit.ps1
```

Le scanner détecte des motifs connus sans afficher leurs valeurs. Il couvre
l'index et la copie de travail suivie, pas tout secret possible ni l'historique,
les sous-modules ou les fichiers non suivis. Auditer les nouveaux fichiers dans
un instantané Git isolé avant publication. La CI prévue Windows/Linux ne vaut
pas une exécution distante réussie. Les tests isolés ne valident aucun modèle IA.

Le scanner refuse aussi les index en conflit ou marqués `assume-unchanged` /
`skip-worktree` : ces options peuvent cacher la copie de travail à Git. Il ne
modifie pas ces indicateurs à la place de l'utilisateur. Le validateur inclut
les nouveaux fichiers non ignorés et exclut les données locales ignorées.

## Licence

Usage libre, personnel ou commercial. Pas de garantie. Améliorer et
redistribuer encouragé.
