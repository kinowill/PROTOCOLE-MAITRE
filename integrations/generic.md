# Adaptateur — Outils génériques

S'applique à tout assistant acceptant un prompt système ou un fichier
d'instructions persistant : Cursor, Cline, Continue, Aider, ChatGPT custom
GPTs, API directe, agents maison.

## Surfaces d'injection

| Outil | Endroit où injecter |
|---|---|
| Cursor | `.cursorrules` à la racine, ou Settings → Rules |
| Cline | Custom Instructions dans les settings |
| Continue | `~/.continue/config.json` → `systemMessage` |
| Aider | `--read CONVENTIONS.md` ou `.aider.conf.yml` |
| ChatGPT custom GPT | Champ « Instructions » du GPT |
| API directe | Paramètre `system` de l'appel |

## Méthode universelle

1. Copier le contenu de `NOYAU.md`.
2. Le coller dans le champ « instructions système » de l'outil choisi.
3. Si l'outil supporte un fichier projet en plus du système global, y ajouter
   une courte fiche projet (langue, stack, sources de vérité).

La référence (`PROTOCOLE.md`) est consultée à la demande (fichier local ou
dépôt GitHub), pas injectée en permanence.

## Adaptations possibles

Selon l'outil : traduire (la langue n'est pas une règle), ajouter des
spécificités de projet. En cas de fenêtre limitée, tout raccourcissement
reste soumis à la règle du noyau (bloc 9) et à la référence (section 11) :
pas de version courte substituée au noyau sans demande explicite de
l'utilisateur.

## Test minimal

Session sur un projet sans `DOCUMENT_MAITRE.md` : l'agent doit proposer de
créer le maître avant de répondre à la demande. S'il répond directement sans
mentionner le maître, le protocole n'est pas chargé ou est ignoré : vérifier
la configuration.

## Limites connues

- **Petits modèles locaux** (7B et moins) : oublient une étape sur deux ;
  utiliser de préférence un modèle de classe Sonnet / GPT-4o / Gemini Pro
  ou équivalent.
- **Agents en « tool calling » agressif** : peuvent exécuter avant de lire ;
  vérifier dans les premiers tests que « lire avant d'agir » est tenu.
- **Fenêtres courtes** : si le protocole est oublié après quelques tours, la
  fenêtre est saturée ; réduire la longueur des réponses ou changer d'outil.
- **Garantie de reprise** : complète uniquement pour les outils avec accès
  fichiers + instructions persistantes ; un outil chat-only ne tient que la
  session courante.
