# Roadmap — PROTOCOLE MAITRE

## État actuel

- [x] Édition 1.1.0 disponible sur `main` : dernière revue et CI Windows/Linux réalisées (journal).

## À vérifier avant intégration complète

- [ ] Session vierge Entrim, DeepSeek et OpenCode Free : SM-01, skill et permissions.
- [ ] Reprise après compaction et changement de modèle, sans perte des faits durables.
- [x] CI distante Windows/Linux réussie sur le correctif publié `53d4943` (journal).
- [ ] Arbitrer une révision du noyau : démarrage proportionné et autorisations persistantes (audit du 12/11).
- [ ] Réexaminer les observations historiques DSH sur une installation actuelle.
- [ ] Retester la lecture via Codex CLI sous Windows, rejouer les cas direct
      et repli dans OpenCode et vérifier la délégation dans ChatGPT Work.
- [ ] Comparer les décisions de délégation sur d'autres demandes ordinaires.
      Sur le premier rapprochement, les deux réponses directes ont échoué
      sur une liaison malgré une contradiction technique. Mesurer le coût
      total seulement avec des résultats de qualité comparable.
- [ ] Retester SM-11 dans des sessions neuves. Le premier rejeu laisse la
      prochaine étape implicite quand le correctif peut être proposé.
- [x] Commits revus publiés et CI vérifiée, alignement autorisé le 12/11/2026.

## Fait

- [x] Release GitHub obsolète retirée à la demande de l'utilisateur ; code actuel disponible sur main.

- [x] v1.0.0 : noyau, référence, 5 adaptateurs, templates, outils, CI.
- [x] Audit OpenCode 2 et corrections locales de documentation, sécurité et tests.
- [x] Audit des mécanismes intrinsèques et distinction entre corrections et refonte normative.
- [x] Branche locale SM-12 : routage vérifié dans Codex CLI et délégation locale
      vérifiée dans OpenCode avec Ollama. Périmètre des essais dans le journal.
- [x] Traitement direct observé avec le réglage Codex habituel. Erreur de
      rapprochement reproduite et contrôlée dans les deux sources.
- [x] Premier rejeu du bilan SM-11 sur deux cas fictifs dans Codex.

## Limites

Pas de document maître propre au dépôt : poursuite sans création explicitement
demandée par l'utilisateur le 12/11/2026, déviation consignée dans le journal.
Version revue publiée ; CI Windows/Linux réussie, preuves dans le journal. Les installations utilisateur restent distinctes.
