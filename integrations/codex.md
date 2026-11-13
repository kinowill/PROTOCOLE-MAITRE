# Adaptateur — OpenAI Codex CLI

Surfaces revues le 12/11/2026 d'après la [documentation officielle](https://learn.chatgpt.com/docs/agent-configuration/agents-md).
L'ancien dépôt `PROTOCOLE-CODEX` est historique, pas une référence de version actuelle.

## Surfaces d'injection

- Global : `$CODEX_HOME/AGENTS.md` (par défaut `~/.codex/AGENTS.md`).
- `AGENTS.override.md` est prioritaire sur `AGENTS.md` dans un même dossier ;
  un seul fichier est retenu par niveau. Examiner les overrides existants.
- Projet : chaîne de fichiers depuis la racine du projet jusqu'au dossier courant.
- Budget des documents projet : `project_doc_max_bytes` dans la configuration
  (32 Kio par défaut d'après la documentation consultée). Le contenu existant compte aussi.

## Installation du protocole

Coller l'intégralité de `NOYAU.md` dans l'`AGENTS.md` global ; ajouter les
spécificités du projet dans l'`AGENTS.md` projet, en préservant les instructions
existantes. Le contrôle statique ne détecte pas qu'un override masque la cible :
examiner les instructions effectives et lancer une session vierge pour SM-01.

## Valeurs propres

Vérifier le modèle, le client et leurs limites dans l'environnement actif.
Les chiffres d'un ancien adaptateur ne prouvent pas la capacité du modèle actuel.

## Sous-agents et vérification

Dans Codex, `[agents]` peut définir `default_subagent_model`,
`default_subagent_reasoning_effort` et `max_concurrent_threads_per_session`.
La limite porte sur les enfants ouverts et exclut le principal. Les valeurs
explicites de lancement priment sur les défauts et un fichier de rôle peut
aussi fixer son modèle ou son effort. Le fournisseur et les permissions sont
hérités de la session parente. [Configuration des sous-agents](https://learn.chatgpt.com/docs/agent-configuration/subagents)

Le CLI accepte des surcharges temporaires via `-c`. Dans SM-12, elles
permettent de tester les paramètres des enfants sur une invocation. Le
modèle, l'effort et la vitesse du principal suivent les réglages de la
session. Les modèles accessibles dépendent du compte et du fournisseur
actif. Sans choix de modèle pour un enfant, Codex peut utiliser celui du
principal.

En mode interactif, `/subagents` ouvre le fil enfant et `/status` y affiche
le modèle actif.
Les traces d'exécution peuvent aussi fournir le modèle et l'effort du tour
enfant. Dans Codex CLI 0.167.2, les journaux de session associent les enfants
au principal et enregistrent `model` et `effort` dans `turn_context`.
La sortie `--json` du principal peut omettre ces informations.
[Options du CLI](https://learn.chatgpt.com/docs/cli/reference) · [Commandes interactives](https://learn.chatgpt.com/docs/cli/slash-commands)

Pour le repli de SM-12, utiliser une session d'essai avec
`-c 'agents.enabled=false'`. ChatGPT Work exécute ses sous-agents dans son
environnement hébergé. Les réglages et preuves de cette surface se vérifient
dans sa propre session.
