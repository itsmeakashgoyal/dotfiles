# Development Environment Setup [![](https://img.shields.io/badge/Quality-A%2B-brightgreen.svg)](https://img.shields.io/badge/Quality-A%2B-brightgreen.svg) [![License](https://img.shields.io/badge/License-BSD_2--Clause-orange.svg)](https://opensource.org/licenses/BSD-2-Clause)

[![Test Setup dotfiles](https://github.com/itsmeakashgoyal/dotfiles/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/itsmeakashgoyal/dotfiles/actions/workflows/build_and_test.yml)

This repository contains scripts and configuration files to set up a development environment for macOS and LinuxOS. It's tailored for software development, focusing on a clean, minimal, and efficient setup.

## Overview

The setup includes automated scripts for installing essential software, configuring Bash and Zsh shells, and setting up Sublime Text and Visual Studio Code editors. This guide will help you replicate my development environment on your machine if you desire to do so.

## Important Note Before Installation

**WARNING:** The configurations and scripts in this repository are **HIGHLY PERSONALIZED** to my own preferences and workflows. If you decide to use them, please be aware that they will **MODIFY** your current system, potentially making some changes that are **IRREVERSIBLE** without a fresh installation of your operating system.

Furthermore, while I strive to backup files wherever possible, I cannot guarantee that all files are backed up. The backup mechanism is designed to backup SOME files **ONCE**. If the script is run more than once, the initial backups will be **OVERWRITTEN**, potentially resulting in loss of data. While I could implement timestamped backups to preserve multiple versions, this setup is optimized for my personal use, and a single backup suffices for me.

If you would like a development environment similar to mine, I highly encourage you to fork this repository and make your own personalized changes to these scripts instead of running them exactly as I have them written for myself.

Any kind of corrections would be welcome!. I feel free to accept pull requests if there are any errors in my scripts.

If you choose to run these scripts, please do so with **EXTREME CAUTION**. It's recommended to review the scripts and understand the changes they will make to your system before proceeding.

By using these scripts, you acknowledge and accept the risk of potential data loss or system alteration. Proceed at your own risk.

## Getting Started

### Prerequisites

- macOS
- LinuxOS
This dotfiles setup are tailored for both macOS and LinuxOS.

### Installation

1. Clone the repository to your local machine:
   ```sh
   git clone https://github.com/itsmeakashgoyal/dotfiles.git ~/dotfiles
   ```
2. Navigate to the `dotfiles` directory:
   ```sh
   cd ~/dotfiles
   ```
3. Run the installation script:
   ```sh
   ./setup.sh
   ```


This script will:

- Create symlinks for dotfiles (`.gitconfig`, `.zshrc`, etc.)
- Run macOS and LinuxOS specific configurations based on OS in which it is running.

## Configuration Files

- `settings/`: Directory containing editor settings and themes for Sublime Text, Visual Studio Code and iterm terminal.
- `scripts/`: Containing common scripts to run while setting up the dotfiles.
- `tmux/`: Containing tmux config files
- `zsh/`: Containing Shell configuration files for Zsh.
- `git/`: Containing git configuration.
- `homeConfig/`: Containing configurations should be link to home dir.
- `nvim/`: Another git submodule for my nvim config.
- `nix/`: Nix configurations specific to LinuxOS.

### Customizing Your Setup

You're encouraged to modify the scripts and configuration files to suit your preferences. Here are some tips for customization:

- **Sublime Text and VS Code**: Adjust settings in the `settings/` directory to change editor preferences and themes.

## Contributing

Feel free to fork this repository and customize it for your setup. Pull requests for improvements and bug fixes are welcome.

## License

This project is licensed under the BSD 2-Clause License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Thanks to all the open-source projects used in this setup.
