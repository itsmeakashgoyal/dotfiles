#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

user=$(whoami)

process() {
	echo "$(date) PROCESSING:  $@" >>$LOG
	printf "$(tput setaf 6) [STEP ${STEP:-0}] %s...$(tput sgr0)\n" "$@"
	STEP=$((STEP + 1))
}

# Set variables
NAME=$1
EMAIL=$2

if [ -z "$NAME" ]; then
	read -r -p "Please enter your git user.name, (for example, akashgoyal)" NAME
	NAME=${NAME:-"akashgoyal"}
fi

if [ -z "$EMAIL" ]; then
	read -r -p "Please enter your git user.email, (for example, decoder[at]live[dot]de)" EMAIL
	EMAIL=${EMAIL:-"decoder@live.com"}
fi

process "→ Bootstrap steps start here:\n------------------"

sudo apt-get update
sudo apt-get -y upgrade

process "→ Installing snapd"

sudo apt install snapd

process "→ install git"

sudo apt install -y git

process "→ setup git config"

git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

process "→ install essencial packages"

sudo apt install -y vim-gtk htop unzip python3-setuptools figlet tmux pydf mc wget mtr ncdu cmatrix ranger jq lolcat tmux bat locate libgraph-easy-perl stow cowsay fortune
sudo apt install -y encfs fuse xclip xsel alsa-utils fd-find expect bat

process "→ install tmuxinator"
sudo gem install tmuxinator

process "→ install pip"
sudo apt install -y python3-pip

process "→ install exa"
EXA_VERSION=$(curl -s "https://api.github.com/repos/ogham/exa/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo exa.zip "https://github.com/ogham/exa/releases/latest/download/exa-linux-x86_64-v${EXA_VERSION}.zip"
sudo unzip -q exa.zip bin/exa -d /usr/local
sudo rm exa.zip

process "→ install go"
sudo apt install -y golang

process "→ Install development tools and package managers"

sudo apt install -y cargo
cargo install just
cargo install zoxide
cargo install onefetch

process "→ Install PipeWire for audio management"

sudo apt install -y pipewire pipewire-utils

process "→ install node and nmp"
sudo apt install -y nodejs

process "→ install zsh and oh-my-zsh"
sudo apt install -y zsh
sudo rm -rf ~/.oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

process "→ Installing zsh-autosuggestions plugin"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

process "→ Installing gh, k9s, kind, krew"
arkade get gh \
           k9s \
					 kind \
					 kubectx \
					 kubens \
					 yq

echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >>~/.zshrc

process "→ Installing GCP CLI"
curl "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-377.0.0-linux-x86_64.tar.gz" -o "google-cloud-sdk-377.0.0-linux-x86.tar.gz"
tar zxvf google-cloud-sdk-377.0.0-linux-x86.tar.gz
./google-cloud-sdk/install.sh --usage-reporting=false --quiet

process "→ Installing Neovim"
sudo curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
sudo chmod +x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim
sudo chown "$user" /usr/local/bin/nvim

symlink

nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

process "→ Setting zsh as default shell"
cd "$HOME"
sudo chsh -s $(which zsh) "$user"
zsh
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="3den"/g' ~/.zshrc
source ~/.zshrc
exec zsh

process → Installation complete"
