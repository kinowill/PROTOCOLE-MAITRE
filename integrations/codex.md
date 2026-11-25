# Adaptateur — OpenAI Codex CLI

Surfaces revues le 25/11/2026 dans le guide officiel et les sources du CLI.
Le dépôt `PROTOCOLE-CODEX` reste une référence historique.

## Surfaces d'injection

- Le dossier global du CLI est `$CODEX_HOME` ou, par défaut, `~/.codex`.
  La recherche retient le premier fichier au contenu non blanc parmi
  `AGENTS.override.md` et `AGENTS.md`, dans cet ordre.
  [Guide officiel](https://learn.chatgpt.com/docs/agent-configuration/agents-md) · [Chargement global du CLI 0.167.2](https://github.com/openai/codex/blob/ce21072c90d32c40af7a55b60b2fb35c84a43a6a/codex-rs/codex-home/src/instructions/mod.rs#L36-L79)
- Le projet est parcouru depuis la racine détectée jusqu'au dossier de la
  session. Sans racine détectée, seul ce dossier est pris en compte. À chaque
  niveau, l'ordre est `AGENTS.override.md`, `AGENTS.md`, puis la liste
  `project_doc_fallback_filenames`. Dans le code du CLI 0.167.2 et la
  source actuelle consultée, le premier fichier régulier réserve le niveau.
  Un override projet vide ou blanc peut donc masquer le standard, puis
  contribuer zéro octet d'instructions.
  [Découverte projet du CLI 0.167.2](https://github.com/openai/codex/blob/ce21072c90d32c40af7a55b60b2fb35c84a43a6a/codex-rs/core/src/agents_md.rs#L175-L278) · [Source revue au 25/11](https://github.com/openai/codex/blob/cec14d27b5aa1a79e9de2e21a6281d308ae1fac3/codex-rs/core/src/agents_md.rs#L185-L375)
- `project_doc_max_bytes` plafonne les fichiers du projet ensemble. Le
  global est hors budget. Le défaut documenté est 32 Kio. Chaque fichier est
  lu sur le solde restant, ce qui peut tronquer un fichier puis exclure les
  niveaux suivants. La source actuelle applique ce solde aux environnements
  sélectionnés et conditionne les lectures à la confiance du projet.
  Vérifier les réglages de l'invocation, notamment ses surcharges `-c`.
  [Configuration et découverte](https://learn.chatgpt.com/docs/config-file/config-advanced#project-instructions-discovery) · [Budget dans le code du CLI](https://github.com/openai/codex/blob/cec14d27b5aa1a79e9de2e21a6281d308ae1fac3/codex-rs/core/src/agents_md.rs#L55-L175)

## Installation du protocole

Pour une installation globale autorisée, intégrer `NOYAU.md` en entier dans
le fichier global retenu. Pour une installation limitée au projet, utiliser
un fichier de sa chaîne dont le chargement est vérifié. Placer les
spécificités dans la chaîne du projet et préserver les consignes existantes.
[Contrat d'installation](../README.md#installation-manuelle)

Garder `PROTOCOLE.md` et cet adaptateur à la même révision pour la lecture
à la demande. Vérifier l'intégrité du fichier d'installation avec
`tools/install-check.ps1`, puis comparer la chaîne locale au dossier de
lancement et aux paramètres retenus. SM-01 se rejoue dans une session vierge
avec une consigne témoin inoffensive, sans copier son texte dans la demande.
Consigner la version, la surface, les sources observables et l'action
réellement observée. Le CLI, l'application et une exécution hébergée ont
chacun leur environnement.
[Guide de vérification](https://learn.chatgpt.com/docs/agent-configuration/agents-md) · [Dossiers dans l'application](https://learn.chatgpt.com/docs/projects)

## Diagnostic de la chaîne locale

Avec PowerShell 7 et un manifeste JSON UTF-8 local, le script simule une
chaîne CLI sur un seul environnement dont le projet est autorisé à fournir
ses instructions. Le manifeste contient des chemins privés et se garde
localement hors Git. Exemple avec chemins fictifs à remplacer par des chemins
absolus. Sous Windows, doubler les antislashs dans les chaînes JSON ou utiliser
des barres obliques.

```json
{
  "client": "codex-cli",
  "global_dir": "/local/codex",
  "project_root": "/local/project",
  "cwd": "/local/project/subdirectory",
  "project_doc_max_bytes": 32768,
  "project_doc_fallback_filenames": ["TEAM_GUIDE.md"]
}
```

```powershell
pwsh -NoProfile -File tools/check-instruction-context.ps1 -ManifestPath './manifest-local.json'
```

- Renseigner `project_root` à `null` seulement si l'absence de racine est
  établie, et la liste de repli à `[]` si elle est effectivement vide.
  Omettre la racine si elle est inconnue. Omettre un budget ou une liste
  inconnus ou leur donner `null`. Il faut connaître les trois valeurs
  pour simuler la consommation du budget. Le script utilise les valeurs
  déclarées et l'état local des fichiers. La configuration effective, les
  imports et les lectures manuelles restent en dehors de ce contrôle.
- `SIMULATED` décrit une chaîne calculée avec tous les paramètres.
  `PARTIAL` indique une donnée manquante. `MASKED` signale un candidat
  écarté au profit d'un autre au même niveau. `EMPTY` signale un texte vide ou
  blanc dans la portion lue, `truncated` une portion plus courte que le
  fichier. `SKIPPED_BUDGET` signale une source sélectionnée laissée de côté
  faute de solde. Les niveaux de projet sont numérotés depuis la racine
  simulée, les replis selon leur ordre après retrait des doublons exacts.
  Le code de sortie 0 indique qu'un rapport a été produit, même avec des
  réserves. Le code 1 indique que le diagnostic a échoué.
- Le calcul se limite à la lecture d'un environnement. Codex coupe sur
  les octets avant de décoder en UTF-8. Un caractère invalide ou coupé
  devient un caractère de remplacement. Pour une portion non blanche,
  le solde local est débité de sa taille brute. Le calcul natif entre
  plusieurs environnements porte sur le texte décodé et sort du périmètre.
  [Calcul dans le CLI 0.167.2](https://github.com/openai/codex/blob/ce21072c90d32c40af7a55b60b2fb35c84a43a6a/codex-rs/core/src/agents_md.rs#L62-L165)
- Le script lit le manifeste, les métadonnées des fichiers candidats et
  les préfixes utiles des instructions. Il utilise des fichiers locaux
  ordinaires et stables. Il refuse notamment les partages explicites, les
  liens symboliques et jonctions détectés, et les lectures au-delà d'un Mio
  par fichier candidat. Sous Unix, l'exécutable système `test` permet
  d'écarter par exemple les tubes nommés avant toute lecture. Son absence
  arrête le diagnostic. Un fichier illisible interrompt le diagnostic
  même si le client peut continuer ou conserver un état antérieur.
  Le JSON n'affiche ni chemin, ni contenu, ni erreur
  brute. Le rapport laisse `session_load` à `UNVERIFIED`. Vérifier SM-01
  pour une preuve de comportement en session.

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
