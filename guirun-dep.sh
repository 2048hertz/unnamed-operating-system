#!/bin/bash
# Written by Ayaan Eusufzai
# Installs dependencies for gui-run

echo "[*] Installing Xorg and basic graphical tools..."

xbps-install -S \
  xorg-minimal \
  xinit \
  xterm \
  openbox \
  firefox \
  gimp \
  psmisc \
  flatpak \
  xrandr \
  xdg-utils

echo "[+] GUI dependencies installed."
