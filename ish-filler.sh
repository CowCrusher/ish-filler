#!/bin/sh
# ish-filler.sh v1.2 - Alpine full setup script for iSH

set -e

MAIN_REPO="https://raw.githubusercontent.com/CowCrusher/ish-filler/main"
FALLBACK_REPO="https://archive.org/download/ish-filler"
VERSION="1.2"
INSTALL_DIR="$HOME/ish-filler"
COWMOD_DIR="$INSTALL_DIR/cowMOD"
CACHE_DIR="$INSTALL_DIR/.cache"
VERSION_FILE="$INSTALL_DIR/latest-version.txt"

print_header() {
    echo "[*] Welcome to ish-filler v$VERSION"
}

check_or_install() {
    command -v "$1" >/dev/null 2>&1 || apk add "$1"
}

update_check() {
    echo "[*] Checking for updates..."
    mkdir -p "$CACHE_DIR"
    if curl -fsSL "$MAIN_REPO/latest-version.txt" -o "$CACHE_DIR/latest.txt" 2>/dev/null || \
       curl -fsSL "$FALLBACK_REPO/latest-version.txt" -o "$CACHE_DIR/latest.txt"; then
        REMOTE_VER=$(cat "$CACHE_DIR/latest.txt")
        if [ "$REMOTE_VER" != "$VERSION" ]; then
            echo "[!] Update available: v$REMOTE_VER"
            echo "[*] Updating ish-filler..."
            if curl -fsSL "$MAIN_REPO/ish-filler.sh" -o "$0" || \
               curl -fsSL "$FALLBACK_REPO/ish-filler.sh" -o "$0"; then
                chmod +x "$0"
                echo "[*] Update complete. Restarting..."
                exec "$0"
            else
                echo "[!] Failed to fetch updated script!"
            fi
        fi
    fi
}

install_system() {
    echo "[*] Installing base packages..."
    apk update
    apk upgrade --available
    apk add curl git zsh bash coreutils fastfetch font-noto doas shadow openrc

    echo "[*] Fixing Alpine mirror..."
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories
    apk update

    echo "[*] Creating directories..."
    mkdir -p "$INSTALL_DIR" "$COWMOD_DIR/packages" "$CACHE_DIR"
    touch "$COWMOD_DIR/.cowMOD_usage"
    echo 0 > "$COWMOD_DIR/.cowMOD_usage"

    echo "[*] Installing Oh My Zsh and Pokémon scripts..."
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh || true
    curl -fsSL https://raw.githubusercontent.com/CowCrusher/ish-filler/main/pokemon-colorscripts.sh -o /usr/local/bin/pokemon-colorscripts && chmod +x /usr/local/bin/pokemon-colorscripts

    echo "[*] Creating user..."
    echo -n "Username: "; read USERNAME
    echo -n "Password: "; read -s PASSWORD; echo
    adduser -D "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "permit $USERNAME" > /etc/doas.conf
    echo "default_user=$USERNAME" >> /etc/login.defs

    echo "[*] Enable login screen? [y/N]"
    read LOGIN
    if [ "$LOGIN" = "y" ]; then
        touch /etc/.use-login
        echo '[ -f /etc/.use-login ] && exec login' >> /etc/profile
    fi

    echo "[*] Installing cowMOD..."
    curl -fsSL "$MAIN_REPO/cowMOD/cowMOD.sh" -o "$COWMOD_DIR/cowMOD.sh" || \
    curl -fsSL "$FALLBACK_REPO/cowMOD.sh" -o "$COWMOD_DIR/cowMOD.sh"
    chmod +x "$COWMOD_DIR/cowMOD.sh"
    ln -sf "$COWMOD_DIR/cowMOD.sh" /usr/local/bin/cowMOD

    echo "[*] Installation complete!"
}

undo_system() {
    echo "[*] Undoing system setup..."
    deluser --remove-home "$USERNAME" || true
    rm -rf "$INSTALL_DIR"
    sed -i '/use-login/d' /etc/profile
    rm -f /etc/.use-login /usr/local/bin/cowMOD /etc/doas.conf
    echo "https://apk.ish.app/v3.18/main" > /etc/apk/repositories
    apk del curl git zsh fastfetch font-noto doas shadow openrc || true
    echo "[*] System reverted."
}

container_menu() {
    echo "[*] Container Management"
    echo "1) Install Alpine"
    echo "2) Install Debian"
    echo "3) Install Arch"
    echo "4) Back"
    read -p "> " CHOICE
    case "$CHOICE" in
        1)
            curl -fsSL "$MAIN_REPO/containers/alpine.sh" -o alpine.sh || curl -fsSL "$FALLBACK_REPO/containers/alpine.sh" -o alpine.sh
            chmod +x alpine.sh && ./alpine.sh
            ;;
        2)
            curl -fsSL "$MAIN_REPO/containers/debian.sh" -o debian.sh || curl -fsSL "$FALLBACK_REPO/containers/debian.sh" -o debian.sh
            chmod +x debian.sh && ./debian.sh
            ;;
        3)
            curl -fsSL "$MAIN_REPO/containers/arch.sh" -o arch.sh || curl -fsSL "$FALLBACK_REPO/containers/arch.sh" -o arch.sh
            chmod +x arch.sh && ./arch.sh
            ;;
    esac
}

main_menu() {
    print_header
    update_check
    echo "[i] Install"
    echo "[u] Undo"
    echo "[c] Containers"
    echo "[e] Exit"
    read -p "Select: " OPT
    case "$OPT" in
        i) install_system ;;
        u) undo_system ;;
        c) container_menu ;;
        e) exit 0 ;;
        *) echo "[!] Invalid" ;;
    esac
}

main_menu
