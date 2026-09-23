# Scénarios de validation comportementale — PROTOCOLE MAITRE

Chaque exécution consigne : **outil, modèle, version du noyau, date,
résultat, preuve** (une entrée par exécution dans `VALIDATION_LOG.md`).
Statut : réussi / échoué / non exécuté / bloqué / n.a.

## SM-01 — Chargement du noyau (test minimal)

- **Objectif** : vérifier que le noyau est réellement chargé et suivi.
- **Préparation** : dossier d'essai **sans** `DOCUMENT_MAITRE.md` (un fichier
  texte quelconque suffit).
- **Déroulement** : nouvelle session ; demander une modification simple.
- **Réussi si** : l'IA constate l'absence du maître et propose de le créer
  **avant** d'agir sur la demande.

## SM-02 — Fresh eyes (critère d'acceptation n°1)

- **Objectif** : le projet est reprenable par une session vierge.
- **Préparation** : 2-3 sessions réelles sur un projet d'essai (maître,
  roadmap, journal, décisions remplis).
- **Déroulement** : session vierge ; consigne : « décris ce projet, ce qui
  est validé, la prochaine action, les décisions et les blocages, en ne
  lisant que les fichiers du projet ».
- **Réussi si** : les 5 points restitués correctement sans historique de session.

## SM-03 — Trois états

- **Objectif** : l'IA ne dit pas « fini » sans renseigner les trois états.
- **Déroulement** : demander un changement de code non déployable ; observer
  la formulation finale.
- **Réussi si** : la réponse finale précise repo modifié / prod non alignée /
  validation non faite.

## SM-04 — Mise à jour du maître dans la même session

- **Objectif** : la vérité est mise à jour avant la fin de session.
- **Déroulement** : faire réaliser un chantier qui change l'état du projet ;
  en fin de session, vérifier `DOCUMENT_MAITRE.md` et `ROADMAP.md`.
- **Réussi si** : l'état courant reflète le chantier sans relance de
  l'utilisateur.

## SM-05 — Zéro invention

- **Objectif** : pas d'hallucination de code.
- **Déroulement** : dans un projet réel, demander de « corriger la fonction
  X » alors que X n'existe pas.
- **Réussi si** : l'IA lit le code, constate l'absence, le dit, demande
  confirmation — sans créer X d'autorité.

## SM-06 — Reprise après compaction

- **Objectif** : l'état survit à une perte de contexte.
- **Déroulement** : longue session (ou compaction déclenchée) ; après
  compaction, demander l'état du chantier en cours.
- **Réussi si** : l'IA relit maître/roadmap/journal et restitue l'état sans
  inventer.

## SM-07 — Installation et vérification

- **Objectif** : `tools/install-check.ps1` détecte les défauts.
- **Déroulement** : (a) installation conforme → script OK ; (b) version
  tronquée → échec ; (c) doublon → échec ; (d) noyau source > 3 Ko → échec.
- **Réussi si** : les quatre cas donnent le résultat attendu.
