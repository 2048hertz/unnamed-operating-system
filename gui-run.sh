#!/bin/bash
# Unnamed Operating System gui-run — Fullscreen GUI app launcher using Openbox
# Written by Ayaan Eusufzai
# Dependencies: xorg-minimal xinit openbox psmisc xdotool

APP="$1"

function show_help() {
    echo "Unnamed Operating System GUI Launcher"
    echo
    echo "Usage:"
    echo "  gui-run <app>        Launch a GUI app in fullscreen Openbox"
    echo "  gui-run doctor       Check for required dependencies"
    echo "  gui-run help         Show this help message"
    echo
    echo "Examples:"
    echo "  gui-run firefox"
    echo "  gui-run flatpak run com.discordapp.Discord"
}

function run_doctor() {
    echo "Running Unnamed Operating System gui-run dependency check..."
    echo

    REQUIRED_CMDS=("startx" "xinit" "openbox" "xterm" "killall" "xdotool")

    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "[MISSING] $cmd"
        else
            echo "[OK]      $cmd"
        fi
    done

    echo
    echo "To install missing packages, run: ./install-gui-deps.sh"
}

case "$APP" in
    help|"")
        show_help
        ;;
    doctor)
        run_doctor
        ;;
    *)
        if ! command -v $APP >/dev/null 2>&1 && ! echo "$APP" | grep -q "^flatpak run"; then
            echo "[!] '$APP' not found as a command."
            echo "You can also run full Flatpak launch strings:"
            echo "  gui-run flatpak run com.discordapp.Discord"
            exit 1
        fi

        mkdir -p ~/.config/openbox

        # Openbox autostart: run app and fullscreen it
        cat > ~/.config/openbox/autostart <<EOF
$APP &
sleep 2
xdotool search --onlyvisible --class "$(basename $APP | cut -d' ' -f1)" windowactivate --sync key F11
EOF

        # Temporary .xinitrc for launching Openbox
        echo "exec openbox-session" > ~/.xinitrc.gui-run

        echo "[*] Launching $APP in fullscreen via Openbox..."
        startx ~/.xinitrc.gui-run -- :1
        rm -f ~/.xinitrc.gui-run
        echo "[*] Application closed. Back to Unnamed Operating System."
        ;;
esac
