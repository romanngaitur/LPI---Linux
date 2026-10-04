# Changelog

Toutes les modifications notables de **LPI for Linux** sont documentées dans ce fichier.

Le format suit les principes de [Keep a Changelog](https://keepachangelog.com/fr-FR/1.1.0/) et les versions suivent [Semantic Versioning](https://semver.org/lang/fr/).

## [1.0.0] - 2026-10-04

### Sécurité

- Remplacement du chargement direct de la configuration par une validation des données.
- La configuration persistée n'est plus exécutée comme du code Bash.
- Validation stricte des paquets avant installation.
- Validation des utilisateurs avant modification des groupes.
- Protection renforcée du mode `--auto`.
- Gestion plus prudente de l'activation d'UFW.
- Préservation du port SSH détecté lorsque le pare-feu est configuré.
- Avertissements renforcés concernant les groupes `docker`, `libvirt` et `kvm`.
- Suppression de l'utilisation de noms temporaires non réservés de manière atomique.
- Nettoyage renforcé des fichiers et ressources temporaires.
- Permissions restrictives pour les fichiers de configuration et rapports.

### Robustesse

- Gestion améliorée des verrous APT/dpkg.
- Échec propre lorsque le gestionnaire de paquets reste indisponible.
- Validation des arguments de ligne de commande.
- Meilleure gestion des erreurs d'installation.
- Amélioration du mode `--dry-run`.
- Nettoyage fiable en cas d'interruption.

### Documentation

- Nouveau README orienté utilisateur et contributeur.
- Ajout de `SECURITY.md`.
- Ajout de `CONTRIBUTING.md`.
- Mise à jour du guide de publication GitHub.
- Documentation de l'impact des groupes privilégiés.
- Documentation des risques liés à UFW et SSH.

### CI

- Ajout d'un workflow GitHub Actions pour `bash -n` et ShellCheck.

## [0.1.0] - 2026-10-04

### Ajouté

- Première version publique de LPI for Linux.
- Interface `whiptail`.
- Catégories de logiciels.
- Profils prédéfinis.
- Mémorisation des choix.
- Journal d'installation.
- Rapport de session.
- Mode `--auto`.
- Mode `--dry-run`.
- Support français / anglais.
- Vérifications préalables.
- Licence MIT.
