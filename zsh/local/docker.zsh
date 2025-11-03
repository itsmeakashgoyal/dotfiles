#!/usr/bin/env zsh
#                     █████
#                    ░░███
#   █████████  █████  ░███████
#  ░█░░░░███  ███░░   ░███░░███
#  ░   ███░  ░░█████  ░███ ░███
#    ███░   █ ░░░░███ ░███ ░███
#   █████████ ██████  ████ █████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/local/docker.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# Docker Aliases and Functions
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Container Management
# ------------------------------------------------------------------------------
alias dl="docker ps -l -q" # Get the latest container ID
alias dps="docker ps"      # Get list of all running containers
alias dpa="docker ps -a"   # Get list of all containers, even the ones not running

# Stop and remove containers (safer versions with confirmation)
dstop() {
    local containers=$(docker ps -q)
    if [[ -z "$containers" ]]; then
        echo "No running containers to stop."
        return 0
    fi
    echo "Running containers:"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
    echo "\n⚠️  Stop ALL running containers? (y/N)"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]] && docker stop $containers || echo "Cancelled."
}

drm() {
    local containers=$(docker ps -a -q)
    if [[ -z "$containers" ]]; then
        echo "No containers to remove."
        return 0
    fi
    echo "All containers:"
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
    echo "\n⚠️  Remove ALL containers? (y/N)"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]] && docker rm $containers || echo "Cancelled."
}

drmf() {
    local containers=$(docker ps -a -q)
    if [[ -z "$containers" ]]; then
        echo "No containers to remove."
        return 0
    fi
    echo "All containers:"
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
    echo "\n⚠️  STOP and REMOVE ALL containers? This cannot be undone! (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        docker stop $containers && docker rm $containers
    else
        echo "Cancelled."
    fi
}

# ------------------------------------------------------------------------------
# Image Management
# ------------------------------------------------------------------------------
alias di="docker images"       # List all images
alias dpull="docker pull"      # Pull an image
alias dbuild="docker build"    # Build an image

# Remove all images (with confirmation)
dri() {
    local images=$(docker images -q)
    if [[ -z "$images" ]]; then
        echo "No images to remove."
        return 0
    fi
    echo "All images:"
    docker images
    echo "\n⚠️  Remove ALL images? (y/N)"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]] && docker rmi $images || echo "Cancelled."
}

# ------------------------------------------------------------------------------
# System Management
# ------------------------------------------------------------------------------
# Remove unused data (containers, networks, images, volumes)
alias docker-clean='docker system prune --volumes -af'

# Individual prune commands
alias dcp='docker container prune -f' # Remove stopped containers
alias dip='docker image prune -af'    # Remove unused images
alias dnp='docker network prune -f'   # Remove unused networks
alias dsp='docker system prune -af'   # Remove all unused objects
