# Adaptateur — DeepSeek Harness (DSH)

Outil en interface web, sessions liées à un espace de travail local.
Pilote quotidien de l'auteur.

## Surfaces d'injection (vérifiées dans le harnais, 2026-09)

- **Fichier global d'instructions : `$DSH_HOME/AGENTS.md`** (sous Windows :
  `C:\Users\<toi>\.dsh\AGENTS.md`). Le paquet natif
  `@deepseek-ai/dsh-agent-instructions` l'injecte automatiquement au premier
  message de chaque session. Budget par défaut : 65 536 octets (configurable
  via `maxBytes` dans le `cordis.patch.yml` du profil).
- **Chaîne projet** : `AGENTS.md` et `CLAUDE.md` sont lus du dossier racine du
  projet (marqueur `.git`) jusqu'au dossier de travail, complétés par les
  surcouches `AGENTS.local.md` / `CLAUDE.local.md`. Les doublons de contenu
  sont dédupliqués.
- **Skills** : `C:\Users\<toi>\.agents\skills\<nom>\SKILL.md`, chargées à la
  demande (catalogue exposé dans le prompt système sous `<available_skills>`).

## Installation du protocole

1. **Globale (recommandée)** : coller l'intégralité de `NOYAU.md` dans
   `$DSH_HOME/AGENTS.md`. Le noyau est alors chargé automatiquement dans
   toutes les sessions, sans aucune demande.
2. **Projet** : placer la fiche projet (`templates/FICHE_PROJET.md` remplie)
   dans `AGENTS.md` ou `CLAUDE.md` à la racine du projet.
3. **Référence à la demande** : garder la skill `protocole-maitre` comme
   pointeur, ou lire `PROTOCOLE.md` directement.

## Vérification

- Statique : `tools/install-check.ps1 -Target "$DSH_HOME/AGENTS.md"`.
- Comportementale : scénario SM-01 dans une nouvelle session (le noyau est
  actif dès le premier message, sans rien demander).

## Fonctionnalités natives observées

- Outils : lecture/écriture de fichiers, PowerShell (bac à sable), recherche,
  web, sous-agents, objectif de session suivi entre tours, mode plan,
  approbations utilisateur.
- Plugins : système Cordis (`$DSH_HOME/plugins/`, déclaration par
  `cordis.patch.yml`). Inutile pour ce protocole : le mécanisme natif
  `AGENTS.md` suffit.

## Valeurs propres

- Modèle sous-jacent : DeepSeek V4 Pro (1 M de tokens annoncé, thinking par
  défaut). Chiffres à vérifier dans l'environnement actif.

## Limites connues

- Observé (2026-09-23) : le harnais injecte le fichier global dans la session
  courante dès qu'il apparaît — une session neuve le reçoit dès le premier
  message.
- Les dossiers hors espace de travail exigent une approbation par opération.
