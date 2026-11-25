# Adaptateur — DeepSeek Harness (DSH)

Surfaces revues le 25/11/2026 dans la documentation du paquet officiel.
Les observations d'installation du 23/09/2026 restent historiques. Vérifier
le harnais, sa version et son profil avant d'appliquer les détails ci-dessous.
DeepSeek utilisé via OpenCode suit l'adaptateur OpenCode.
[Guide utilisateur](https://github.com/deepseek-ai/deepseek-harness/blob/4b399c39a6d1479cd84ca591b4d7c88e24d38a96/docs/user/guide/index.md) · [Paquet d'instructions](https://github.com/deepseek-ai/deepseek-harness/tree/4b399c39a6d1479cd84ca591b4d7c88e24d38a96/packages/context/agent-instructions)

## Surfaces d'injection

- `dsh-base` active `@deepseek-ai/dsh-agent-instructions` par défaut.
  Selon le profil, le paquet peut être désactivé ou manquer d'un service
  de fichiers. Il compose la chaîne initiale avant la première requête
  et peut réévaluer la portée lors de la reprise ou après des opérations
  de fichiers liées au projet.
- La chaîne globale utilise `$DSH_HOME/AGENTS.md` (par défaut
  `~/.dsh/AGENTS.md`) puis `$DSH_AGENTS_HOME/AGENTS.md` (par défaut
  `~/.agents/AGENTS.md`). Les chemins dépendent de l'environnement du
  processus du harnais. Les deux sources sont regroupées pour dédupliquer
  les contenus identiques après retrait des blancs en début et fin.
- La chaîne projet part de la racine détectée, marquée par `.git` par
  défaut, et descend jusqu'au dossier de travail de la session. Par
  répertoire, elle lit les candidats existants `AGENTS.md` et `CLAUDE.md`,
  puis `AGENTS.local.md` et `CLAUDE.local.md`. Les candidats locaux
  s'ajoutent aux autres et les doublons de contenu du même groupe sont
  regroupés. Les marqueurs et listes peuvent être configurés.
- Le budget `maxBytes` de `dsh-base` est de 65 536 octets par chaîne
  (globale ou projet). Le paquet retire d'abord les instructions les plus
  générales puis peut tronquer le dernier fichier retenu. Un avis de
  budget signale les omissions ou troncatures. Le profil peut ajuster
  ces bornes, dont `maxSourceBytes` pour une source individuelle.
  [Configuration et rendu du paquet](https://github.com/deepseek-ai/deepseek-harness/blob/4b399c39a6d1479cd84ca591b4d7c88e24d38a96/packages/context/agent-instructions/README.md#observing-the-budget)

## Installation et vérification

1. Identifier le profil et le dossier de travail de la session. Selon
   la portée autorisée, intégrer le noyau complet dans une des surfaces
   globales chargées ou dans un candidat chargé du projet. Garder les
   consignes préexistantes. Placer la fiche projet dans le candidat prévu
   pour les règles partagées. [Contrat d'installation](../README.md#installation-manuelle)
2. Garder `PROTOCOLE.md` et cet adaptateur à la même révision pour une
   consultation à la demande. Utiliser la skill `protocole-maitre` si le
   profil la découvre et si sa référence est lisible.
3. Vérifier le fichier cible avec `tools/install-check.ps1 -Target <cible>`.
   Dans une session neuve, vérifier les sources et avis de budget observables
   pour le bon profil et workspace, puis effectuer SM-01 sans fournir le
   contenu témoin dans la demande. Réserver toute lecture manuelle aux
   essais qui l'isolent du chargement automatique.

Relever le modèle, les permissions de lecture hors workspace et les
capacités réellement disponibles dans le profil utilisé. Les observations
de septembre, dont les demandes d'approbation hors workspace et l'injection
dans une session déjà ouverte, demandent une nouvelle recette pour un profil
actuel. Aucun plugin additionnel n'est requis si le profil fournit déjà la
découverte native nécessaire.
