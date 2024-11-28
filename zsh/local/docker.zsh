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

# ------------------------------------------------------------------------------
# Container Inspection and Interaction
# ------------------------------------------------------------------------------
# Get container IP
dcip() {
  local container_name="$1"
  if [[ -z "$container_name" ]]; then
    echo "Usage: dip CONTAINER_NAME"
    return 1
  fi
  docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$container_name"
}

# Execute bash in container
dbash() {
  local container_name="$1"
  if [[ -z "$container_name" ]]; then
    echo "Usage: dbash CONTAINER_NAME"
    return 1
  fi
  docker exec -it "$container_name" bash || docker exec -it "$container_name" sh
}

# Stop containers by partial name match
dsc() {
  local container_pattern="$1"
  if [[ -z "$container_pattern" ]]; then
    echo "Usage: dsc CONTAINER_PATTERN"
    return 1
  fi
  docker stop $(docker ps -a | grep "$container_pattern" | awk '{print $1}')
}

# Remove containers by partial name match
drmc() {
  local container_pattern="$1"
  if [[ -z "$container_pattern" ]]; then
    echo "Usage: drmc CONTAINER_PATTERN"
    return 1
  fi
  docker rm $(docker ps -a | grep "$container_pattern" | awk '{print $1}')
}

# Show docker disk usage
dsize() {
  docker system df -v
}

# List all Docker aliases and functions
dalias() {
  echo "Docker Aliases and Functions:"
  echo "----------------------------"
  alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/" | sed "s/['|\']//g" | sort
  echo "\nCustom Functions:"
  echo "---------------"
  declare -f | grep '^[a-z][a-zA-Z0-9_]* () {$' | grep 'd[a-zA-Z0-9_]*' | sed 's/ () {$//'
}

# Check if Docker daemon is running
docker_running() {
  if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker daemon is not running"
    return 1
  fi
  return 0
}
