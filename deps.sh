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
    echo "  deps privacy    Install sandbox and secure wipe tools"
    echo "  deps help       Show this help message"
    echo
}

function install_gui() {
    echo "[*] Installing GUI dependencies..."

    echo
    echo "Choose your video driver:"
    echo "  1. intel"
    echo "  2. amd"
    echo "  3. nvidia (open source)"
    echo "  4. vesa (generic fallback)"
    echo

    read -p "[?] Enter your choice (1-4): " driver_choice

    case "$driver_choice" in
        1) VIDEO_DRIVER="xf86-video-intel" ;;
        2) VIDEO_DRIVER="xf86-video-amdgpu" ;;
        3) VIDEO_DRIVER="xf86-video-nouveau" ;;
        4) VIDEO_DRIVER="xf86-video-vesa" ;;
        *)
            echo "[!] Invalid choice. Defaulting to vesa driver."
            VIDEO_DRIVER="xf86-video-vesa"
            ;;
    esac

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
        xdotool \
        xf86-input-libinput \
        font-misc-misc \
        "$VIDEO_DRIVER"

    echo "[+] GUI dependencies installed with driver: $VIDEO_DRIVER"
}

function install_network() {
    echo "[*] Installing network tool dependencies..."
    xbps-install -S \
        iw \
        wpa_supplicant \
        dhcpcd \
        psmisc \
        iproute2
    echo "[+] Network tool dependencies installed."
}

function install_status() {
    echo "[*] Installing system status tool dependencies..."
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

function install_privacy() {
    echo "[*] Installing privacy tools (sandbox and wipe)..."
    xbps-install -S \
        firejail \
        wipe
    echo "[+] Privacy tools installed."
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
    privacy)
        install_privacy
        ;;
    all)
        install_gui
        install_network
        install_status
        install_privacy
        ;;
    help|"")
        show_help
        ;;
    *)
        echo "[!] Unknown option: $1"
        show_help
        ;;
esac
