# Adaptateur — Claude Code

Surfaces revues le 25/11/2026. [Documentation officielle](https://code.claude.com/docs/en/memory)
L'ancien dépôt `PROTOCOLE-CLAUDE` reste une référence historique.

## Surfaces d'injection

- Le fichier utilisateur habituel est `~/.claude/CLAUDE.md`. À l'ouverture,
  Claude Code peut aussi charger des instructions gérées et les consignes des
  répertoires du projet jusqu'au dossier de travail, notamment `CLAUDE.md`,
  `.claude/CLAUDE.md` et `CLAUDE.local.md`. Les fichiers descendants se
  chargent à l'exploration. Les règles ciblées et les skills servent aux besoins
  conditionnels. [Choix des emplacements et ordre](https://code.claude.com/docs/en/memory#choose-where-to-put-claudemd-files)
- À partir de la version 2.1.277, vérifier la présence et la valeur de
  **Project instructions** dans `/config`. Avec le réglage par défaut lorsque la
  fonction est disponible, les `AGENTS.md` projet chargent si les trois formes
  de `CLAUDE.md` de projet ou locales sont absentes dans la chaîne de lancement.
  Le fichier utilisateur global et les règles `.claude/rules/` peuvent
  coexister avec `AGENTS.md`. Le réglage peut aussi demander les deux familles,
  seulement les fichiers Claude, ou seulement les instructions gérées à
  l'ouverture. [Modes et conditions du chargement direct](https://code.claude.com/docs/en/memory#use-an-existing-agentsmd)
- Un `CLAUDE.md` peut importer un `AGENTS.md` partagé via `@AGENTS.md` dans
  le même dossier. Cet import et la découverte directe sont deux voies
  automatiques distinctes. La lecture du fichier par un outil pendant une
  tâche est une troisième voie. [Imports de fichiers](https://code.claude.com/docs/en/memory#use-imports)

## Installation du protocole

Pour une installation globale autorisée, intégrer `NOYAU.md` en entier
dans la surface utilisateur effectivement chargée. Pour une installation
limitée au projet, utiliser sa surface active. Ajouter les spécificités
dans la surface projet en préservant les consignes existantes. Garder la
référence à la demande. [Contrat d'installation](../README.md#installation-manuelle)

Vérifier l'intégrité du fichier cible avec `tools/install-check.ps1`.
Dans une session vierge, consulter `/context all` sous **Memory files**
pour les fichiers chargés à l'ouverture. `/memory` permet d'examiner les
emplacements utilisateur et projet, y compris certains candidats absents.
Effectuer ensuite SM-01 pour vérifier le comportement sur une consigne
témoin fournie par la surface permanente. Les commandes de visualisation
peuvent afficher des chemins privés. [Vérification en session](https://code.claude.com/docs/en/memory#troubleshoot-memory-issues)
