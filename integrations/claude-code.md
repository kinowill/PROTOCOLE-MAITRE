# Adaptateur — Claude Code

Surfaces revues le 12/11/2026 d'après la [documentation officielle](https://code.claude.com/docs/en/memory).
L'ancien dépôt `PROTOCOLE-CLAUDE` reste une référence historique.

## Surfaces d'injection

- Global : `~/.claude/CLAUDE.md`
- Projet : `CLAUDE.md` à la racine
- Skills : `.claude/skills/`
- Depuis v2.1.277, `AGENTS.md` projet peut aussi être chargé selon les réglages
  et la présence de fichiers `CLAUDE.md` / `CLAUDE.local.md` dans la chaîne locale.
  Le `CLAUDE.md` global ne suffit pas à exclure ce mécanisme. Vérifier avec `/memory`.

## Installation du protocole

Coller l'intégralité de `NOYAU.md` dans le `CLAUDE.md` global ; spécificités
par projet dans la surface effectivement chargée. Préserver les instructions
existantes et éviter les doublons. Le contrôle statique et SM-01 en session
vierge couvrent des aspects différents de l'installation.
