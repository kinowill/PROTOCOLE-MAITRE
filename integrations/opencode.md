# Adaptateur — opencode

Outil pilote quotidien. opencode combine des surfaces compatibles Claude Code
et ses propres surfaces natives.

## Surfaces d'injection

| Surface | Chemin | Portée |
|---|---|---|
| `CLAUDE.md` (compat) | `~/.claude/CLAUDE.md` (global), `CLAUDE.md` (projet) | lu automatiquement |
| `AGENTS.md` (natif) | racine du projet, généré par `/init` | lu automatiquement |
| `opencode.json` | `~/.config/opencode/opencode.json` (global), projet | champ `instructions` : fichiers chargés |

## Installation du protocole

- **Globale** : coller l'intégralité de `NOYAU.md` dans `~/.claude/CLAUDE.md`
  (Windows : `C:\Users\<toi>\.claude\CLAUDE.md`), ou pointer le champ
  `instructions` de `~/.config/opencode/opencode.json` vers le chemin local
  de `NOYAU.md` et de `PROTOCOLE.md`.
- **Projet** : `CLAUDE.md` court à la racine avec les spécificités du projet
  (stack, commandes, sources de vérité) ; le noyau reste global.
- **Hybride recommandé** : noyau + référence en global ; par projet, seulement
  les spécificités.

## Fonctionnalités natives

- Agents : Build (tous les outils), Plan (lecture seule), General et Explore
  (subagents).
- Skills : `.agents/skills/`, `.opencode/skills/`, `.claude/skills/`,
  `~/.config/opencode/skills/`.
- LSP chargés automatiquement. Commandes : `/init`, `/undo`, `/redo`,
  `/share`, `/connect`.
- Compaction : agent automatique à l'approche de la limite de contexte.
- `rtk` (Rust Token Killer) : wrapper de verbosité pour git/npm/cargo/tsc…
  s'il existe dans l'environnement.

## Valeurs propres

- Avec DeepSeek V4 Pro via opencode : fenêtre 1 000 000 tokens (thinking
  inclus), sortie max 384 000, thinking par défaut, effort `max` pour les
  agents de codage, cache disque de préfixe (hit ~12× moins cher), rate limit
  dynamique (HTTP 429, timeout 10 min). Chiffres fournisseur : à vérifier
  dans la configuration active.
- Journaux de session : `~/.claude/projects/*.jsonl` (lus par
  `tools/show_context.ps1`).

## Commande de monitoring

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\PROJETS\PROTOCOLE MAITRE\tools\show_context.ps1"
```

## Limites connues

- Les chemins `~/.claude/` dépendent de la compatibilité Claude Code ; à
  vérifier selon la version d'opencode installée.
- La présence d'un `CLAUDE.md` ne prouve pas le chargement : vérification en
  nouvelle session (scénario SM-01 de VALIDATION_SCENARIOS.md).
