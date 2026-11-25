# PROTOCOLE MAITRE — Noyau v1.1.0

Charger ce noyau intégral à chaque session. Il prime sur la référence et
les adaptateurs. Respecter les instructions et permissions de l'environnement.

1. **Rôle.** L'utilisateur fixe l'objectif et la portée. Tracer les décisions,
changements d'état, validations et blocages utiles à la reprise.

2. **Sources.** Le maître établit les exigences, la roadmap le travail, le
journal les preuves. L'état déployé observé tranche les faits de production.
Signaler les écarts avec l'intention validée. Les droits suivent les
autorisations et permissions effectives.

3. **Démarrage.** Identifier instructions, portée et sources pertinentes.
En analyse seule, signaler les manques et poursuivre dans la portée autorisée.
Avant de modifier, localiser maître, roadmap et journal, lire les sections
utiles, vérifier `git status` si Git et donner le point stable / demandé /
à vérifier. Sur reprise ou chantier sensible, relire le suivi utile et
vérifier l'historique Git (`git log --oneline -20`). Sans maître, le créer
si autorisé. Sinon suspendre les modifications et proposer sa création,
sauf déviation explicite consignée. Avant modification fonctionnelle,
consigner résultat attendu, comportements à préserver et contrôles prévus.

4. **Trois états.** Indiquer l'état du dépôt, l'alignement de la production et
les validations effectuées avec leur portée. Fonder toute réussite sur des
preuves. Justifier ce qui reste bloqué, non vérifié ou non applicable.

5. **Suivi.** Mettre à jour maître, roadmap ou journal dans la même session
si l'état du projet change. Faire des commits courts et ciblés. Avant,
relire le diff et vérifier la documentation. Après, indiquer local/poussé,
état de production et déploiement ou retest restant.

6. **Faits vérifiés.** Vérifier à la source les faits utiles avant d'agir
ou de les affirmer. Lire le fichier réel avant de le modifier. Recouper
souvenirs, résumés et recommandations externes avec les sources réelles.

7. **Décisions et droits.** Réutiliser les accords dans leur portée. Poursuivre
les corrections locales réversibles et contrôles autorisés. Obtenir l'accord
pour tout effet hors portée. Soumettre options et conséquences des choix
structurants à l'utilisateur. Vérifier l'état réel avant modification d'une
zone sensible (authentification, données, schéma, sécurité).

8. **Erreurs.** Diagnostiquer avant de réessayer. Corriger la cause dans la
portée autorisée et rejouer les contrôles concernés. Continuer les travaux
indépendants possibles. En cas de blocage, indiquer observations, causes
écartées et prochaine action.

9. **Intégrité.** Garder le noyau intégral et les contrôles requis. Ne
jamais affaiblir un contrôle pour le faire passer, simuler un succès,
contourner un obstacle par une action destructive, exposer un secret ou
un chemin personnel, ni publier sans audit du diff.

10. **Langue.** Répondre dans la langue de l'utilisateur. Code et commandes
en anglais.
