# Installation du pack GitHub

Cette archive est déjà structurée pour être déposée dans la racine de `LPI---Linux`.

## Important

Décompresse l'archive puis envoie **tout le contenu**, y compris `.github/`.

Tu ne dois pas envoyer l'archive `.zip` elle-même.

Structure principale :

```text
.github/
├── ISSUE_TEMPLATE/
├── workflows/
├── dependabot.yml
└── pull_request_template.md
lpi.sh
README.md
SECURITY.md
CONTRIBUTING.md
CODE_OF_CONDUCT.md
SECURITY_CHECKLIST.md
CHANGELOG.md
LICENSE
.gitignore
.editorconfig
```

Avant utilisation sur une vraie machine :

```bash
bash -n lpi.sh
shellcheck lpi.sh
chmod +x lpi.sh
./lpi.sh --help
./lpi.sh --dry-run
```

Teste d'abord dans une VM Debian.

Après publication, active dans les réglages GitHub les protections disponibles :
Dependabot alerts, Dependabot security updates, Dependabot version updates,
Private vulnerability reporting et, si disponible, Secret scanning / push protection.

Protège ensuite `main` avec une Pull Request et le workflow de sécurité obligatoire.
