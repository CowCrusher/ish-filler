#!/bin/sh
mkdir -p ~/ish-filler/containers/debian
cd ~/ish-filler/containers/debian
curl -LO https://cdimage.debian.org/cdimage/release/current/armhf/iso-cd/debian-armhf-netinst.iso
# Optional: extract rootfs manually or with proot
proot -0 -r . /bin/bash
