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
