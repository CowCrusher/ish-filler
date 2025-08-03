#!/bin/sh

# ish-filler v1.2
# Main GitHub repo: https://github.com/CowCrusher/ish-filler
# Extra repo: https://archive.org/download/ish-filler

INSTALL_DIR="$HOME/ish-filler"
COWMOD_DIR="$INSTALL_DIR/cowMOD"
GITHUB_REPO="https://github.com/CowCrusher/ish-filler"
EXTRA_REPO="https://archive.org/download/ish-filler"

mkdir -p "$COWMOD_DIR"

echo "[*] Welcome to ish-filler v1.2"
echo "[*] Checking for updates..."

curl -fsSL "$GITHUB_REPO/latest-version.txt" -o "$INSTALL_DIR/latest-version.txt" 2>/dev/null
if [ -s "$INSTALL_DIR/latest-version.txt" ]; then
    ONLINE_VERSION=$(cat "$INSTALL_DIR/latest-version.txt")
    if [ "$ONLINE_VERSION" != "1.2" ]; then
        echo "[!] Update available: $ONLINE_VERSION"
        echo "[*] Updating ish-filler..."
        curl -fsSL "$GITHUB_REPO/ish-filler.sh" -o "$INSTALL_DIR/ish-filler.sh"
        sh "$INSTALL_DIR/ish-filler.sh"
        exit
    fi
fi

echo "[*] Installing base Alpine packages..."
apk update
apk add alpine-base bash coreutils curl git doas zsh fastfetch font-noto shadow

echo "[*] Creating basic directories..."
for d in bin boot dev etc home lib media mnt opt proc root run sbin srv sys tmp usr var; do
    mkdir -p "/$d"
done

echo "[*] Setting up user account..."
read -p "Enter a username: " NEWUSER
adduser -D "$NEWUSER"
passwd "$NEWUSER"
echo "permit $NEWUSER as root" > /etc/doas.conf

echo "[*] Installing login screen support..."
read -p "Enable terminal login screen? (y/n): " LOGIN_CHOICE
if [ "$LOGIN_CHOICE" = "y" ]; then
    touch /etc/.use-login
    echo '[ -f /etc/.use-login ] && exec login' >> /etc/profile
fi

echo "[*] Setting Zsh as default shell..."
chsh -s /bin/zsh "$NEWUSER"

echo "[*] Downloading and installing cowMOD..."
curl -fsSL "$GITHUB_REPO/cowMOD.sh" -o "$COWMOD_DIR/cowMOD"
chmod +x "$COWMOD_DIR/cowMOD"
ln -sf "$COWMOD_DIR/cowMOD" /usr/local/bin/cowMOD

echo "[*] Setting up container management system..."
mkdir -p "$INSTALL_DIR/containers"

echo "[*] Installation complete!"
echo "[*] Type ./ish-filler.sh again to access the main menu."
