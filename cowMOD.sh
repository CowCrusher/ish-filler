#!/bin/sh

COWMOD_USAGE_COUNT_FILE="$HOME/.cowmod_usage"
COWMOD_REPO="https://github.com/CowCrusher/ish-filler"
EXTRA_REPO="https://archive.org/download/ish-filler"

[ ! -f "$COWMOD_USAGE_COUNT_FILE" ] && echo 0 > "$COWMOD_USAGE_COUNT_FILE"
USAGE_COUNT=$(cat "$COWMOD_USAGE_COUNT_FILE")
USAGE_COUNT=$((USAGE_COUNT + 1))
echo "$USAGE_COUNT" > "$COWMOD_USAGE_COUNT_FILE"

case "$1" in
    -h)
        echo "cowMOD command system:"
        echo "-h        Show this help message"
        echo "-d        Download from Alpine repo"
        echo "-d -r     Download from archive.org"
        echo "-d -url   Download from a URL"
        echo "-rm       Remove a package"
        echo "-m        Move package files"
        echo "-s        Execute system-wide command"
        echo "-alpine   Download/modify Alpine (like archiso)"
        echo "-c [pkg]  Configure/edit command or program"
        echo "-i        Show system info (modified fastfetch)"
        echo "-u        Update cowMOD, ish-filler and packages"
        ;;
    -d)
        shift
        if [ "$1" = "-r" ]; then
            echo "[*] Downloading from user repo..."
            apk add --repository="$EXTRA_REPO" "$2"
        elif [ "$1" = "-url" ]; then
            echo "[*] Downloading from URL: $2"
            curl -LO "$2"
        else
            echo "[*] Downloading package from Alpine repo..."
            apk add "$1"
        fi
        ;;
    -rm)
        apk del "$2"
        ;;
    -m)
        echo "[*] Moving package files for $2"
        # Placeholder logic
        ;;
    -s)
        shift
        echo "[*] Executing system command: $*"
        eval "$*"
        ;;
    -alpine)
        echo "[*] Downloading Alpine system for editing..."
        # Placeholder logic
        ;;
    -c)
        echo "[*] Configuring $2"
        # Placeholder logic
        ;;
    -i)
        echo "   (__)"
        echo "   (oo)  cowMOD"
        echo "  /------\\"
        echo " / |    ||"
        echo "*  /\\---/\\  Usage: $USAGE_COUNT"
        echo "   ~~     Cache: $(du -sh ~/.cache 2>/dev/null | cut -f1)"
        fastfetch
        ;;
    -u)
        echo "[*] Updating cowMOD, ish-filler, and packages..."
        curl -fsSL "$COWMOD_REPO/cowMOD.sh" -o "$0"
        curl -fsSL "$COWMOD_REPO/ish-filler.sh" -o "$HOME/ish-filler/ish-filler.sh"
        ;;
    "")
        echo "( wrong usage type cowMOD -h for help )"
        ;;
    *)
        echo "Unknown command. Type cowMOD -h for help."
        ;;
esac
