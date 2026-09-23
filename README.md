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
| `NOYAU.md` | Les règles non négociables (≤ 3 Ko), chargées dans **chaque session**, quel que soit l'outil. En cas de conflit, le noyau gagne. |
| `PROTOCOLE.md` | La référence complète : elle explique et détaille le noyau. Lue à la demande. |
| `integrations/<outil>.md` | L'adaptateur de chaque outil : surfaces d'injection, fonctionnalités, valeurs propres. Aucune règle normative. |
| `tools/install-check.ps1` | Vérificateur d'installation : intégrité, doublons, version, taille. |
| `tools/pre-push-audit.ps1` | Audit de publication : détecte secrets et motifs sensibles avant push. |
| `templates/` | Squelettes pour les projets gouvernés. |
| `VALIDATION_SCENARIOS.md` | Méthode de validation comportementale (SM-01…SM-07). |
| `VALIDATION_LOG.md` | Ce qui a été réellement vérifié, et les limites. |

## Démarrage rapide (délégué à l'IA)

Dans une session de ton outil, envoie :

> Regarde https://github.com/kinowill/PROTOCOLE-MAITRE et intègre ce protocole
> dans mon outil et mes projets. Préserve mes consignes existantes, crée la
> documentation factuelle manquante et vérifie l'installation.

Précise « installe-le globalement » ou « installe-le globalement et complète
les consignes de ce projet » (hybride recommandé). L'utilisateur n'a rien à
copier ni remplir.

### Contrat d'intégration déléguée (pour l'IA qui intègre)

1. Lire `NOYAU.md` (la loi) et `PROTOCOLE.md` (la référence) depuis une même
   révision identifiée, puis l'adaptateur de l'outil actif
   (`integrations/<outil>.md` — sinon `integrations/generic.md`).
2. Identifier l'outil cible, ses surfaces d'injection (fichier global
   d'instructions, config, skill) et ses consignes existantes — les préserver.
3. Intégrer l'**intégralité** de `NOYAU.md` dans la surface globale de l'outil.
   Par projet, ajouter la fiche projet (`templates/FICHE_PROJET.md` remplie).
   Jamais de version courte du noyau.
4. Sauvegarder les fichiers modifiés avant de les toucher ; une réinstallation
   ne crée aucun doublon.
5. Créer les documents factuels manquants du projet (maître, roadmap) avec les
   faits vérifiés — sans rien inventer.
6. Vérifier : `tools/install-check.ps1 -Target <fichier injecté>` (intégrité,
   doublons, version, taille), puis le test SM-01 (nouvelle session, projet
   sans maître → proposition de création du maître avant d'agir).
7. Rendre un bilan : version source, cible, sauvegardes, changements, contrôles
   passés, chargement observé, limites. Si le chargement en nouvelle session
   n'a pas pu être observé, le dire : « installation vérifiée, chargement en
   nouvelle session non vérifié ».

### Validation de l'installation

La présence d'un fichier d'instructions ne prouve pas le chargement : seul le
test SM-01 le prouve (voir `VALIDATION_SCENARIOS.md`). `install-check.ps1`
vérifie la conformité statique (intégrité SHA-256, doublons, version, taille).

## Installation manuelle

1. Choisis ton adaptateur dans `integrations/`.
2. Colle l'intégralité de `NOYAU.md` dans la surface globale de ton outil.
3. Relance l'outil, puis teste : dans un projet sans `DOCUMENT_MAITRE.md`,
   l'IA doit proposer de créer le maître avant d'agir sur ta demande.

Vérifier une installation : `tools/install-check.ps1 -Target <fichier>`.

## Ce que devient un projet gouverné

```
mon-projet/
├── DOCUMENT_MAITRE.md    ← REPRISE (10 lignes) + DÉCISIONS + ENVIRONNEMENT
├── ROADMAP.md            ← fait / en cours / à faire / bloqué
├── VALIDATION_LOG.md     ← une entrée par validation réelle
├── FICHE_PROJET.md       ← spécificités locales uniquement
└── code + .git           ← la vérité runtime
```

Un repreneur — humain ou IA — retrouve, en lisant ces fichiers seuls :
l'état réel, ce qui est validé vs simplement écrit, la prochaine action,
les décisions et pourquoi, les blocages. C'est le critère « fresh eyes »
(scénario SM-02), critère d'acceptation n°1 du protocole.

## État du dépôt

Version candidate v1.0. Chaque intégration est vérifiée par l'intégrateur
selon la méthode `VALIDATION_SCENARIOS.md` (SM-01…SM-07) et le contrat
d'intégration ci-dessus.

## Licence

Usage libre, personnel ou commercial. Pas de garantie. Améliorer et
redistribuer encouragé.
