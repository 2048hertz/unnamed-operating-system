#!/bin/bash
# Unnamed Operating System Update Manager CLI
# Written by Ayaan Eusufzai
# Based on my old script rum.sh for RobertOS/AstraOS

# Current installed version
CURRENT_VERSION="1.0"

# GitHub repository URL
REPO_URL="https://github.com/2048hertz/unnamed-operating-system"

# Required commands
REQUIRED_CMDS=("curl" "grep" "sed" "sort" "mktemp" "chmod")

# Check for required dependencies
check_dependencies() {
    echo "[*] Checking dependencies..."
    local missing=false
    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "[MISSING] $cmd"
            missing=true
        else
            echo "[OK]      $cmd"
        fi
    done

    if [ "$missing" = true ]; then
        echo "[!] Missing dependencies detected. Please install them before running the update."
        echo "    Recommended fix: xbps-install -S curl coreutils util-linux"
        exit 1
    fi

    echo "[✓] All dependencies satisfied."
}

# Get the latest tag name from the GitHub releases page
get_latest_release_version() {
    repo_url="$1"
    curl -sSL "$repo_url/releases/latest" | grep -o '"tag_name": *"[^"]*"' | sed 's/.*"tag_name": *"//' | sed 's/"//'
}

# Compare two versions using sort -V
is_newer_version() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n 1)" != "$1" ]
}

# Download update.sh from the latest release and execute it
download_and_execute_update() {
    local repo_url="$1"
    local version="$2"
    local download_url="$repo_url/releases/download/$version/update.sh"

    echo "[*] Downloading update script from $download_url"

    local temp_dir
    temp_dir=$(mktemp -d)
    local script_path="$temp_dir/update.sh"

    curl -sSL -o "$script_path" "$download_url"

    if [ ! -s "$script_path" ]; then
        echo "[!] Failed to download update script or script is empty."
        exit 1
    fi

    chmod +x "$script_path"
    echo "[*] Running update..."
    "$script_path"
}

# Check for updates
check_for_updates() {
    echo "[*] Checking for updates from $REPO_URL..."

    latest_version=$(get_latest_release_version "$REPO_URL")

    if [ -z "$latest_version" ]; then
        echo "[!] Failed to fetch latest version."
        exit 1
    fi

    if [ "$latest_version" == "$CURRENT_VERSION" ]; then
        echo "[✓] You are already on the latest version ($CURRENT_VERSION)."
        exit 0
    fi

    echo "[!] New version available: $latest_version"

    # Skip update for version 1.0
    if [ "$latest_version" == "1.0" ]; then
        echo "[i] Version 1.0 is the base release. No update.sh available yet."
        exit 0
    fi

    download_and_execute_update "$REPO_URL" "$latest_version"
}

# Entry point
main() {
    if [[ "$1" == "--check" ]]; then
        check_dependencies
        exit 0
    fi

    check_dependencies
    check_for_updates
}

main "$@"
