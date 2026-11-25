# Adaptateur — Outils génériques

Identifier d'abord le client ou orchestrateur, sa version, le dossier de
travail et le profil actif. Identifier ensuite le fournisseur et le modèle.
Le client gère la découverte et l'assemblage des instructions. Un même
fournisseur peut être utilisé depuis des clients qui assemblent le contexte
différemment.

1. Chercher dans la documentation du client les surfaces globales, projet et
   conditionnelles. Observer la racine reconnue et la chaîne depuis le
   dossier de travail, les surcharges, les replis, les exclusions et les
   budgets applicables. Consigner comme inconnues les valeurs effectives
   qui ne sont pas vérifiables.
2. Intégrer le noyau une seule fois et en entier dans une surface persistante
   autorisée et chargée, en préservant les règles déjà présentes. Placer les
   spécificités dans le projet. Garder la référence et l'adaptateur à la
   même révision pour les consulter au besoin. Les réglages fournisseurs et
   leurs accès relèvent de l'environnement de l'utilisateur.
   [Contrat d'installation](../README.md#installation-manuelle)
3. Vérifier l'intégrité du fichier avec `tools/install-check.ps1`, puis
   vérifier la découverte effective avec les commandes natives quand elles
   permettent d'observer les sources. Exécuter SM-01 dans une session vierge,
   depuis le dossier et le profil attendus. Indiquer si chaque résultat
   provient d'un fichier automatiquement chargé, d'une skill, d'un import
   par le client ou d'une lecture manuelle.
4. Vérifier les permissions par un effet observable dans une fixture sûre.
   Réexaminer le chargement et le comportement à chaque environnement
   réellement utilisé ainsi qu'après compaction, reprise et changement
   de modèle. Le résultat d'un modèle sur un cas témoigne de cet essai.

## GitHub CLI

Pour une action sur GitHub (pull request, issue, checks CI, release ou appel
d'API), vérifier la disponibilité de `gh` par `Get-Command gh` en PowerShell,
`where gh` dans CMD ou `command -v gh` en shell POSIX. Vérifier le compte et
l'hôte pertinents avec `gh auth status` selon le besoin. Sur les versions
qui le proposent, `--no-refresh` évite le rafraîchissement automatique.
Les droits se vérifient pour l'action visée. Si nécessaire, utiliser le
moyen disponible parmi le client Git, l'interface ou l'API du projet.
[Commandes GitHub CLI](https://cli.github.com/manual/) · [État d'authentification](https://cli.github.com/manual/gh_auth_status)

Pour l'automatisation sur GitHub.com, `gh` consulte `GH_TOKEN` puis
`GITHUB_TOKEN`, avant les identifiants stockés. Appliquer la section
**Sécurité et secrets** de la [référence](../PROTOCOLE.md#8-sécurité-et-secrets).
[Variables d'environnement GitHub CLI](https://cli.github.com/manual/gh_help_environment)
