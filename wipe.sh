#!/bin/bash
# Unnamed Operating System wipe tool
# Written by Ayaan Eusufzai

TARGET="$1"

if ! command -v wipe >/dev/null 2>&1; then
    echo "[!] 'wipe' utility not found. Run: deps privacy"
    exit 1
fi

if [ -z "$TARGET" ]; then
    echo "Usage: wipe <file-or-dir>"
    echo "Example: wipe ~/.bash_history"
    exit 1
fi

if [ ! -e "$TARGET" ]; then
    echo "[!] Target does not exist: $TARGET"
    exit 1
fi

# Prevent wiping dangerous paths
case "$TARGET" in
    "/"|"/home"|"/root"|"/etc"|"/usr"|"/var"|"/*")
        echo "[!] Wiping system directories is not allowed."
        exit 1
        ;;
esac

echo "[*] Securely wiping: $TARGET"
wipe -rfi "$TARGET"
echo "[+] Wipe complete."
