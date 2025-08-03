#!/bin/sh
# cowMOD v1.2
COWMOD_DIR="${HOME}/ish-filler/cowMOD"
CACHE_FILE="${COWMOD_DIR}/.cowMOD_usage"
PKG_REPO="https://raw.githubusercontent.com/CowCrusher/ish-filler/main/cowMOD/packages"
EXTRA_REPO="https://archive.org/download/ish-filler"

# Usage tracking
[ -f "$CACHE_FILE" ] && COUNT=$(cat "$CACHE_FILE") || COUNT=0
echo $((COUNT + 1)) > "$CACHE_FILE"

# Help
if [ "$1" = "-h" ]; then
    echo "cowMOD v1.2 - Commands:"
    echo "-h        Show help"
    echo "-d        Download packages from main repo"
    echo "-d -r     Download from archive.org"
    echo "-d -url   Download from custom URL"
    echo "-rm       Remove package"
    echo "-m        Move package files"
    echo "-s        System command mode"
    echo "-alpine   Fetch and prep Alpine ISO"
    echo "-c        Configure a package"
    echo "-i        Show system info + cow"
    echo "-u        Update packages and cowMOD/ish-filler"
    exit 0
fi

# Info screen
if [ "$1" = "-i" ]; then
    echo "🐄 cowMOD v1.2"
    echo "Usage Count: $((COUNT + 1))"
    echo "Cache Dir: ${COWMOD_DIR}"
    echo "Fastfetch output:"
    fastfetch || echo "(fastfetch not installed)"
    exit 0
fi

# Package installer
if [ "$1" = "-d" ]; then
    shift
    REPO="$PKG_REPO"
    [ "$1" = "-r" ] && REPO="$EXTRA_REPO" && shift
    [ "$1" = "-url" ] && REPO="$2" && shift 2
    mkdir -p /tmp/cowmod-pkgs
    for pkg in "$@"; do
        echo "Fetching $pkg..."
        curl -fsSL "$REPO/$pkg" -o "/tmp/cowmod-pkgs/$pkg" || {
            echo "❌ No such package in repo: $pkg"
            continue
        }
        apk add /tmp/cowmod-pkgs/$pkg
    done
    exit 0
fi

# Package remover
if [ "$1" = "-rm" ]; then
    shift
    for pkg in "$@"; do
        apk del "$pkg" || echo "❌ Failed to remove: $pkg"
    done
    exit 0
fi

# Move files
if [ "$1" = "-m" ]; then
    echo "Move not yet implemented."
    exit 0
fi

# System command executor
if [ "$1" = "-s" ]; then
    echo "System mode (placeholder)."
    exit 0
fi

# Alpine modding
if [ "$1" = "-alpine" ]; then
    echo "Download Alpine base (placeholder)."
    exit 0
fi

# Configure command
if [ "$1" = "-c" ]; then
    echo "Edit command (placeholder)."
    exit 0
fi

# Auto-updater
if [ "$1" = "-u" ]; then
    echo "🔁 Checking for updates..."
    curl -fsSL "https://raw.githubusercontent.com/CowCrusher/ish-filler/main/latest-version.txt" -o /tmp/latest-version.txt
    CUR_VER="1.2"
    NEW_VER=$(cat /tmp/latest-version.txt)
    if [ "$NEW_VER" != "$CUR_VER" ]; then
        echo "⬆️ Updating to v$NEW_VER..."
        curl -fsSL "https://raw.githubusercontent.com/CowCrusher/ish-filler/main/ish-filler.sh" -o "${HOME}/ish-filler/ish-filler.sh"
        curl -fsSL "https://raw.githubusercontent.com/CowCrusher/ish-filler/main/cowMOD/cowMOD.sh" -o "${HOME}/ish-filler/cowMOD/cowMOD.sh"
        chmod +x "${HOME}/ish-filler/ish-filler.sh" "${HOME}/ish-filler/cowMOD/cowMOD.sh"
        echo "✅ Updated!"
    else
        echo "✅ Already up-to-date."
    fi
    exit 0
fi

# Wrong usage
echo "( wrong usage - type cowMOD -h for help )"
exit 1
