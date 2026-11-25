# Adaptateur — OpenCode 2

Instructions et configuration revues le 25/11/2026. Relever la version du
client, le workspace et, le cas échéant, le service auquel il est connecté.
[Instructions V2](https://opencode.ai/docs/instructions/) · [Configuration](https://opencode.ai/docs/config/) · [Migration depuis V1](https://opencode.ai/docs/migrate-v1/)

Autres surfaces documentées le 12/11/2026.
[Skills](https://opencode.ai/docs/skills/) · [Permissions](https://opencode.ai/docs/permissions/) · [Policies](https://opencode.ai/docs/policies/) · [CLI](https://opencode.ai/docs/cli/commands/) · [Compaction](https://opencode.ai/docs/compaction/) · [Cache](https://opencode.ai/docs/models/#prompt-caching) · [Warming](https://opencode.ai/docs/warming/)

## Installation native

- Le chemin global habituel est `~/.config/opencode/AGENTS.md`. Vérifier la
  configuration du serveur réellement utilisé et les dossiers alternatifs,
  par exemple `OPENCODE_CONFIG_DIR`. Préserver les consignes et ajouter le
  noyau intégral une seule fois dans une surface globale ou projet
  effectivement chargée selon la portée autorisée.
  [Contrat d'installation](../README.md#installation-manuelle)
- V2 combine le global et la chaîne du workspace vers ses ancêtres. La
  découverte s'arrête au dossier utilisateur. Pour un workspace hors du
  dossier utilisateur, elle s'arrête à la racine du projet. Le guide actuel décrit un repli
  `CLAUDE.md` par répertoire en l'absence d'`AGENTS.md` et le repli global
  `~/.claude/CLAUDE.md`. Vérifier l'effet de
  `OPENCODE_DISABLE_CLAUDE_CODE_PROMPT`, `OPENCODE_DISABLE_CLAUDE_CODE` et
  `OPENCODE_DISABLE_PROJECT_CONFIG` s'ils sont présents dans l'environnement
  du serveur. [Portée, repli et découverte](https://opencode.ai/docs/instructions/)
- Les entrées `instructions` de la configuration effective s'ajoutent aux
  sources de la chaîne. Elles peuvent viser des fichiers locaux, des motifs
  ou des URL. OpenCode assemble les textes et laisse les conflits à résoudre.
  Les fichiers descendants pertinents peuvent s'ajouter lors de la lecture
  d'une zone. Les mises à jour des fichiers ambiants et celles des fichiers
  découverts en descendant suivent des règles différentes.
  [Assemblage et mises à jour](https://opencode.ai/docs/instructions/#ordering)
- Conserver `PROTOCOLE.md` et cet adaptateur à la même révision pour lecture à la
  demande, par exemple dans la skill. Une entrée `instructions` à ce fichier
  en ferait une instruction additionnelle du client.
- Sauvegarder les fichiers d'installation puis fusionner : aucune réécriture globale de la configuration n'est nécessaire. Préserver les providers, modèles, clés, sessions et réglages de cache/compaction.
- Vérifier `tools/install-check.ps1 -Target <cible>` pour l'intégrité du fichier.
  Relever les sources observables dans le workspace visé, puis effectuer SM-01
  en session vierge avant toute lecture manuelle du témoin.

## Skill de référence

En dehors du bloc intégral du noyau, inclure ce repère de chargement dans la
surface d'installation autorisée. Le bloc intégral porte les règles permanentes.

> Avant de conclure à un blocage, ou pour préciser une règle de sécurité,
> qualité, communication, validation ou reprise, charger le skill `protocole-maitre` et lire
> la section utile de sa référence locale. Le noyau reste prioritaire.

Le dossier `skills/protocole-maitre/` du dépôt est un modèle d'installation.
Pour une installation globale autorisée, procéder ainsi.

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
