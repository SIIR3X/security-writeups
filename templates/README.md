# Template LaTeX des rapports

Tous les rapports du dépôt partagent la même mise en forme, définie ici.

## Fichiers

- `preambule.tex` — préambule commun : paquets, palette, style des blocs de
  code, encadrés (`keybox`, `warnbox`), macro de capture `\shot`, page de
  garde `\makecover`. **Inclus** par chaque rapport, jamais compilé seul.
- `rapport-securite.tex` — modèle vierge à copier pour démarrer un rapport.

## Créer un nouveau rapport

1. Copier le modèle dans l'arborescence par classe de vulnérabilité :

   ```
   <classe>/<slug>/<slug>.tex        # copie de templates/rapport-securite.tex
   <classe>/<slug>/images/           # captures numérotées 01, 02, …
   ```

2. Remplir la page de garde (`\makecover`) et les sections.
3. Insérer les captures avec `\shot{01-nom.png}{Légende.}` (fichiers dans
   `images/`).

## Compiler

Depuis le dossier du rapport (le chemin `\input` suppose deux niveaux sous la
racine) :

```bash
latexmk -pdf <slug>.tex      # recommandé
# ou :
pdflatex <slug>.tex          # à lancer deux fois pour la table des matières
```

Moteur : **pdflatex** (encodage `utf8` + `fontenc T1` + `lmodern`).

## Briques disponibles

| Brique | Usage |
|---|---|
| `\makecover{titre}{sous-titre}{lignes}{auteur}{date}` | page de garde + sommaire |
| `\metarow{Étiquette}{Valeur}` | une ligne de l'encadré méta |
| `\shot{fichier.png}{légende}` | capture + légende en italique |
| `lstlisting` | bloc de code encadré |
| `keybox` | encadré « point clé » (bleu) |
| `warnbox` | encadré « attention » (orange) |
