# Rapports de sécurité

Études pratiques de sécurité offensive. Chaque rapport suit une seule faille, de
la reconnaissance à l'exploitation, puis en détaille l'impact et la remédiation.

Tout est réalisé légalement sur des plateformes d'entraînement dédiées
(PortSwigger Web Security Academy, machines retirées de Hack The Box, ou labs
montés en local). Rien ici ne vise un système sans autorisation explicite.

## Rapports

| Rapport (PDF) | Classe | CWE | OWASP | Plateforme |
|---|---|---|---|---|

## Organisation

Un dossier par rapport, regroupé par classe de vulnérabilité :

```
<classe>/<slug>/
  <slug>.tex     la source LaTeX du rapport
  <slug>.pdf     le rapport compilé, en français
  images/        les captures d'écran, numérotées
```

Chaque PDF suit la même structure : page de garde, table des matières, puis
Contexte, Reconnaissance, Exploitation, Impact et Remédiation.

## Compilation

Tous les rapports partagent une mise en forme commune définie dans
[`templates/`](templates/) (préambule + modèle vierge). Pour (re)générer un
PDF, depuis le dossier du rapport :

```bash
latexmk -pdf <slug>.tex      # moteur pdflatex
```

Voir [`templates/README.md`](templates/README.md) pour créer un nouveau rapport.

## Licence

Publié sous [licence MIT](LICENSE).
