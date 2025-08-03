#!/bin/sh

# cowMOD v1.2 by CowCrusher
VERSION="1.2"
REPO_MAIN="https://github.com/CowCrusher/ish-filler/raw/main"
REPO_EXTRA="https://archive.org/download/ish-filler"
CACHE_DIR="$HOME/.cache/cowMOD"
USAGE_FILE="$CACHE_DIR/.usage"
PKG_CACHE="$CACHE_DIR/.pkg-cache"
COWMOD_PATH="$HOME/ish-filler/cowMOD"

mkdir -p "$CACHE_DIR" "$COWMOD_PATH"

# Usage count
if [ -f "$USAGE_FILE" ]; then
    COUNT=$(cat "$USAGE_FILE")
else
    COUNT=0
fi
COUNT=$((COUNT+1))
echo "$COUNT" > "$USAGE_FILE"

# Help
show_help() {
    cat <<EOF
cowMOD v$VERSION - modular command manager
Usage: cowMOD -[command]

Commands:
  -h           Show this help message
  -d           Download package from Alpine
  -d -r        Download from user repo ($REPO_EXTRA)
  -d -url URL  Download package from URL
  -rm          Remove a package
  -m           Move package/files to another folder
  -s           System command mode (like systemd)
  -alpine      Download Alpine for modding
  -c NAME      Configure/edit program
  -i           Info screen
  -u           Update cowMOD and packages
EOF
}

# Info screen
show_info() {
    echo "   (__) "
    echo "   (oo)   cowMOD Info"
    echo "  /------\\"
    echo " / |    ||"
    echo "*  /\\---/\\  "
    echo "~~     ~~"
    echo
    echo "cowMOD version : $VERSION"
    echo "Total uses     : $(cat "$USAGE_FILE")"
    echo "Cache location : $CACHE_DIR"
    echo "Packages cached:"
    cat "$PKG_CACHE" 2>/dev/null || echo "  None"
    echo
    fastfetch 2>/dev/null || echo "[*] fastfetch not installed."
}

# Download handler
download_pkg() {
    PKG="$1"
    echo "[*] Downloading $PKG from Alpine..."
    apk add --no-cache "$PKG" && echo "$PKG" >> "$PKG_CACHE" || echo "[!] Package not found in Alpine repo."
}

download_repo() {
    PKG="$1"
    echo "[*] Downloading $PKG from user repo..."
    wget -q "$REPO_EXTRA/$PKG" -O "$PKG" && echo "$PKG" >> "$PKG_CACHE" || echo "[!] Package not found in extra repo."
}

download_url() {
    URL="$1"
    echo "[*] Downloading from $URL..."
    wget "$URL" || echo "[!] Failed to download from URL."
}

remove_pkg() {
    PKG="$1"
    echo "[*] Removing $PKG..."
    apk del "$PKG" || echo "[!] Failed to remove $PKG."
    sed -i "/^$PKG$/d" "$PKG_CACHE" 2>/dev/null
}

update_cowMOD() {
    echo "[*] Checking for updates..."
    REMOTE_VER=$(wget -qO- "$REPO_MAIN/latest-version.txt")
    if [ "$REMOTE_VER" != "$VERSION" ]; then
        echo "[*] Updating cowMOD to v$REMOTE_VER..."
        wget "$REPO_MAIN/cowMOD/cowMOD.sh" -O "$COWMOD_PATH/cowMOD.sh" && chmod +x "$COWMOD_PATH/cowMOD.sh"
        echo "[*] Updated. Please restart cowMOD."
    else
        echo "[*] cowMOD is up to date."
    fi
}

# Argument handler
case "$1" in
    -h) show_help ;;
    -i) show_info ;;
    -d)
        if [ "$2" = "-r" ]; then
            read -p "Package name: " PKG
            download_repo "$PKG"
        elif [ "$2" = "-url" ]; then
            read -p "Enter full URL: " URL
            download_url "$URL"
        else
            read -p "Package name: " PKG
            download_pkg "$PKG"
        fi
        ;;
    -rm)
        read -p "Package name to remove: " PKG
        remove_pkg "$PKG"
        ;;
    -m)
        read -p "Package/file name: " FILE
        read -p "Destination folder: " DEST
        mkdir -p "$DEST" && mv "$FILE" "$DEST"
        echo "[*] Moved $FILE to $DEST"
        ;;
    -s)
        echo "[*] System command mode not yet implemented."
        ;;
    -alpine)
        echo "[*] Downloading Alpine system for modding..."
        wget "$REPO_MAIN/install/alpine-minirootfs.tar.gz" -O alpine.tar.gz || echo "[!] Download failed."
        ;;
    -c)
        read -p "Program to configure: " PROG
        nano "$(which $PROG)" || echo "[!] Cannot configure $PROG"
        ;;
    -u) update_cowMOD ;;
    *) echo "( wrong usage type cowMOD -h for help )" ;;
esac
