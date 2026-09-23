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
| `VALIDATION_SCENARIOS.md` | Scénarios comportementaux (SM-01…SM-07) à exécuter. |
| `VALIDATION_LOG.md` | Ce qui a été réellement vérifié, et les limites. |

## Démarrage rapide (délégué à l'IA)

Dans une session de ton outil, envoie :

> Regarde https://github.com/kinowill/PROTOCOLE-MAITRE et intègre ce protocole
> dans mon projet. Préserve mes consignes existantes, crée la documentation
> factuelle manquante et vérifie l'installation.

Précise « installe-le globalement » ou « installe-le globalement et complète
les consignes de ce projet » (hybride recommandé). L'IA lit le dépôt, intègre,
vérifie et rend un bilan — sans copier-coller demandé à l'utilisateur.

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

Candidate v1.0. Validation documentaire consignée dans `VALIDATION_LOG.md` ;
scénarios comportementaux préparés, exécution à venir. Aucune release stable
tant que SM-01…SM-07 ne sont pas exécutés.

## Licence

Usage libre, personnel ou commercial. Pas de garantie. Améliorer et
redistribuer encouragé.
