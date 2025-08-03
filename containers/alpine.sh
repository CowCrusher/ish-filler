#!/bin/sh
mkdir -p ~/ish-filler/containers/alpine
cd ~/ish-filler/containers/alpine
curl -LO https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86/alpine-minirootfs-latest-x86.tar.gz
proot -0 -r . /bin/sh
