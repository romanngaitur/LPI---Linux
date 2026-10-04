# 🐧 LPI for Linux

**Linux Post Install** — un assistant Bash interactif pour préparer rapidement une machine Debian avec une sélection contrôlée de logiciels, d'outils de développement, de services, de sécurité et de virtualisation.

LPI for Linux utilise **Bash + whiptail + APT** et privilégie une approche simple, lisible et orientée sécurité.

> ⚠️ **Important :** LPI for Linux effectue des modifications système et doit être exécuté avec les privilèges `root`. Testez-le d'abord dans une machine virtuelle ou sur une machine de test.

---

## ✨ Fonctionnalités

- 🖥️ Interface terminal interactive avec `whiptail`
- 🇫🇷 / 🇬🇧 Interface française et anglaise
- 📦 Installation de paquets Debian par catégories
- 🎯 Profils prédéfinis pour accélérer la configuration
- 🔁 Mémorisation sécurisée des choix
- 🤖 Mode automatique `--auto`
- 🧪 Mode simulation `--dry-run`
- 🔐 Validation stricte des paquets et des utilisateurs
- 🧱 Protection de la configuration contre l'exécution de commandes arbitraires
- 🔥 Gestion prudente d'UFW et du port SSH
- 📝 Journal d'installation et rapport de session
- 🔎 Vérifications préalables de l'environnement
- 🧹 Nettoyage des fichiers temporaires après interruption
- 🐳 Gestion des groupes Docker avec avertissement de sécurité
- 🧰 Conçu pour rester facilement modifiable et extensible

---

## 🎯 Objectif du projet

L'objectif de LPI for Linux est de proposer un **post-installateur Debian pratique et transparent**.

Au lieu de mémoriser et exécuter manuellement une longue liste de commandes après l'installation d'un système, LPI permet de sélectionner ce dont on a besoin depuis une interface terminal.

Le projet reste volontairement en **Bash** afin d'être :

- facile à lire ;
- facile à modifier ;
- facile à distribuer ;
- adapté aux environnements Debian minimaux ;
- utile comme base d'apprentissage de l'administration Linux et du scripting Bash.

---

## 🖥️ Compatibilité

### Support principal

- Debian 12
- Debian 13
- systèmes Debian utilisant APT

### Compatibilité possible

Les distributions dérivées de Debian peuvent fonctionner si elles conservent une organisation compatible avec :

- `apt`
- `apt-get`
- `dpkg`
- `systemd`
- `/etc/os-release`

Cependant, elles ne sont pas toutes testées.

> Ubuntu et les autres dérivées Debian peuvent fonctionner, mais Debian reste la cible principale du projet.

---

## 📋 Prérequis

LPI nécessite :

- Linux basé sur Debian ;
- Bash ;
- `apt-get` ;
- `dpkg` ;
- `sudo` pour l'exécution non-root ;
- une connexion réseau pour télécharger les paquets ;
- `whiptail` pour l'interface interactive.

Le script vérifie les prérequis nécessaires au démarrage.

---

## 🚀 Installation

### Avec Git

```bash
git clone https://github.com/romanngaitur/LPI---Linux.git
cd LPI---Linux
chmod +x lpi.sh
```

Puis :

```bash
sudo ./lpi.sh
```

### Sans Git

Téléchargez `lpi.sh`, puis :

```bash
chmod +x lpi.sh
sudo ./lpi.sh
```

---

## 🧪 Tester sans modifier le système

Avant toute utilisation réelle, il est recommandé de commencer par :

```bash
sudo ./lpi.sh --dry-run
```

Le mode simulation permet de vérifier les actions prévues sans appliquer les modifications système prises en charge par LPI.

Pour tester le mode automatique :

```bash
sudo ./lpi.sh --auto --dry-run
```

> Le mode `--dry-run` est un mécanisme de sécurité, mais il ne remplace pas un test dans une machine virtuelle.

---

## 🤖 Mode automatique

LPI peut rejouer la configuration précédemment enregistrée :

```bash
sudo ./lpi.sh --auto
```

Pour une utilisation non interactive :

```bash
sudo ./lpi.sh --auto --lang=en
```

Le mode automatique utilise uniquement les valeurs de configuration que LPI sait reconnaître. La configuration n'est **jamais exécutée comme du code Bash**.

---

## 🌍 Langues

Français :

```bash
sudo ./lpi.sh --lang=fr
```

Anglais :

```bash
sudo ./lpi.sh --lang=en
```

---

## 🧰 Options

| Option | Description |
|---|---|
| `--auto` | Rejoue la configuration enregistrée sans interface interactive |
| `--dry-run` | Simule les actions sans appliquer les modifications prévues |
| `--lang=fr` | Interface française |
| `--lang=en` | Interface anglaise |
| `-h`, `--help` | Affiche l'aide |
| `-v`, `--version` | Affiche la version |

Exemples :

```bash
sudo ./lpi.sh --help
sudo ./lpi.sh --version
sudo ./lpi.sh --dry-run
sudo ./lpi.sh --lang=en
sudo ./lpi.sh --auto --dry-run
```

---

## 📦 Catégories

LPI organise les logiciels par familles afin d'éviter une installation massive et difficile à contrôler.

### Mise à jour

Gestion des opérations APT telles que :

- mise à jour de l'index ;
- mise à niveau des paquets ;
- nettoyage optionnel.

### Utilitaires

Exemples :

- `git`
- `vim`
- `nano`
- `htop`
- `tmux`
- `curl`
- `wget`
- outils système

### Sécurité et réseau

Exemples :

- `ufw`
- `fail2ban`
- `openssh-server`
- `nmap`
- `wireguard`

### Développement

Exemples :

- `build-essential`
- Python
- Node.js
- Git
- Docker

### Internet et communication

Exemples :

- navigateur ;
- outils réseau ;
- clients mail ;
- gestionnaires de mots de passe.

### Multimédia et bureautique

Exemples :

- VLC ;
- GIMP ;
- LibreOffice ;
- outils graphiques.

### Sécurité offensive

Des outils de sécurité et de test peuvent être proposés.

> ⚠️ Utilisez ces outils uniquement sur des systèmes et réseaux pour lesquels vous disposez d'une autorisation.

### Serveurs

Exemples :

- Nginx ;
- MariaDB ;
- PHP-FPM ;
- Certbot.

### Virtualisation et conteneurs

Exemples :

- KVM/QEMU ;
- libvirt ;
- Docker ;
- Podman.

### Nettoyage

Opérations APT de nettoyage, proposées explicitement.

---

## 👤 Utilisateurs et groupes privilégiés

Certaines fonctionnalités peuvent ajouter un utilisateur à des groupes puissants.

### Groupe Docker

L'appartenance au groupe `docker` peut permettre d'obtenir des privilèges équivalents à `root`.

LPI ne considère donc pas cette opération comme anodine et la traite comme une modification privilégiée.

### KVM / libvirt

Les groupes `kvm` et `libvirt` donnent également des privilèges supplémentaires sur le système.

Vérifiez toujours les groupes ajoutés avant de continuer.

---

## 🔥 Pare-feu et SSH

L'activation d'UFW peut avoir des conséquences importantes sur une machine distante.

LPI vérifie le service SSH et cherche à préserver le port SSH utilisé avant d'appliquer les règles de pare-feu.

Sur un serveur distant, vérifiez toujours le résultat avant de fermer votre session.

Pour un serveur web, les ports nécessaires peuvent également être pris en compte lorsque les services correspondants sont sélectionnés.

> **Recommandation :** faites votre premier test UFW depuis une console locale ou une console de récupération de votre hébergeur.

---

## 🔐 Sécurité

LPI est exécuté avec `root`. La sécurité du script est donc une priorité du projet.

Principes appliqués :

- configuration traitée comme des données ;
- pas d'exécution directe du fichier de configuration ;
- validation des valeurs persistées ;
- validation des noms de paquets ;
- validation des utilisateurs ;
- permissions restrictives pour les fichiers sensibles ;
- répertoire temporaire sécurisé ;
- nettoyage des ressources avec `trap` ;
- refus des options CLI inconnues ;
- contrôle des verrous APT/dpkg ;
- validation de l'environnement avant modification.

### Signaler une vulnérabilité

Consultez [`SECURITY.md`](SECURITY.md) avant de publier une vulnérabilité dans une issue publique.

---

## 📁 Fichiers et données locales

Selon l'installation et les opérations effectuées, LPI utilise notamment :

```text
/etc/lpi/
└── choix.conf

/var/log/
└── lpi_install.log

/root/
└── lpi_rapport_<date>.txt
```

Ces fichiers peuvent contenir des informations sur les opérations effectuées sur la machine.

Ils doivent rester accessibles uniquement aux utilisateurs autorisés.

---

## 🧪 Vérification avant contribution

Avant de proposer une modification :

```bash
bash -n lpi.sh
```

Si ShellCheck est disponible :

```bash
shellcheck lpi.sh
```

Testez également :

```bash
./lpi.sh --help
./lpi.sh --version
sudo ./lpi.sh --dry-run
sudo ./lpi.sh --auto --dry-run
```

Pour les changements concernant APT, UFW, les utilisateurs ou les groupes, utilisez de préférence une **VM Debian de test**.

---

## 🏗️ Structure du dépôt

```text
LPI---Linux/
├── lpi.sh
├── README.md
├── CHANGELOG.md
├── LICENSE
├── SECURITY.md
├── CONTRIBUTING.md
├── PUBLIER_SUR_GITHUB.md
├── .gitignore
├── .editorconfig
├── .github/
│   └── workflows/
│       └── shellcheck.yml
└── docs/
    ├── Page d'accueil .png
    └── Menu principal.png
```

---

## 🤝 Contribuer

Les contributions sont les bienvenues.

Vous pouvez :

- corriger un bug ;
- améliorer la sécurité ;
- ajouter un paquet au catalogue ;
- améliorer l'interface ;
- ajouter une traduction ;
- améliorer la documentation ;
- proposer un nouveau profil ;
- ajouter des tests.

Voir [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

## 📜 Licence

LPI for Linux est distribué sous licence **MIT**.

Vous pouvez :

- utiliser le logiciel ;
- le copier ;
- le modifier ;
- le redistribuer ;
- l'utiliser dans un projet commercial.

Consultez [`LICENSE`](LICENSE) pour le texte complet.

---

## ⚠️ Avertissement

Ce logiciel modifie la configuration du système.

L'auteur et les contributeurs ne peuvent pas garantir que le script sera adapté à chaque environnement, serveur, hébergeur, distribution dérivée ou configuration particulière.

**Utilisez-le à vos propres risques et sauvegardez vos données importantes avant toute modification système.**

---

## 👨‍💻 Auteur

**Roman Gaitur**

Projet libre et communautaire.

Les contributions, retours, rapports de bugs et améliorations sont les bienvenus.

---

## ⭐ Soutenir le projet

Si LPI for Linux vous est utile :

- ⭐ ajoutez une étoile au dépôt ;
- 🐛 signalez les bugs ;
- 💡 proposez des améliorations ;
- 🔧 envoyez des Pull Requests ;
- 📖 améliorez la documentation.

Merci de contribuer au projet !
