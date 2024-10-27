# ------------------------------------------------------------------------------
# Docker Aliases
# ------------------------------------------------------------------------------

# Container Management
alias dl="docker ps -l -q"                                                  # Get the latest container ID
alias dps="docker ps"                                                       # Get list of all running containers
alias dpa="docker ps -a"                                                    # Get list of all containers, even the ones not running
alias dstop='docker stop $(docker ps -a -q)'                                # Stop all containers
alias drm='docker rm $(docker ps -a -q)'                                    # Remove all containers
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)' # Stop and Remove all containers
alias dclean="docker rm -v $(docker ps -a -q -f status=exited)"             # Remove all stopped/exited containers

# Image Management
alias di="docker images"                   # List all images
alias dri='docker rmi $(docker images -q)' # Remove all images

# Network Management
alias dn='docker network ls' # List Docker networks

# Volume Management
alias dvp='docker volume prune' # Remove unused Volumes

# System Prune
alias dsp='docker system prune' # Remove unused Containers, Images, Network, etc.

# Container Inspection
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'" # Get container IP

# Container Interaction
alias dbash='docker exec -it $(docker ps -aqf "name=$1") bash' # Bash into a running container

# Stop specific container
dsc() { docker stop $(docker ps -a | grep $1 | awk '{print $1}'); }

# Show all aliases related to docker
dalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/" | sed "s/['|\']//g" | sort; }
