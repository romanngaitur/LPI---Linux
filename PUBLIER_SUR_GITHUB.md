# Publier LPI for Linux sur GitHub

Ce document décrit la procédure recommandée pour publier une version propre du projet.

## 1. Structure recommandée

Le dépôt doit contenir au minimum :

```text
LPI---Linux/
├── lpi.sh
├── README.md
├── CHANGELOG.md
├── LICENSE
├── SECURITY.md
├── CONTRIBUTING.md
├── .gitignore
├── .editorconfig
├── .github/
│   └── workflows/
│       └── shellcheck.yml
└── docs/
    ├── Page d'accueil .png
    └── Menu principal.png
```

Les captures peuvent être renommées plus tard en noms sans espaces, par exemple :

```text
docs/screenshot-accueil.png
docs/screenshot-menu.png
```

## 2. Vérifier le script

Depuis le dossier du projet :

```bash
bash -n lpi.sh
```

Si ShellCheck est installé :

```bash
shellcheck lpi.sh
```

Tester ensuite :

```bash
./lpi.sh --help
./lpi.sh --version
sudo ./lpi.sh --dry-run
sudo ./lpi.sh --auto --dry-run
```

## 3. Initialiser Git

Si le dépôt n'est pas encore initialisé :

```bash
git init
git branch -M main
git add .
git commit -m "release: LPI for Linux v1.0.0"
```

## 4. Ajouter le dépôt distant

Si tu conserves le dépôt actuel :

```bash
git remote add origin https://github.com/romanngaitur/LPI---Linux.git
```

Puis :

```bash
git push -u origin main
```

Si tu renommes le dépôt en `lpi-for-linux`, utilise l'URL correspondante.

## 5. Créer la release

Créer le tag :

```bash
git tag -a v1.0.0 -m "LPI for Linux v1.0.0"
git push origin v1.0.0
```

Puis créer une Release GitHub à partir de `v1.0.0`.

## 6. Description GitHub recommandée

**Description :**

> Debian post-install assistant written in Bash with whiptail. Secure package selection, profiles, dry-run and automated provisioning.

**Topics :**

```text
bash
debian
linux
whiptail
apt
system-administration
post-install
linux-administration
shell-script
open-source
```

## 7. Avant une release publique

Vérifier :

- [ ] `bash -n lpi.sh`
- [ ] ShellCheck sans erreur
- [ ] README à jour
- [ ] CHANGELOG à jour
- [ ] SECURITY.md présent
- [ ] LICENSE présent
- [ ] aucune clé/API/password dans le dépôt
- [ ] aucun fichier `/etc/lpi/choix.conf`
- [ ] aucun log système
- [ ] aucun rapport personnel
- [ ] test dans une VM Debian
- [ ] test du `--dry-run`
- [ ] test du mode `--auto`
- [ ] test UFW sur une machine de test
- [ ] test du comportement SSH
- [ ] test des groupes Docker/libvirt
- [ ] GitHub Actions verte

## 8. Ne jamais publier

Ne poussez jamais :

```text
.env
.env.*
/etc/lpi/choix.conf
/var/log/lpi_install.log
/root/lpi_rapport_*.txt
```

ou toute donnée contenant :

- mots de passe ;
- tokens ;
- clés privées ;
- informations personnelles ;
- secrets de serveurs.
