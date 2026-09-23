# Roadmap — PROTOCOLE MAITRE (backlog du protocole lui-même)

## En cours

- [ ] Exécuter les scénarios restants : SM-01…SM-06 (SM-07 déjà exécuté).

## À faire

- [ ] Décider : pointeurs dans les README des 3 anciens repos.

## Fait

- [x] Design validé (DESIGN.md, décisions D1-D13).
- [x] NOYAU.md (3 004 octets) + PROTOCOLE.md (référence) + 5 adaptateurs.
- [x] Templates projet + install-check.ps1 + CI.
- [x] Publication GitHub : repo public, push `main`, tag `v1.0.0-candidate` (release stable après scénarios).
- [x] Skill `protocole-maitre` créée et active dans DeepSeek Harness.
- [x] Sécurité : noyau bloc 9 enrichi, référence §8, pre-push-audit.ps1, scan CI.
- [x] SM-07 exécuté : 4/4 cas conformes.
- [x] Auto-chargement global activé dans DeepSeek Harness (`$DSH_HOME/AGENTS.md`, mécanisme natif vérifié).
- [x] Contrat d'intégration déléguée documenté (README) : tout agent peut intégrer sans aide.

## Bloqué

(néant)
