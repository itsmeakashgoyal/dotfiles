#!/bin/bash

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

nvimCleanup() {
    echo "${YELLOW}Cleanup nvim artifacts...${RC}"
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim
    rm -rf ~/.cache/nvim
}

nvimCleanup
