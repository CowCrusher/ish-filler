#!/bin/sh
mkdir -p ~/ish-filler/containers/arch
cd ~/ish-filler/containers/arch
curl -LO https://mirror.rackspace.com/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.gz
tar -xvzf archlinux-bootstrap-*.tar.gz --strip-components=1
proot -0 -r . /bin/bash
