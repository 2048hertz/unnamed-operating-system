#!/bin/bash
# Unnamed Operating System sandbox tool
# Written by Ayaan Eusufzai

STRICT_MODE=false

# Parse --strict as first arg
if [ "$1" == "--strict" ]; then
    STRICT_MODE=true
    shift
fi

# Check if firejail is installed
if ! command -v firejail >/dev/null 2>&1; then
    echo "[!] firejail is not installed. Run: deps privacy"
    exit 1
fi

# Check if command is provided
if [ $# -eq 0 ]; then
    echo "Usage:"
    echo "  sandbox <app> [args...]          Run an app in a firejail sandbox"
    echo "  sandbox --strict <app> [args...] Run app in private mode (no access to real files)"
    echo
    echo "Examples:"
    echo "  sandbox firefox"
    echo "  sandbox --strict flatpak run com.discordapp.Discord"
    exit 1
fi

# Run in the appropriate mode
if $STRICT_MODE; then
    echo "[*] Launching '$*' in strict sandbox mode (--private)"
    exec firejail --noprofile --private "$@"
else
    echo "[*] Launching '$*' in normal sandbox"
    exec firejail --noprofile "$@"
fi
