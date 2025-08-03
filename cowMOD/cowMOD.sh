#!/bin/sh
# cowMOD v1.2 by CowCrusher

COWMOD_DIR="$HOME/ish-filler/cowMOD"
USAGE_FILE="$COWMOD_DIR/.cowMOD_usage"
CACHE_DIR="$COWMOD_DIR/.cache"
MAIN_REPO="https://github.com/CowCrusher/ish-filler/raw/main/cowMOD/packages"
FALLBACK_REPO="https://archive.org/download/ish-filler"

[ ! -f "$USAGE_FILE" ] && echo 0 > "$USAGE_FILE"

increment_usage() {
  count=$(cat "$USAGE_FILE")
  echo $((count + 1)) > "$USAGE_FILE"
}

cow_header() {
  echo "   (__) "
  echo "   (oo)  cowMOD v1.2"
  echo "  /------\\"
  echo " *  |||||"
  echo
}

case "$1" in
  -h)
    cow_header
    echo "Usage: cowMOD [flags]"
    echo "-h            Show this help"
    echo "-i            Info screen (fastfetch style)"
    echo "-d            Download package from GitHub repo"
    echo "-d -r         Download package from Archive.org repo"
    echo "-d -url       Download package from any URL"
    echo "-rm           Remove a package"
    echo "-m            Move a package to another folder"
    echo "-s            Run system-wide commands"
    echo "-u            Update cowMOD, ish-filler, and installed packages"
    echo "-c [pkg]      Configure/edit a package"
    ;;
  -i)
    cow_header
    echo "Times used: $(cat "$USAGE_FILE")"
    echo "Cache files: $(ls "$CACHE_DIR" 2>/dev/null | wc -l)"
    echo "cowMOD path: $COWMOD_DIR"
    echo "Primary repo: GitHub"
    echo "Extra repo: Archive.org"
    ;;
  -d)
    if [ "$2" = "-r" ]; then
      shift 2
      pkg="$1"
      url="$FALLBACK_REPO/$pkg"
    elif [ "$2" = "-url" ]; then
      shift 2
      url="$1"
    else
      shift
      pkg="$1"
      url="$MAIN_REPO/$pkg"
    fi
    echo "[*] Downloading package: $pkg"
    mkdir -p "$CACHE_DIR"
    curl -fLo "$CACHE_DIR/$pkg" "$url" || echo "[-] Package not found in repo"
    ;;
  -rm)
    rm -f "$CACHE_DIR/$2"
    echo "[*] Removed $2"
    ;;
  -m)
    mv "$CACHE_DIR/$2" "$3"
    echo "[*] Moved $2 to $3"
    ;;
  -s)
    echo "[!] Running system command: $2"
    sh -c "$2"
    ;;
  -u)
    echo "[*] Updating cowMOD and ish-filler..."
    curl -Lo "$COWMOD_DIR/cowMOD.sh" "$MAIN_REPO/../cowMOD.sh" && chmod +x "$COWMOD_DIR/cowMOD.sh"
    curl -Lo "$HOME/ish-filler/ish-filler.sh" "https://github.com/CowCrusher/ish-filler/raw/main/ish-filler.sh" && chmod +x "$HOME/ish-filler/ish-filler.sh"
    echo "[*] Update complete."
    ;;
  -c)
    nano "$CACHE_DIR/$2"
    ;;
  *)
    echo "( wrong usage — type cowMOD -h for help )"
    ;;
esac

increment_usage
