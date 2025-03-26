#!/bin/bash
# UnnamedOS Wi-Fi CLI Tool — /usr/local/bin/network
# Written by Ayaan Eusufzai
# Dependencies - iw wpa_supplicant dhcpcd psmisc iproute2

# Detect wireless interface
IFACE=$(iw dev | awk '$1=="Interface"{print $2}')
WPA_CONF="/tmp/wpa.conf"

function show_help() {
    echo "UnnamedOS Network Tool"
    echo
    echo "Usage:"
    echo "  network help                     Show this help message"
    echo "  network menu                     Show available Wi-Fi networks"
    echo "  network connect SSID PASSWORD   Connect to a Wi-Fi network"
    echo "  network status                   Show current connection status"
    echo "  network disconnect               Disconnect from current network"
    echo "  network doctor                   Check for required dependencies"
    echo
    echo "Examples:"
    echo "  network connect MyWiFi hunter2"
    echo "  network menu"
    echo "  network status"
    echo "  network doctor"
}

function show_menu() {
    if [ -z "$IFACE" ]; then
        echo "[!] No wireless interface found."
        exit 1
    fi

    echo "[*] Scanning for Wi-Fi networks..."
    ip link set "$IFACE" up
    sleep 2
    iw dev "$IFACE" scan | grep SSID | awk -F ': ' '{print $2}' | sort -u
}

function connect_wifi() {
    local ssid="$1"
    local pass="$2"

    if [ -z "$IFACE" ]; then
        echo "[!] No wireless interface found."
        exit 1
    fi

    if [ -z "$ssid" ] || [ -z "$pass" ]; then
        echo "[!] SSID and password required."
        echo "Usage: network connect <SSID> <PASSWORD>"
        exit 1
    fi

    echo "[*] Connecting to $ssid..."
    wpa_passphrase "$ssid" "$pass" > "$WPA_CONF"

    killall wpa_supplicant 2>/dev/null
    wpa_supplicant -B -i "$IFACE" -c "$WPA_CONF"

    sleep 3
    dhcpcd "$IFACE"
    echo "[+] Connected. Try 'ping archlinux.org' to test."
    rm "$WPA_CONF"
}

function show_status() {
    if [ -z "$IFACE" ]; then
        echo "[!] No wireless interface found."
        exit 1
    fi

    echo "[*] Interface: $IFACE"
    ip addr show "$IFACE" | grep inet || echo "[!] No IP address assigned."

    CURRENT_SSID=$(iw dev "$IFACE" link | grep SSID | awk '{print $2}')
    if [ -z "$CURRENT_SSID" ]; then
        echo "[!] Not connected to any Wi-Fi network."
    else
        echo "[+] Connected to SSID: $CURRENT_SSID"
    fi
}

function disconnect_wifi() {
    if [ -z "$IFACE" ]; then
        echo "[!] No wireless interface found."
        exit 1
    fi

    echo "[*] Disconnecting from Wi-Fi..."
    killall wpa_supplicant 2>/dev/null
    dhcpcd -k "$IFACE"
    ip link set "$IFACE" down
    echo "[+] Disconnected from Wi-Fi."
}

function run_doctor() {
    echo "Running UnnamedOS Network Diagnostics..."
    echo

    REQUIRED_CMDS=("iw" "wpa_supplicant" "wpa_passphrase" "dhcpcd" "ip" "killall")

    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "[❌] Missing: $cmd"
        else
            echo "[✅] Found: $cmd"
        fi
    done

    if [ -z "$IFACE" ]; then
        echo "[⚠️ ] No wireless interface found. Are you on a laptop or using a USB Wi-Fi adapter?"
    else
        echo "[✅] Wireless interface detected: $IFACE"
    fi

    echo
    echo "If something’s missing, run:"
    echo "  xbps-install -S iw wpa_supplicant dhcpcd psmisc iproute2"
}

# Command parser
case "$1" in
    help|"")
        show_help
        ;;
    menu)
        show_menu
        ;;
    connect)
        connect_wifi "$2" "$3"
        ;;
    status)
        show_status
        ;;
    disconnect)
        disconnect_wifi
        ;;
    doctor)
        run_doctor
        ;;
    *)
        echo "[!] Unknown command: $1"
        show_help
        ;;
esac
