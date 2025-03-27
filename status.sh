#!/bin/bash
# status command for an unnamed operating system
# written by ayaan eusufzai

REQUIRED_CMDS=("hostname" "uptime" "uname" "ip" "iw" "df" "free" "lscpu" "awk" "grep" "sed")

print_line() {
    echo "----------------------------------------"
}

print_title() {
    echo
    echo "$1"
    print_line
}

run_main_status() {
    # System Info
    print_title "System"
    echo "Hostname:  $(hostname)"
    echo "Uptime:    $(uptime -p)"
    echo "Kernel:    $(uname -r)"
    echo "OS:        Unnamed"

    # Network Info
    print_title "Network"
    ip -4 addr show | awk '/inet/ && !/127.0.0.1/ {print "Interface:", $NF, "-> IP:", $2}'

    IFACE=$(iw dev | awk '$1=="Interface"{print $2}')
    if [ -n "$IFACE" ]; then
        SSID=$(iw dev "$IFACE" link | grep SSID | awk '{print $2}')
        if [ -n "$SSID" ]; then
            echo "Wi-Fi:     Interface: $IFACE, SSID: $SSID"
        else
            echo "Wi-Fi:     Interface: $IFACE, Status: Disconnected"
        fi
    else
        echo "Wi-Fi:     No wireless interface detected"
    fi

    # Disk Usage
    print_title "Disk Usage"
    df -h --output=source,fstype,size,used,avail,pcent,target | grep '^/dev' || echo "No mounted disks found."

    # Memory Usage
    print_title "Memory"
    free -h | awk '/Mem:/ {printf "Used: %s / %s\n", $3, $2}'

    # CPU Info
    print_title "CPU"
    lscpu | grep -E 'Model name|CPU\(s\):|MHz' | sed 's/^[ \t]*//'

    # USB Devices
    print_title "USB Devices"
    if command -v lsusb >/dev/null 2>&1; then
        lsusb
    else
        echo "lsusb not installed. Run: xbps-install -S usbutils"
    fi

    print_line
}

run_doctor() {
    echo "Running UnnamedOS Status Doctor"
    print_line

    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "[MISSING] $cmd"
        else
            echo "[OK]      $cmd"
        fi
    done

    if ! command -v lsusb >/dev/null 2>&1; then
        echo "[OPTIONAL] lsusb not found (used to list USB devices)"
    fi

    echo
    echo "To install missing packages:"
    echo "  xbps-install -S iw iproute2 procps-ng util-linux usbutils gawk grep sed"
    print_line
}

case "$1" in
    doctor)
        run_doctor
        ;;
    ""|main|status)
        run_main_status
        ;;
    help|-h|--help)
        echo "UnnamedOS Status Command"
        echo
        echo "Usage:"
        echo "  status             Show system status"
        echo "  status doctor      Check for missing required commands"
        echo "  status help        Show this message"
        ;;
    *)
        echo "[!] Unknown command: $1"
        echo "Run 'status help' for usage."
        ;;
esac
