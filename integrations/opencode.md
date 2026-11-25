# Adaptateur — OpenCode 2

Documentation officielle consultée le 12/11/2026 : [instructions](https://opencode.ai/docs/instructions/), [skills](https://opencode.ai/docs/skills/), [permissions](https://opencode.ai/docs/permissions/), [policies](https://opencode.ai/docs/policies/), [CLI](https://opencode.ai/docs/cli/commands/), [compaction](https://opencode.ai/docs/compaction/), [cache](https://opencode.ai/docs/models/#prompt-caching) et [warming](https://opencode.ai/docs/warming/). Documentation évolutive : relever aussi la version installée ; OpenCode 1 et 2 diffèrent.

## Installation native

- Global : `~/.config/opencode/AGENTS.md`. Préserver les consignes existantes et ajouter le noyau intégral une seule fois. V2 reconnaît `AGENTS.md`, sans solution de repli `CLAUDE.md`.
- Projet : `AGENTS.md` pour les spécificités locales. Les fichiers globaux, ceux du workspace et des ancêtres puis ceux du tableau `instructions` sont combinés. Les conflits de texte ne sont pas résolus automatiquement. Des fichiers descendants peuvent s'ajouter pendant l'exploration.
- Examiner les chemins de configuration alternatifs et les sources effectives avant de choisir la cible globale. XDG et `OPENCODE_CONFIG_DIR` peuvent déplacer la configuration.
- Conserver `PROTOCOLE.md` localement à une révision identifiée. Ne pas ajouter la référence complète à `instructions` si elle doit rester à la demande.
- Sauvegarder les fichiers d'installation puis fusionner : aucune réécriture globale de la configuration n'est nécessaire. Préserver les providers, modèles, clés, sessions et réglages de cache/compaction.
- Vérifier `tools/install-check.ps1 -Target <cible>`, puis SM-01 en session vierge. Le contrôle statique ne prouve ni le chargement ni l'obéissance du modèle.

## Skill de référence

En dehors du bloc intégral du noyau, inclure ce repère de chargement dans les
instructions globales lors de l'installation, sans résumer ni remplacer le noyau :

> Avant de conclure à un blocage, ou pour préciser une règle de sécurité,
> qualité, communication, validation ou reprise, charger le skill `protocole-maitre` et lire
> la section utile de sa référence locale. Le noyau reste prioritaire.

Le dossier `skills/protocole-maitre/` du dépôt est un modèle d'installation :

1. Copier son `SKILL.md` dans `~/.config/opencode/skills/protocole-maitre/`.
2. Copier le `PROTOCOLE.md` de la même révision dans `references/PROTOCOLE.md`, sous ce dossier de skill.
3. Copier aussi `integrations/opencode.md` vers `references/integrations/opencode.md`, à la même révision.
4. Tester découverte, chargement et lecture de ces copies locales dans une session vierge.

L'ID vient du dossier `protocole-maitre`, pas de `name`. Le catalogue annonce
nom et description ; le corps puis les fichiers d'appui sont chargés à la demande.
`.opencode/skills/` est l'alternative projet ; éviter les doublons global/projet.
La disponibilité dépend des permissions et de la configuration de skills.

## Permissions et politiques V2

V2 utilise `permissions` (tableau), `shell` et `subagent`, à la place des anciennes
clés `permission`, `bash` et `task`. Chaque règle porte `action`, `resource`,
`effect` (`allow`, `ask`, `deny`). La dernière règle correspondante gagne.
Les règles d'agent sont ajoutées après les globales ; un sous-agent personnalisé
utilise ses propres permissions. Vérifier les règles effectives de chaque agent.

Exemple à examiner et fusionner dans la configuration existante :

```json
{
  "permissions": [
    { "action": "shell", "resource": "*", "effect": "ask" },
    { "action": "shell", "resource": "git status --short", "effect": "allow" },
    { "action": "shell", "resource": "git diff --no-ext-diff --no-textconv", "effect": "allow" },
    { "action": "shell", "resource": "git push *", "effect": "ask" },
    { "action": "external_directory", "resource": "*", "effect": "ask" }
  ]
}
```

Les autorisations de l'exemple sont des commandes exactes : un motif large comme
`git diff *` couvrirait aussi des options d'écriture ou de diff externe.
Les `policies` sont distinctes. Une règle telle que
`{"action":"tool.use","resource":"shell:git push *","effect":"deny"}`
dans `policies` apporte un refus dur pour ce motif, y compris face aux permissions
d'agents et approbations sauvegardées. Elle ne couvre pas tous les moyens de
publier. Une politique invalide peut être ignorée avec avertissement.

Les permissions textuelles ne sont pas une isolation du système : le shell garde
les pouvoirs de l'utilisateur. Tester les commandes composées, les accès hors
projet et les autres agents dans un dossier d'essai, sans publication réelle.
Une liste de commandes bloquées ne prouve pas une protection exhaustive.

## Contexte et statistiques

Commandes V2 documentées, à confirmer par l'aide locale :

```powershell
opencode --version
opencode stats --models --cost
opencode stats --json
opencode session list --max-count 20 --format json
opencode debug paths db
pwsh -NoProfile -File tools/show_context.ps1
pwsh -NoProfile -File tools/show_context.ps1 -Mode Sessions
```

`stats` mesure l'usage, pas le remplissage exact du contexte actif. La limite
dépend du modèle. Le script ne lit aucune ancienne trace Claude et ne calcule
aucun pourcentage arbitraire. `-Mode Paths` affiche le chemin de la base sans
la modifier. Les sorties peuvent contenir des chemins et titres privés.

La compaction automatique utilise le budget du modèle. Préserver les réglages
`compaction.auto`, `compaction.keep.tokens` et `compaction.buffer` existants.
Elle peut perdre des détails et ne réduit pas les instructions fixes volumineuses.
Les checkpoints natifs chiffrés restent liés au fournisseur et au modèle ; après
changement, OpenCode repart de la conversation originale. Les faits de reprise
restent dans les documents du projet.

## Cache et indépendance des modèles

Le cache dépend de l'endpoint et du modèle : ni hit, ni durée, ni prix ni transfert
entre fournisseurs ne sont garantis. Ne pas ajouter un format de cache Anthropic
à un fournisseur compatible OpenAI sans preuve de compatibilité. Le warming,
désactivé par défaut, émet de vraies requêtes pouvant être facturées et consommer
des limites ; son activation ne fait pas partie de l'installation du protocole.

Entrim, DeepSeek et OpenCode Free reçoivent les instructions par OpenCode.
Préserver providers, URLs, credentials, variantes, modèle par défaut, variables
de service et sessions. Ne pas ajouter de filtre `provider.use`, de liste de
fournisseurs ni `OPENCODE_DISABLE_FREE_MODELS` pour installer les règles.
Les IDs et la disponibilité se vérifient dans `/models` ou `opencode models` ;
ne pas inventer de catalogue Entrim. [Providers](https://opencode.ai/docs/providers/).

## Sous-agents et vérification

Un agent peut utiliser un autre modèle ou fournisseur que le principal, avec
l'identifiant `fournisseur/modèle` d'un fournisseur configuré. Un fournisseur
local peut servir de cible si son serveur répond et expose le modèle demandé.
[Agents V2](https://opencode.ai/docs/agents/) · [Agents V1](https://opencode.ai/v1/docs/agents/#model)

Pour SM-12, un rôle temporaire dans le dossier d'essai est une option pour
vérifier un choix explicite de modèle en conservant le principal configuré.
Les commandes et permissions dépendent de la version. Dans OpenCode 1.19.5,
le résultat de l'outil `task` indique la session enfant et le modèle
sélectionné. `opencode export <id> --sanitize`
permet de contrôler `info.providerID` et `info.modelID` dans les messages
assistant de l'enfant et de vérifier l'absence d'erreur. Un extrait limité à
ces champs et à l'état du tour suffit au journal public.
[Délégation dans la version 1.19.5](https://github.com/anomalyco/opencode/blob/v1.19.5/packages/opencode/src/tool/task.ts#L161-L175) · [Export V1](https://opencode.ai/v1/docs/cli/#export)

## Validation

Tester séparément les fournisseurs/modèles utilisés, les consignes locales,
les permissions, le skill, puis la reprise après compaction et changement de modèle.
Les mêmes instructions ne garantissent pas la même fiabilité. Distinguer les
sources effectivement injectées du seul comportement observé. Ne jamais afficher
de clés ou de configuration privée dans le compte rendu.
