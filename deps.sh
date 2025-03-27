#!/bin/bash
# Unnamed Operating System deps — Dependency installer CLI
# Written by Ayaan Eusufzai

function show_help() {
    echo "Unnamed Operating System Dependency Installer"
    echo
    echo "Usage:"
    echo "  deps all        Install all dependencies"
    echo "  deps gui        Install GUI-related packages (for gui-run)"
    echo "  deps network    Install network tool dependencies"
    echo "  deps status     Install system status tool dependencies"
    echo "  deps help       Show this help message"
    echo
}

function install_gui() {
    echo "[*] Installing GUI dependencies..."
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
        xdg-utils \
        xdotool
    echo "[+] GUI dependencies installed."
}

function install_network() {
    echo "[*] Installing network dependencies..."
    xbps-install -S \
        iw \
        wpa_supplicant \
        dhcpcd \
        psmisc \
        iproute2
    echo "[+] Network tool dependencies installed."
}

function install_status() {
    echo "[*] Installing status tool dependencies..."
    xbps-install -S \
        hostname \
        procps-ng \
        iproute2 \
        util-linux \
        usbutils \
        gawk \
        grep \
        sed \
        coreutils
    echo "[+] Status tool dependencies installed."
}

case "$1" in
    gui)
        install_gui
        ;;
    network)
        install_network
        ;;
    status)
        install_status
        ;;
    all)
        install_gui
        install_network
        install_status
        ;;
    help|"")
        show_help
        ;;
    *)
        echo "[!] Unknown option: $1"
        show_help
        ;;
esac
