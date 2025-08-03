#!/bin/sh
# cowMOD.sh v1.2 - modular system manager

MAIN_REPO="https://raw.githubusercontent.com/CowCrusher/ish-filler/main/cowMOD"
FALLBACK_REPO="https://archive.org/download/ish-filler"
PKG_DIR="$MAIN_REPO/packages"
ALT_PKG_DIR="$FALLBACK_REPO/packages"
USAGE_FILE="$(dirname "$0")/.cowMOD_usage"

increment_usage() {
    COUNT=$(cat "$USAGE_FILE" 2>/dev/null || echo 0)
    COUNT=$((COUNT + 1))
    echo "$COUNT" > "$USAGE_FILE"
}

print_help() {
    echo "cowMOD v1.2"
    echo "Usage: cowMOD [option]"
    echo "  -h        Show this help"
    echo "  -i        Info screen (cow logo, usage)"
    echo "  -d        Download packages"
    echo "  -d -r     Download from archive.org"
    echo "  -rm       Remove packages"
    echo "  -m        Move packages/files"
    echo "  -s        System commands"
    echo "  -c <pkg>  Configure package"
    echo "  -u        Update cowMOD & packages"
}

info_screen() {
    clear
    echo "   (__) "
    echo "   (oo) cowMOD v1.2"
    echo "  /------\\"
    echo " / |    ||"
    echo "*  /\\---/\\"
    echo "Usage count: $(cat "$USAGE_FILE" 2>/dev/null || echo 0)"
    echo "Cache: $(du -sh ~/.cache 2>/dev/null || echo 0)"
    echo "Uptime: $(uptime)"
}

download_pkg() {
    mkdir -p /usr/local/bin
    echo "[*] Enter package name:"
    read PKG
    curl -fsSL "$PKG_DIR/$PKG" -o "/usr/local/bin/$PKG" || \
    curl -fsSL "$ALT_PKG_DIR/$PKG" -o "/usr/local/bin/$PKG" || \
    { echo "[!] Package not found."; return; }
    chmod +x "/usr/local/bin/$PKG"
    echo "[*] Installed $PKG."
}

remove_pkg() {
    echo "[*] Enter package name to remove:"
    read PKG
    rm -f "/usr/local/bin/$PKG"
    echo "[*] Removed $PKG."
}

update_all() {
    echo "[*] Updating cowMOD..."
    curl -fsSL "$MAIN_REPO/cowMOD.sh" -o "$0" || \
    curl -fsSL "$FALLBACK_REPO/cowMOD.sh" -o "$0"
    chmod +x "$0"
    echo "[*] cowMOD updated."
}

case "$1" in
    -h) print_help ;;
    -i) info_screen ;;
    -d) download_pkg ;;
    -rm) remove_pkg ;;
    -u) update_all ;;
    *) echo "( wrong usage type cowMOD -h for help )" ;;
esac

increment_usage
