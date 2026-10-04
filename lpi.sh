#!/bin/bash
# =====================================================================
# LPI for Linux v1.0 - Linux Post Install
# Base conservée depuis la version 0.1, avec durcissement sécurité.
# =====================================================================
umask 077

LPI_VERSION="1.0"
LPI_AUTEUR="Roman Gaitur"
CONF_DIR="/etc/lpi"
CONF_FILE="$CONF_DIR/choix.conf"
LOG_FILE="/var/log/lpi_install.log"
TMP_DIR=""
F_TMP=""
GAUGE_PIPE=""
GAUGE_PID=""
REPORT_FILE=""
DRY_RUN=0
AUTO_MODE=0
LANG_CHOICE="fr"
SHOW_HELP=0
SHOW_VERSION=0
STATUS=0
CONFIG_RESTAUREE="non"
TARGET_USER=""
FAILED=()
RESUME=""

for arg in "$@"; do
    case "$arg" in
        --help|-h) SHOW_HELP=1 ;;
        --version|-v) SHOW_VERSION=1 ;;
        --auto) AUTO_MODE=1 ;;
        --dry-run) DRY_RUN=1 ;;
        --lang=en) LANG_CHOICE="en" ;;
        --lang=fr) LANG_CHOICE="fr" ;;
        *) echo "Option inconnue : $arg" >&2; exit 2 ;;
    esac
done

declare -A L
L[cat1]="Mise à jour du système"
L[cat2]="Utilitaires essentiels"
L[cat3]="Sécurité et Réseau"
L[cat4]="Outils de développement"
L[cat5]="Internet et communication"
L[cat6]="Multimédia et bureautique"
L[cat7]="Sécurité offensive (pentest)"
L[cat8]="Serveurs"
L[cat9]="Virtualisation / Conteneurs"
L[cat10]="Nettoyage du système"
L[menu_profiles]="Profils prédéfinis"
L[menu_help]="Aide"
L[menu_reset]="Réinitialiser tous mes choix"
L[menu_install]="==> DÉMARRER L'INSTALLATION <=="
L[menu_quit]="Quitter (les choix restent mémorisés)"
L[menu_prompt]="Sélectionnez une catégorie, ou lancez l'installation."
L[menu_by]="par"
L[btn_accept]="Accepter"
L[btn_quit]="Quitter"
L[btn_continue]="Continuer"
L[btn_back_menu]="Retour au menu"
L[choisis]="choisi(s)"
L[confirm_reset_title]="Réinitialisation"
L[confirm_reset_q]="Remettre tous les choix par défaut ?"
L[confirm_install_title]="Confirmer l'installation"
L[confirm_install_q]="Lancer l'installation ?"
L[pentest_warn_title]="Avertissement"
L[distro_warn_title]="Distribution non testée"
L[network_warn_title]="Pas de connexion réseau"
L[final_title]="LPI - Terminé"
L[final_success]="Installation terminée avec succès !"
L[final_failed_prefix]="Installation terminée, mais"
L[final_failed_suffix]="élément(s) n'ont pas pu être traité(s) (voir le journal)."
L[final_log]="Journal :"
L[final_conf]="Choix mémorisés :"
L[final_report]="Rapport :"
L[closing]="LPI fermé. Vos choix ont été conservés dans"
L[profiles_title]="Profils prédéfinis"
L[profile_dev]="Poste de développement"
L[profile_web]="Serveur web"
L[profile_office]="Poste bureautique"
L[profile_minimal]="Minimal (réinitialiser)"
L[profile_back]="Retour"
L[profile_applied]="Profil appliqué. Vous pouvez encore ajuster chaque catégorie avant de lancer l'installation."
L[prompt_target_user]="Nom de l'utilisateur à ajouter aux groupes privilégiés (docker, libvirt/kvm) :"
L[dryrun_banner]="MODE SIMULATION (--dry-run) : aucune modification système ne sera effectuée."
L[err_root]="Erreur : veuillez exécuter ce script en tant que root."
L[gauge_title]="LPI - Installation en cours"
L[gauge_prep]="Préparation..."
L[gauge_done]="Terminé."
L[security_warning]="ATTENTION : cette action modifie la configuration système avec les privilèges root."

load_lang_en() {
    L[cat1]="System update"; L[cat2]="Essential utilities"; L[cat3]="Security & Network"
    L[cat4]="Development tools"; L[cat5]="Internet & communication"; L[cat6]="Multimedia & office"
    L[cat7]="Offensive security (pentest)"; L[cat8]="Servers"; L[cat9]="Virtualization / Containers"
    L[cat10]="System cleanup"; L[menu_profiles]="Preset profiles"; L[menu_help]="Help"
    L[menu_reset]="Reset all my choices"; L[menu_install]="==> START INSTALLATION <=="
    L[menu_quit]="Quit (choices are kept)"; L[menu_prompt]="Select a category, or start the installation."
    L[menu_by]="by"; L[btn_accept]="Accept"; L[btn_quit]="Quit"; L[btn_continue]="Continue"
    L[btn_back_menu]="Back to menu"; L[choisis]="selected"; L[confirm_reset_title]="Reset"
    L[confirm_reset_q]="Restore all choices to their defaults?"; L[confirm_install_title]="Confirm installation"
    L[confirm_install_q]="Start the installation?"; L[pentest_warn_title]="Warning"
    L[distro_warn_title]="Untested distribution"; L[network_warn_title]="No network connection"
    L[final_title]="LPI - Done"; L[final_success]="Installation completed successfully!"
    L[final_failed_prefix]="Installation completed, but"; L[final_failed_suffix]="item(s) could not be processed (see the log)."
    L[final_log]="Log:"; L[final_conf]="Saved choices:"; L[final_report]="Report:"
    L[closing]="LPI closed. Your choices were kept in"; L[profiles_title]="Preset profiles"
    L[profile_dev]="Development workstation"; L[profile_web]="Web server"; L[profile_office]="Office workstation"
    L[profile_minimal]="Minimal (reset)"; L[profile_back]="Back"
    L[profile_applied]="Profile applied. You can still adjust each category before starting the installation."
    L[prompt_target_user]="Username to add to privileged groups (docker, libvirt/kvm):"
    L[dryrun_banner]="SIMULATION MODE (--dry-run): no system modification will be performed."
    L[err_root]="Error: please run this script as root."
    L[gauge_title]="LPI - Installation in progress"; L[gauge_prep]="Preparing..."
    L[gauge_done]="Done."; L[security_warning]="WARNING: this action changes the system with root privileges."
}
[ "$LANG_CHOICE" = "en" ] && load_lang_en

if [ "$LANG_CHOICE" = "en" ]; then
    PENTEST_WARN_BODY="These tools (scanning, password cracking, etc.) must only be used on systems you own or are explicitly authorized to test."
else
    PENTEST_WARN_BODY="Ces outils (scan, cassage de mots de passe, etc.) ne doivent être utilisés que sur vos propres systèmes ou avec une autorisation explicite."
fi

HELP_TXT="LPI for Linux v$LPI_VERSION - $LPI_AUTEUR

Usage : sudo ./lpi.sh [options]

Options :
  --auto          Installe la configuration mémorisée sans menu.
  --dry-run       Simule les actions sans modifier le système.
  --lang=fr|en    Langue de l'interface.
  -h, --help      Affiche cette aide.
  -v, --version   Affiche la version.

Sécurité :
  - La configuration mémorisée est traitée comme des données, jamais comme du code.
  - Seuls les paquets présents dans le catalogue LPI peuvent être installés.
  - Les noms d'utilisateurs sont validés avant toute modification de groupes.
  - UFW détecte le port SSH actif avant de modifier le pare-feu.
  - Les fichiers temporaires et journaux sont créés avec des permissions restrictives.

Fichiers :
  $CONF_FILE
  $LOG_FILE
  /root/lpi_rapport_<date>.txt"

if [ "$SHOW_VERSION" = "1" ]; then
    echo "LPI for Linux v$LPI_VERSION - $LPI_AUTEUR"
    exit 0
fi
if [ "$SHOW_HELP" = "1" ]; then
    echo "$HELP_TXT"
    exit 0
fi
if [ "$EUID" -ne 0 ]; then
    echo "${L[err_root]}" >&2
    exit 1
fi

cleanup() {
    local rc=$?
    exec 3>&- 2>/dev/null || true
    exec 4>&- 2>/dev/null || true
    exec 5>&- 2>/dev/null || true
    if [ -n "${GAUGE_PID:-}" ] && kill -0 "$GAUGE_PID" 2>/dev/null; then
        kill "$GAUGE_PID" 2>/dev/null || true
        wait "$GAUGE_PID" 2>/dev/null || true
    fi
    [ -n "${GAUGE_PIPE:-}" ] && rm -f -- "$GAUGE_PIPE"
    [ -n "${F_TMP:-}" ] && rm -f -- "$F_TMP"
    [ -n "${TMP_DIR:-}" ] && rm -rf -- "$TMP_DIR"
    exit "$rc"
}
trap cleanup EXIT HUP INT TERM

TMP_DIR="$(mktemp -d /tmp/lpi.XXXXXX)" || exit 1
chmod 700 "$TMP_DIR"
F_TMP="$TMP_DIR/dialog"
: > "$F_TMP"
chmod 600 "$F_TMP"

export NEWT_COLORS='
root=green,black
border=green,black
window=green,black
shadow=black,black
title=red,black
button=black,green
actbutton=black,red
checkbox=green,black
actcheckbox=black,red
entry=green,black
label=green,black
listbox=green,black
actlistbox=black,green
textbox=green,black
acttextbox=black,green
helpline=red,black
roottext=green,black
emptyscale=black,green
fullscale=red,green
disabledentry=green,black
'

TERM_LINES="$(tput lines 2>/dev/null || true)"
TERM_COLS="$(tput cols 2>/dev/null || true)"
TERM_LINES="${TERM_LINES:-24}"
TERM_COLS="${TERM_COLS:-80}"
dlg_size() {
    local h=$1 w=$2 maxh=$((TERM_LINES - 2)) maxw=$((TERM_COLS - 4))
    [ "$maxh" -lt 8 ] && maxh=8; [ "$maxw" -lt 40 ] && maxw=40
    [ "$h" -gt "$maxh" ] && h=$maxh; [ "$w" -gt "$maxw" ] && w=$maxw
    [ "$h" -lt 8 ] && h=8; [ "$w" -lt 40 ] && w=40
    printf '%s %s' "$h" "$w"
}

DISTRO_ID="unknown"
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"
fi

if [ "$AUTO_MODE" != "1" ] && ! command -v whiptail >/dev/null 2>&1; then
    echo "Installation de whiptail..."
    apt-get update -y && apt-get install -y whiptail || {
        echo "Impossible d'installer whiptail." >&2
        exit 1
    }
fi

if [ "$AUTO_MODE" != "1" ] && ! command -v whiptail >/dev/null 2>&1; then
    echo "whiptail est requis en mode interactif." >&2
    exit 1
fi

if [ "$DISTRO_ID" != "debian" ]; then
    if [ "$AUTO_MODE" = "1" ]; then
        echo "[!] Distribution non testée : $DISTRO_ID"
    else
        if [ "$LANG_CHOICE" = "en" ]; then
            DISTRO_WARN_BODY="This script is designed and tested for Debian.
Detected distribution: $DISTRO_ID
Some package names may differ. Continue anyway?"
        else
            DISTRO_WARN_BODY="Ce script est conçu et testé pour Debian.
Distribution détectée : $DISTRO_ID
Certains noms de paquets peuvent différer. Continuer ?"
        fi
        read -r H W <<< "$(dlg_size 12 66)"
        whiptail --title "${L[distro_warn_title]}" --yes-button "${L[btn_continue]}" \
            --no-button "${L[btn_quit]}" --yesno "$DISTRO_WARN_BODY" "$H" "$W" || exit 0
    fi
fi

ITEMS_UPDATE=(
    "update|Mettre à jour la liste des paquets"
    "upgrade|Installer les mises à jour"
    "full-upgrade|Mise à jour complète (gère les dépendances)"
)
ITEMS_UTILS=(
    "ca-certificates|Certificats racine (confiance HTTPS, essentiel)"
    "apt-transport-https|Accès HTTPS pour apt (compatibilité)"
    "wget|Téléchargement de fichiers" "curl|Transfert réseau" "git|Contrôle de version"
    "git-lfs|Git pour gros fichiers" "vim|Éditeur de texte (avancé)" "nano|Éditeur de texte (simple)"
    "htop|Moniteur système" "btop|Moniteur système moderne" "unzip|Extraction ZIP" "zip|Création ZIP"
    "p7zip-full|Archives 7z" "tar|Gestion archives TAR" "tree|Affichage arborescence"
    "jq|Traitement JSON" "ncdu|Analyse espace disque" "tmux|Multiplexeur de terminal"
    "rsync|Synchronisation de fichiers" "lsof|Liste des fichiers ouverts" "pciutils|Infos matériel PCI"
    "usbutils|Infos matériel USB" "bash-completion|Autocomplétion Bash"
    "software-properties-common|Gestion dépôts tiers" "zsh|Shell Zsh" "fzf|Recherche floue"
    "ripgrep|Recherche rapide" "fd-find|Recherche de fichiers" "bat|Affichage de fichiers"
    "neofetch|Infos système" "cowsay|Vache qui parle" "sl|Train fun" "figlet|Texte ASCII"
    "screen|Multiplexeur de terminal" "gparted|Partitionnement graphique" "synaptic|Gestionnaire de paquets"
    "timeshift|Sauvegardes système"
)
ITEMS_SEC=(
    "ufw|Pare-feu (SSH détecté automatiquement)" "fail2ban|Protection anti-bruteforce"
    "openssh-server|Serveur SSH" "net-tools|Commandes réseau" "dnsutils|Outils DNS"
    "nmap|Scanner réseau" "tcpdump|Capture de paquets" "traceroute|Suivi de route"
    "mtr-tiny|Diagnostic réseau" "iperf3|Test de débit" "whois|Informations de domaine"
    "wireguard|VPN WireGuard" "clamav|Antivirus ClamAV" "rkhunter|Détection de rootkits"
    "lynis|Audit de sécurité" "apparmor|Contrôle d'accès obligatoire" "auditd|Journalisation d'audit"
    "openvpn|Client/serveur VPN" "cryptsetup|Chiffrement LUKS" "gnupg|Chiffrement et signature GPG"
    "ssh-audit|Audit SSH" "arpwatch|Surveillance ARP" "iptables-persistent|Persistance iptables"
)
ITEMS_PENTEST=(
    "wireshark|Analyse de trafic réseau" "hydra|Test de robustesse de mots de passe"
    "john|Cassage de mots de passe" "hashcat|Cassage de hachages" "aircrack-ng|Audit Wi-Fi"
    "netcat-traditional|Outil réseau" "sqlmap|Test d'injection SQL" "gobuster|Découverte web"
    "nikto|Scanner web" "masscan|Scanner de ports rapide" "socat|Relais réseau"
    "steghide|Stéganographie" "binwalk|Analyse de firmwares" "exiftool|Métadonnées"
)
ITEMS_SERVER=(
    "nginx|Serveur web Nginx" "apache2|Serveur web Apache" "mariadb-server|MariaDB"
    "postgresql|PostgreSQL" "redis-server|Redis" "php-fpm|PHP-FPM"
    "certbot|Let's Encrypt" "samba|Partage Windows/Linux" "nfs-kernel-server|Partage NFS"
    "vsftpd|Serveur FTP" "bind9|Serveur DNS" "proftpd-basic|Serveur FTP alternatif"
    "supervisor|Gestionnaire de processus"
)
ITEMS_VIRT=(
    "qemu-kvm|Virtualisation KVM" "libvirt-daemon-system|Démon libvirt"
    "virt-manager|Gestionnaire de VM" "virtualbox|VirtualBox" "vagrant|Vagrant"
    "docker-compose|Orchestration Docker" "podman|Conteneurs sans démon"
)
ITEMS_DEV=(
    "build-essential|Compilateurs GCC/Make" "cmake|Build CMake" "gdb|Débogueur GNU"
    "shellcheck|Analyse de scripts shell" "python3|Python 3" "python3-venv|Environnements Python"
    "python3-pip|Gestionnaire Python" "nodejs|Node.js" "npm|Gestionnaire Node"
    "default-jdk|Java JDK" "golang-go|Go" "rustc|Rust" "cargo|Cargo"
    "php-cli|PHP CLI" "ruby|Ruby" "sqlite3|SQLite" "docker.io|Docker"
    "code|Visual Studio Code (dépôt tiers non inclus)" "neovim|Neovim" "meld|Comparateur"
    "maven|Build Java" "perl|Perl" "lua5.4|Lua" "composer|Composer"
    "yarnpkg|Gestionnaire Node alternatif" "clang|LLVM/Clang" "valgrind|Détection fuites mémoire"
)
ITEMS_WEB=(
    "firefox-esr|Navigateur Firefox ESR" "chromium|Navigateur Chromium" "thunderbird|Messagerie"
    "filezilla|Client FTP/SFTP" "transmission-gtk|BitTorrent" "qbittorrent|BitTorrent complet"
    "remmina|Bureau distant" "keepassxc|Gestionnaire de mots de passe" "hexchat|Client IRC"
    "weechat|IRC terminal" "lynx|Navigateur texte" "w3m|Navigateur texte"
    "nextcloud-desktop|Client Nextcloud" "rclone|Synchronisation cloud"
)
ITEMS_MEDIA=(
    "vlc|Lecteur multimédia" "ffmpeg|Audio/vidéo" "handbrake|Transcodage vidéo"
    "kdenlive|Montage vidéo" "obs-studio|Enregistrement/streaming" "audacity|Éditeur audio"
    "gimp|Retouche d'images" "inkscape|Dessin vectoriel" "imagemagick|Traitement d'images"
    "libreoffice|Suite bureautique" "evince|Lecteur PDF" "shotwell|Photos"
    "blender|3D" "krita|Peinture numérique" "mpv|Lecteur vidéo" "pavucontrol|Audio"
    "simplescreenrecorder|Enregistreur d'écran" "calibre|Livres numériques"
)
ITEMS_CLEAN=(
    "autoclean|Supprimer les anciens paquets en cache"
    "clean|Vider le cache d'installation"
    "autoremove|Supprimer les paquets orphelins (à utiliser avec prudence)"
)

CATS=(
    "1|cat1|CH_UPDATE|ITEMS_UPDATE"
    "2|cat2|CH_UTILS|ITEMS_UTILS"
    "3|cat3|CH_SEC|ITEMS_SEC"
    "4|cat4|CH_DEV|ITEMS_DEV"
    "5|cat5|CH_WEB|ITEMS_WEB"
    "6|cat6|CH_MEDIA|ITEMS_MEDIA"
    "7|cat7|CH_PENTEST|ITEMS_PENTEST"
    "8|cat8|CH_SERVER|ITEMS_SERVER"
    "9|cat9|CH_VIRT|ITEMS_VIRT"
    "10|cat10|CH_CLEAN|ITEMS_CLEAN"
)

set_defaults() {
    CH_UPDATE="update upgrade"
    CH_UTILS="ca-certificates apt-transport-https software-properties-common"
    CH_SEC=""
    CH_DEV=""
    CH_WEB=""
    CH_MEDIA=""
    CH_PENTEST=""
    CH_SERVER=""
    CH_VIRT=""
    CH_CLEAN=""
}

has() { local haystack="$1" needle="$2" item; for item in $haystack; do [ "$item" = "$needle" ] && return 0; done; return 1; }
count() { local n=0 item; for item in $1; do n=$((n+1)); done; echo "$n"; }

catalog_contains() {
    local needle="$1" item pkg
    local arrname item2
    for cat in "${CATS[@]}"; do
        IFS='|' read -r _ _ _ arrname <<< "$cat"
        local -n arr="$arrname"
        for item2 in "${arr[@]}"; do
            pkg="${item2%%|*}"
            [ "$pkg" = "$needle" ] && return 0
        done
    done
    return 1
}

validate_selection_list() {
    local list="$1" item
    for item in $list; do
        case "$item" in
            update|upgrade|full-upgrade|autoremove|autoclean|clean)
                ;;
            *)
                if ! catalog_contains "$item"; then
                    return 1
                fi
                ;;
        esac
    done
    return 0
}

validate_all_config() {
    local cat _ _ varname _ val
    for cat in "${CATS[@]}"; do
        IFS='|' read -r _ _ varname _ <<< "$cat"
        val="${!varname}"
        if ! validate_selection_list "$val"; then
            echo "[SECURITY] Configuration invalide pour $varname : réinitialisation." >&2
            return 1
        fi
    done
    return 0
}

save_config() {
    mkdir -p "$CONF_DIR" || return 1
    chmod 700 "$CONF_DIR" || return 1
    local tmp="$CONF_DIR/.choix.conf.tmp.$$"
    {
        echo "# LPI for Linux v$LPI_VERSION - fichier de données généré automatiquement"
        local cat id label_key varname arrname
        for cat in "${CATS[@]}"; do
            IFS='|' read -r id label_key varname arrname <<< "$cat"
            printf '%s="%s"\n' "$varname" "${!varname}"
        done
    } > "$tmp" || { rm -f -- "$tmp"; return 1; }
    chmod 600 "$tmp"
    chown root:root "$tmp" 2>/dev/null || true
    mv -f -- "$tmp" "$CONF_FILE"
    chmod 600 "$CONF_FILE"
}

load_config() {
    set_defaults
    [ -f "$CONF_FILE" ] || return 0
    local owner mode line var value varname found=0
    owner="$(stat -c '%u' "$CONF_FILE" 2>/dev/null || echo 1)"
    mode="$(stat -c '%a' "$CONF_FILE" 2>/dev/null || echo 644)"
    if [ "$owner" != "0" ] || [[ ! "$mode" =~ ^[0-6]00$ ]]; then
        echo "[SECURITY] Configuration ignorée : propriétaire ou permissions non sûrs." >&2
        return 0
    fi
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        if [[ "$line" =~ ^(CH_UPDATE|CH_UTILS|CH_SEC|CH_DEV|CH_WEB|CH_MEDIA|CH_PENTEST|CH_SERVER|CH_VIRT|CH_CLEAN)=\"([^\"]*)\"$ ]]; then
            var="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            printf -v "$var" '%s' "$value"
            found=1
        else
            echo "[SECURITY] Ligne de configuration ignorée." >&2
        fi
    done < "$CONF_FILE"
    if ! validate_all_config; then
        set_defaults
        save_config || true
        return 0
    fi
    [ "$found" -eq 1 ] && CONFIG_RESTAUREE="oui"
}

set_defaults
load_config

target_user() {
    if [ -n "$TARGET_USER" ]; then printf '%s' "$TARGET_USER"; return 0; fi
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ] && id "$SUDO_USER" >/dev/null 2>&1; then
        TARGET_USER="$SUDO_USER"
        printf '%s' "$TARGET_USER"
        return 0
    fi
    if [ "$AUTO_MODE" = "1" ] || [ "$DRY_RUN" = "1" ]; then
        printf ''
        return 0
    fi
    local u H W
    read -r H W <<< "$(dlg_size 10 64)"
    u="$(whiptail --title "LPI" --inputbox "${L[prompt_target_user]}" "$H" "$W" 3>&1 1>&2 2>&3)" || u=""
    if [ -n "$u" ] && ! [[ "$u" =~ ^[a-z_][a-z0-9_.-]{0,31}$ ]]; then
        whiptail --title "LPI" --msgbox "Nom d'utilisateur invalide." "$H" "$W"
        u=""
    fi
    if [ -n "$u" ] && ! id "$u" >/dev/null 2>&1; then
        whiptail --title "LPI" --msgbox "Utilisateur inexistant : $u" "$H" "$W"
        u=""
    fi
    [ "$u" = "root" ] && u=""
    TARGET_USER="$u"
    printf '%s' "$TARGET_USER"
}

run_cmd() {
    if [ "$DRY_RUN" = "1" ]; then
        printf '[DRY-RUN]'
        printf ' %q' "$@"
        printf '\n'
        return 0
    fi
    "$@"
}

wait_for_apt_lock() {
    local waited=0 max=120
    local locks=(/var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/lib/apt/lists/lock)
    command -v fuser >/dev/null 2>&1 || return 0
    while fuser "${locks[@]}" >/dev/null 2>&1; do
        [ "$waited" -eq 0 ] && echo "En attente de libération du verrou apt/dpkg..."
        sleep 2
        waited=$((waited + 2))
        if [ "$waited" -ge "$max" ]; then
            echo "Verrou apt/dpkg toujours occupé après ${max}s : arrêt de l'opération." >&2
            return 1
        fi
    done
}

apt_run() {
    if [ "$DRY_RUN" = "1" ]; then
        printf '[DRY-RUN] apt-get'
        printf ' %q' "$@"
        printf '\n'
        return 0
    fi
    wait_for_apt_lock || return 1
    DEBIAN_FRONTEND=noninteractive apt-get "$@"
}

install_pkgs() {
    local p cand
    local -a valid=()
    for p in "$@"; do
        if ! catalog_contains "$p"; then
            echo "[SECURITY] Paquet refusé (hors catalogue) : $p" >&2
            FAILED+=("$p (hors catalogue)")
            continue
        fi
        if [ "$DRY_RUN" = "1" ]; then
            echo "[DRY-RUN] installerait : $p"
            valid+=("$p")
            continue
        fi
        cand="$(apt-cache policy "$p" 2>/dev/null | awk -F': ' '/Candidate:/{print $2; exit}')"
        if [ -z "$cand" ] || [ "$cand" = "(none)" ]; then
            echo "[!] Paquet introuvable dans les dépôts : $p"
            FAILED+=("$p (introuvable)")
        else
            valid+=("$p")
        fi
    done
    [ "${#valid[@]}" -eq 0 ] && return 0
    [ "$DRY_RUN" = "1" ] && return 0
    if ! apt_run install -y -- "${valid[@]}"; then
        echo "Échec en bloc, nouvel essai paquet par paquet..."
        for p in "${valid[@]}"; do
            apt_run install -y -- "$p" || FAILED+=("$p")
        done
    fi
}

ssh_ports() {
    local ports=""
    if command -v sshd >/dev/null 2>&1; then
        ports="$(sshd -T 2>/dev/null | awk '$1=="port"{print $2}' | sort -nu | tr '\n' ' ')"
    fi
    if [ -z "$ports" ] && [ -r /etc/ssh/sshd_config ]; then
        ports="$(awk '$1 ~ /^[Pp]ort$/ && $2 ~ /^[0-9]+$/ {print $2}' /etc/ssh/sshd_config | sort -nu | tr '\n' ' ')"
    fi
    [ -z "$ports" ] && ports="22"
    printf '%s' "$ports"
}

configure_ufw() {
    command -v ufw >/dev/null 2>&1 || {
        echo "[!] UFW n'est pas disponible."
        FAILED+=("ufw (commande absente)")
        return 1
    }

    local ports port web_selected ssh_active=0
    ports="$(ssh_ports)"

    if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet ssh 2>/dev/null; then
        ssh_active=1
    elif command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet sshd 2>/dev/null; then
        ssh_active=1
    elif ss -ltn 2>/dev/null | grep -Eq ':(22|[0-9]+)[[:space:]]'; then
        ssh_active=1
    fi

    echo "Configuration UFW : politique entrante DENY, sortante ALLOW."
    echo "Ports SSH détectés : $ports"

    run_cmd ufw default deny incoming || return 1
    run_cmd ufw default allow outgoing || return 1

    if [ "$ssh_active" -eq 1 ] || has "${CH_SEC:-}" "openssh-server"; then
        for port in $ports; do
            case "$port" in
                ''|*[!0-9]*) echo "[!] Port SSH invalide ignoré : $port" ;;
                1|2|3|4|5|6|7|8|9) echo "[!] Port SSH invalide ignoré : $port" ;;
                *) run_cmd ufw allow "${port}/tcp" || return 1 ;;
            esac
        done
    fi

    web_selected=0
    has "${CH_SERVER:-}" "nginx" && web_selected=1
    has "${CH_SERVER:-}" "apache2" && web_selected=1
    if [ "$web_selected" -eq 1 ]; then
        run_cmd ufw allow 80/tcp || return 1
        run_cmd ufw allow 443/tcp || return 1
    fi

    if [ "$DRY_RUN" = "1" ]; then
        echo "[DRY-RUN] ufw --force enable"
    else
        if ! ufw --force enable; then
            FAILED+=("ufw (activation échouée)")
            return 1
        fi
    fi
}

configure_privileged_groups() {
    local tu=""
    if has "${CH_DEV:-}" "docker.io"; then
        tu="$(target_user)"
        if [ -n "$tu" ]; then
            if [ "$DRY_RUN" = "1" ]; then
                run_cmd usermod -aG docker "$tu"
            else
                echo "[!] Ajout de $tu au groupe docker : cela confère généralement des privilèges équivalents à root."
                if usermod -aG docker "$tu"; then
                    echo "Utilisateur $tu ajouté au groupe docker (reconnexion nécessaire)."
                else
                    FAILED+=("$tu (groupe docker)")
                fi
            fi
        else
            echo "[!] Aucun utilisateur cible : groupe docker non modifié."
        fi
    fi

    if has "${CH_VIRT:-}" "libvirt-daemon-system"; then
        tu="$(target_user)"
        if [ -n "$tu" ]; then
            if [ "$DRY_RUN" = "1" ]; then
                run_cmd usermod -aG libvirt,kvm "$tu"
            else
                echo "[!] Ajout de $tu aux groupes libvirt/kvm."
                usermod -aG libvirt,kvm "$tu" \
                    && echo "Utilisateur $tu ajouté aux groupes libvirt/kvm (reconnexion nécessaire)." \
                    || FAILED+=("$tu (groupes libvirt/kvm)")
            fi
        else
            echo "[!] Aucun utilisateur cible : groupes libvirt/kvm non modifiés."
        fi
    fi
}

check_prerequisites() {
    local cmd
    for cmd in apt-get apt-cache awk sed stat mktemp; do
        command -v "$cmd" >/dev/null 2>&1 || {
            echo "Dépendance système manquante : $cmd" >&2
            return 1
        }
    done
    return 0
}

check_network() {
    [ "$DRY_RUN" = "1" ] && return 0
    timeout 5 bash -c 'echo > /dev/tcp/deb.debian.org/443' 2>/dev/null
}

check_prerequisites || exit 1

check_network || {
    if [ "$AUTO_MODE" = "1" ]; then
        echo "[!] Connexion aux dépôts Debian non détectée."
    else
        if [ "$LANG_CHOICE" = "en" ]; then
            NETWORK_WARN_BODY="Unable to reach deb.debian.org.
Check your network, proxy or mirror. Continue anyway?"
        else
            NETWORK_WARN_BODY="Impossible de joindre deb.debian.org.
Vérifiez le réseau, le proxy ou le miroir. Continuer quand même ?"
        fi
        read -r H W <<< "$(dlg_size 12 66)"
        whiptail --title "${L[network_warn_title]}" --yes-button "${L[btn_continue]}" \
            --no-button "${L[btn_quit]}" --yesno "$NETWORK_WARN_BODY" "$H" "$W" || exit 0
    fi
}

save_config || {
    echo "[!] Impossible de sauvegarder la configuration dans $CONF_FILE." >&2
    exit 1
}

quitter() {
    echo "${L[closing]} $CONF_FILE"
    exit 0
}

check_selection_safety() {
    validate_all_config || {
        echo "[SECURITY] Sélection invalide : installation annulée." >&2
        return 1
    }
    return 0
}

checklist_menu() {
    local titre="$1" varname="$2" arrname="$3"
    local -n var="$varname"
    local -n arr="$arrname"
    local args=() item pkg desc state n=${#arr[@]} lh H W
    for item in "${arr[@]}"; do
        pkg="${item%%|*}"
        desc="${item#*|}"
        state="OFF"
        has "$var" "$pkg" && state="ON"
        args+=("$pkg" "$desc" "$state")
    done
    read -r H W <<< "$(dlg_size $((n + 8)) 78)"
    lh=$((H - 8)); [ "$lh" -gt "$n" ] && lh=$n; [ "$lh" -lt 1 ] && lh=1
    if whiptail --title "$titre" --checklist \
        "ESPACE = cocher/décocher   ENTRÉE = valider" "$H" "$W" "$lh" \
        "${args[@]}" 2> "$F_TMP"; then
        local tmp
        tmp="$(cat "$F_TMP")"
        tmp="${tmp//\"/}"
        if validate_selection_list "$tmp"; then
            var="$tmp"
            save_config || echo "[!] Échec de sauvegarde de la configuration." >&2
        else
            whiptail --title "LPI" --msgbox "Sélection invalide refusée." "$H" "$W"
        fi
    fi
}

apply_profile() {
    case "$1" in
        dev)
            set_defaults
            CH_UTILS="ca-certificates apt-transport-https software-properties-common git curl wget vim tmux htop ripgrep fzf bat"
            CH_DEV="build-essential cmake gdb shellcheck python3 python3-venv python3-pip nodejs npm neovim docker.io valgrind"
            CH_SEC="gnupg openssh-server"
            ;;
        web)
            set_defaults
            CH_SERVER="nginx mariadb-server php-fpm certbot"
            CH_SEC="ufw fail2ban openssh-server"
            ;;
        office)
            set_defaults
            CH_WEB="firefox-esr thunderbird keepassxc filezilla"
            CH_MEDIA="libreoffice vlc gimp evince"
            ;;
        minimal)
            set_defaults
            ;;
        *) return 1 ;;
    esac
    save_config
}

build_resume() {
    RESUME=""
    local cat id label_key varname arrname val label
    for cat in "${CATS[@]}"; do
        IFS='|' read -r id label_key varname arrname <<< "$cat"
        val="${!varname}"
        label="${L[$label_key]}"
        RESUME+="${label} : ${val:-aucun}"$'\n'
    done
}

write_report() {
    REPORT_FILE="/root/lpi_rapport_$(date +%Y%m%d_%H%M%S).txt"
    {
        echo "LPI for Linux v$LPI_VERSION - Rapport"
        echo "Date : $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Distribution : $DISTRO_ID"
        echo ""
        [ "$DRY_RUN" = "1" ] && echo "${L[dryrun_banner]}"
        echo "$RESUME"
        if [ "${#FAILED[@]}" -eq 0 ]; then
            echo "Résultat : succès, aucun échec."
        else
            echo "Résultat : ${#FAILED[@]} élément(s) en échec :"
            printf '  - %s\n' "${FAILED[@]}"
        fi
    } > "$REPORT_FILE"
    chmod 600 "$REPORT_FILE"
    chown root:root "$REPORT_FILE" 2>/dev/null || true
}

do_install_categories() {
    local progress_cb="${1:-}" cat id label_key varname arrname val label pct
    ACTIVE_DONE=0
    for cat in "${CATS[@]}"; do
        IFS='|' read -r id label_key varname arrname <<< "$cat"
        val="${!varname}"
        [ -z "$val" ] && continue
        label="${L[$label_key]}"
        pct=$(( ACTIVE_DONE * 100 / ACTIVE_TOTAL ))
        [ -n "$progress_cb" ] && "$progress_cb" "$pct" "${label}..."
        echo -e "\n---> [$id/10] $label <---"

        case "$id" in
            1)
                has "$val" "update" && apt_run update -y || true
                has "$val" "upgrade" && apt_run upgrade -y || FAILED+=("upgrade")
                has "$val" "full-upgrade" && apt_run full-upgrade -y || FAILED+=("full-upgrade")
                ;;
            10)
                has "$val" "autoclean" && apt_run autoclean || true
                has "$val" "clean" && apt_run clean || true
                has "$val" "autoremove" && apt_run autoremove -y || FAILED+=("autoremove")
                ;;
            *)
                local -a pkgs=()
                local p
                for p in $val; do pkgs+=("$p"); done
                install_pkgs "${pkgs[@]}"
                ;;
        esac

        case "$id" in
            3)
                if has "$val" "ufw"; then
                    configure_ufw || true
                fi
                if has "$val" "fail2ban"; then
                    if command -v systemctl >/dev/null 2>&1; then
                        run_cmd systemctl enable --now fail2ban || FAILED+=("fail2ban (service)")
                    fi
                fi
                ;;
            4|9)
                configure_privileged_groups
                ;;
        esac
        ACTIVE_DONE=$((ACTIVE_DONE + 1))
    done
    [ -n "$progress_cb" ] && "$progress_cb" 100 "${L[gauge_done]}"
}

run_session() {
    FAILED=()
    check_selection_safety || return 1
    build_resume
    ACTIVE_TOTAL=0
    local cat _ _ varname _
    for cat in "${CATS[@]}"; do
        IFS='|' read -r _ _ varname _ <<< "$cat"
        [ -n "${!varname}" ] && ACTIVE_TOTAL=$((ACTIVE_TOTAL + 1))
    done
    [ "$ACTIVE_TOTAL" -eq 0 ] && ACTIVE_TOTAL=1

    mkdir -p "$(dirname "$LOG_FILE")" || return 1
    touch "$LOG_FILE" || return 1
    chmod 600 "$LOG_FILE"
    chown root:root "$LOG_FILE" 2>/dev/null || true
    {
        echo "=== Session LPI du $(date '+%Y-%m-%d %H:%M:%S') ==="
        [ "$DRY_RUN" = "1" ] && echo "${L[dryrun_banner]}"
        printf '%s\n' "$RESUME"
    } >> "$LOG_FILE"

    if [ "$AUTO_MODE" = "1" ]; then
        do_install_categories
    else
        GAUGE_PIPE="$TMP_DIR/gauge"
        mkfifo "$GAUGE_PIPE"
        exec 3<> "$GAUGE_PIPE"
        read -r GH GW <<< "$(dlg_size 8 70)"
        whiptail --title "${L[gauge_title]}" --gauge "${L[gauge_prep]}" "$GH" "$GW" 0 <&3 3<&- &
        GAUGE_PID=$!
        gauge_progress() {
            { echo "XXX"; echo "$1"; echo "$2"; echo "XXX"; } >&3
        }
        exec 4>&1 5>&2
        exec >> "$LOG_FILE" 2>&1
        do_install_categories gauge_progress
        exec 3>&-
        wait "$GAUGE_PID" 2>/dev/null || true
        GAUGE_PID=""
        rm -f -- "$GAUGE_PIPE"
        GAUGE_PIPE=""
        exec 1>&4 2>&5
        exec 4>&- 5>&-
    fi
    write_report
    return 0
}

if [ "$AUTO_MODE" = "1" ]; then
    echo "======================================================="
    echo " LPI for Linux v$LPI_VERSION - mode automatique"
    [ "$DRY_RUN" = "1" ] && echo " ${L[dryrun_banner]}"
    echo "======================================================="
    build_resume
    echo "$RESUME"
    if ! run_session; then
        echo "Installation annulée : configuration invalide ou prérequis manquants." >&2
        exit 1
    fi
    echo "======================================================="
    if [ "${#FAILED[@]}" -eq 0 ]; then
        echo "LPI terminé avec succès !"
        STATUS=0
    else
        echo "LPI terminé avec des erreurs :"
        printf '  - %s\n' "${FAILED[@]}"
        STATUS=1
    fi
    echo "Choix : $CONF_FILE"
    echo "Journal : $LOG_FILE"
    echo "Rapport : $REPORT_FILE"
    echo "======================================================="
    exit "$STATUS"
fi

MSG_RESTORE=""
[ "$CONFIG_RESTAUREE" = "oui" ] && MSG_RESTORE="
Vos choix précédents ont été restaurés."

WELCOME_BODY="
   __        ______ ___
   \\ \\      / /  _ \\_ _|
    \\ \\ /\\ / /| |_) | |
     \\ V  V / |  __/| |
      \\_/\\_/  |_|  |___|   for Linux

   LPI for Linux v$LPI_VERSION
   Créé par $LPI_AUTEUR
   Installateur de logiciels pour Debian.
   Choisissez vos paquets, vos choix sont mémorisés.
$MSG_RESTORE

   ${L[security_warning]}

   Cliquez sur \"${L[btn_accept]}\" pour continuer."

read -r H W <<< "$(dlg_size 25 70)"
whiptail --title "LPI for Linux v$LPI_VERSION" \
    --yes-button "${L[btn_accept]}" --no-button "${L[btn_quit]}" \
    --yesno "$WELCOME_BODY" "$H" "$W" || exit 0

while true; do
    while true; do
        MENU_ARGS=()
        local_dummy=""
        for cat in "${CATS[@]}"; do
            IFS='|' read -r id label_key varname arrname <<< "$cat"
            cnt="$(count "${!varname}")"
            MENU_ARGS+=("$id" "${L[$label_key]} [$cnt ${L[choisis]}]")
        done
        MENU_ARGS+=(
            "PROFILS" "${L[menu_profiles]}"
            "AIDE" "${L[menu_help]}"
            "RESET" "${L[menu_reset]}"
            "INSTALLER" "${L[menu_install]}"
            "QUITTER" "${L[menu_quit]}"
        )
        TOTAL_ENTRIES=$(( ${#CATS[@]} + 5 ))
        read -r H W <<< "$(dlg_size 25 78)"
        MENU_LH=$((H - 11))
        [ "$MENU_LH" -gt "$TOTAL_ENTRIES" ] && MENU_LH=$TOTAL_ENTRIES
        [ "$MENU_LH" -lt 1 ] && MENU_LH=1

        if ! whiptail --title "LPI for Linux v$LPI_VERSION - ${L[menu_by]} $LPI_AUTEUR" \
            --menu "${L[menu_prompt]}" "$H" "$W" "$MENU_LH" \
            "${MENU_ARGS[@]}" 2> "$F_TMP"; then
            quitter
        fi
        read -r MENU_CHOIX < "$F_TMP"

        case "$MENU_CHOIX" in
            PROFILS)
                read -r H W <<< "$(dlg_size 16 66)"
                if whiptail --title "${L[profiles_title]}" --menu "${L[menu_prompt]}" "$H" "$W" 5 \
                    "dev" "${L[profile_dev]}" "web" "${L[profile_web]}" \
                    "office" "${L[profile_office]}" "minimal" "${L[profile_minimal]}" \
                    "RETOUR" "${L[profile_back]}" 2> "$F_TMP"; then
                    read -r PROFILE_CHOICE < "$F_TMP"
                    if [ "$PROFILE_CHOICE" != "RETOUR" ] && [ -n "$PROFILE_CHOICE" ]; then
                        apply_profile "$PROFILE_CHOICE"
                        read -r H2 W2 <<< "$(dlg_size 10 60)"
                        whiptail --title "${L[profiles_title]}" --msgbox "${L[profile_applied]}" "$H2" "$W2"
                    fi
                fi
                ;;
            AIDE)
                read -r H W <<< "$(dlg_size 24 74)"
                whiptail --scrolltext --title "LPI - ${L[menu_help]}" --msgbox "$HELP_TXT" "$H" "$W"
                ;;
            RESET)
                read -r H W <<< "$(dlg_size 8 50)"
                if whiptail --title "${L[confirm_reset_title]}" --yesno "${L[confirm_reset_q]}" "$H" "$W"; then
                    set_defaults
                    save_config
                fi
                ;;
            INSTALLER)
                build_resume
                read -r H W <<< "$(dlg_size 24 78)"
                if whiptail --scrolltext --title "${L[confirm_install_title]}" --yesno \
                    "$RESUME
${L[confirm_install_q]}" "$H" "$W"; then
                    break
                fi
                ;;
            QUITTER)
                quitter
                ;;
            *)
                for cat in "${CATS[@]}"; do
                    IFS='|' read -r id label_key varname arrname <<< "$cat"
                    if [ "$MENU_CHOIX" = "$id" ]; then
                        if [ "$id" = "7" ]; then
                            read -r H W <<< "$(dlg_size 10 66)"
                            whiptail --title "${L[pentest_warn_title]}" --msgbox "$PENTEST_WARN_BODY" "$H" "$W"
                        fi
                        checklist_menu "$id/${#CATS[@]} - ${L[$label_key]}" "$varname" "$arrname"
                        break
                    fi
                done
                ;;
        esac
    done

    clear
    echo "======================================================="
    echo " LPI for Linux v$LPI_VERSION"
    [ "$DRY_RUN" = "1" ] && echo " ${L[dryrun_banner]}"
    echo "======================================================="

    if ! run_session; then
        FIN_MSG="Installation annulée : configuration invalide ou prérequis manquants."
    elif [ "${#FAILED[@]}" -eq 0 ]; then
        FIN_MSG="${L[final_success]}"
    else
        FIN_MSG="${L[final_failed_prefix]} ${#FAILED[@]} ${L[final_failed_suffix]}"
    fi

    {
        echo "======================================================="
        echo "$FIN_MSG"
        echo "Choix : $CONF_FILE"
        echo "Journal : $LOG_FILE"
        echo "Rapport : $REPORT_FILE"
        echo "======================================================="
    } | tee -a "$LOG_FILE"

    read -r H W <<< "$(dlg_size 15 70)"
    if whiptail --title "${L[final_title]}" \
        --yes-button "${L[btn_back_menu]}" --no-button "${L[btn_quit]}" \
        --yesno "$FIN_MSG

${L[final_log]} $LOG_FILE
${L[final_conf]} $CONF_FILE
${L[final_report]} $REPORT_FILE" "$H" "$W"; then
        clear
        continue
    fi
    break
done

clear
echo "${L[closing]} $CONF_FILE"
exit 0
