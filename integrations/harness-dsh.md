# Adaptateur — DeepSeek Harness (DSH)

Outil en interface web, sessions liées à un espace de travail local.

## Surfaces d'injection connues

- **Skills** : chargées à la demande depuis `C:\Users\<toi>\.agents\skills\<nom>\SKILL.md`
  (liste exposée dans le prompt système sous `<available_skills>`).
- **Espace de travail de session** : dossier fixé par la session ; le bac à
  sable limite les écritures à ce dossier et aux zones temporaires.
- **Approbations** : les opérations hors périmètre passent par des demandes
  d'approbation utilisateur (échec fermé si aucun répondeur disponible).

## Installation du protocole

Méthode prévue : créer une skill `protocole-maitre` contenant l'intégralité
de `NOYAU.md`, chargée à chaque session. La référence (`PROTOCOLE.md`) vit
dans le dossier local du protocole et se lit
à la demande.

Autres surfaces possibles (fichier d'instructions global du harnais) : non
documentées à ce jour, à vérifier avant de s'y appuyer.

## Fonctionnalités natives observées

- Outils : lecture/écriture de fichiers, PowerShell (avec bac à sable),
  recherche, web, sous-agents, objectif de session suivi entre tours.
- Pense-bête de tâches et mode plan (validation du plan avant exécution).

## Valeurs propres

- Modèle sous-jacent : DeepSeek V4 Pro (1 M de tokens annoncé, thinking par
  défaut). Chiffres à vérifier dans l'environnement actif.

## Limites connues

- Pas de fichier d'instructions global documenté : la skill est le vecteur
  principal à ce jour.
- Le bac à sable restreint les écritures à l'espace de travail de session ;
  les dossiers externes (hors espace de travail) exigent une approbation par
  opération.
