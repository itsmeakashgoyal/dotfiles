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

# Stop containers
alias dstop='docker stop $(docker ps -a -q)'                                # Stop all containers
alias drm='docker rm $(docker ps -a -q)'                                    # Remove all containers
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)' # Stop and Remove all containers

# ------------------------------------------------------------------------------
# Image Management
# ------------------------------------------------------------------------------
alias di="docker images"                   # List all images
alias dri='docker rmi $(docker images -q)' # Remove all images
alias dpull="docker pull"                  # Pull an image
alias dbuild="docker build"                # Build an image

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
