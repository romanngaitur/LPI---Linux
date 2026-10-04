# Contributing to LPI for Linux

Merci de vouloir contribuer à LPI for Linux !

Le projet privilégie les contributions simples, lisibles, documentées et sûres.

## Avant de commencer

Lisez :

- `README.md`
- `SECURITY.md`
- `CHANGELOG.md`

Pour une vulnérabilité de sécurité, ne créez pas d'issue publique détaillée.

## Principes du projet

Les modifications doivent privilégier :

- la sécurité ;
- la lisibilité ;
- la compatibilité Debian ;
- la simplicité ;
- la gestion explicite des erreurs ;
- l'absence d'effets de bord inattendus.

LPI étant exécuté avec des privilèges élevés, une modification apparemment mineure peut avoir un impact important.

## Modifier le catalogue

Lorsque vous ajoutez un paquet :

1. vérifiez qu'il existe dans les dépôts Debian ciblés ;
2. placez-le dans la catégorie appropriée ;
3. évitez les doublons ;
4. vérifiez son comportement sur une VM Debian ;
5. documentez les éventuelles dépendances ou dépôts tiers.

Les paquets provenant de dépôts tiers doivent être clairement identifiés.

## Modifier une opération système

Pour toute modification touchant :

- APT ;
- UFW ;
- SSH ;
- `systemctl` ;
- utilisateurs ;
- groupes ;
- permissions ;
- fichiers sous `/etc` ;

ajoutez une validation et un comportement d'échec propre.

Évitez absolument :

```bash
eval "$USER_INPUT"
```

ou toute construction de commande shell à partir d'une entrée utilisateur non validée.

## Tests

Avant de soumettre une Pull Request :

```bash
bash -n lpi.sh
shellcheck lpi.sh
```

Puis :

```bash
./lpi.sh --help
./lpi.sh --version
sudo ./lpi.sh --dry-run
sudo ./lpi.sh --auto --dry-run
```

Les modifications APT/UFW/utilisateurs doivent être testées dans une VM ou une machine de test.

## Pull Requests

Une Pull Request doit expliquer :

- le problème ;
- la solution ;
- les fichiers modifiés ;
- les tests effectués ;
- les éventuels risques.

Exemple de titre :

```text
fix: validate persisted package selections
```

ou :

```text
feat: add Debian server profile
```

## Style Bash

Conservez :

- des fonctions courtes ;
- des variables explicites ;
- des guillemets autour des expansions lorsqu'ils sont nécessaires ;
- des tableaux Bash pour les listes ;
- des codes de retour vérifiés ;
- des commentaires lorsqu'une logique est non évidente.

Utilisez ShellCheck pour détecter les erreurs courantes.

## Commits

Préférez des commits ciblés :

```text
fix: harden config parser
docs: improve installation guide
test: add dry-run checks
feat: add server profile
```

Évitez les commits mélangeant une refonte complète, une fonctionnalité et des changements de documentation sans rapport.

## Licence

En contribuant au projet, vous acceptez que votre contribution soit distribuée sous la licence du projet.
