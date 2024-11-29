# Development Environment Setup [![](https://img.shields.io/badge/Quality-A%2B-brightgreen.svg)](https://img.shields.io/badge/Quality-A%2B-brightgreen.svg) [![License](https://img.shields.io/badge/License-BSD_2--Clause-orange.svg)](https://opensource.org/licenses/BSD-2-Clause)

[![Test Setup dotfiles](https://github.com/itsmeakashgoyal/dotfiles/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/itsmeakashgoyal/dotfiles/actions/workflows/build_and_test.yml)

```
     █████           █████       ██████   ███  ████
    ░░███           ░░███       ███░░███ ░░░  ░░███
  ███████   ██████  ███████    ░███ ░░░  ████  ░███   ██████   █████
 ███░░███  ███░░███░░░███░    ███████   ░░███  ░███  ███░░███ ███░░
░███ ░███ ░███ ░███  ░███    ░░░███░     ░███  ░███ ░███████ ░░█████
░███ ░███ ░███ ░███  ░███ ███  ░███      ░███  ░███ ░███░░░   ░░░░███
░░████████░░██████   ░░█████   █████     █████ █████░░██████  ██████
 ░░░░░░░░  ░░░░░░     ░░░░░   ░░░░░     ░░░░░ ░░░░░  ░░░░░░  ░░░░░░
```

This repository contains scripts and configuration files to set up a development environment for macOS and Linux. It is tailored for software development, focusing on a clean, minimal, and efficient setup.

## Overview

The setup includes automated scripts for installing essential software, configuring Bash and Zsh shells, and setting up Sublime Text and Visual Studio Code editors. This guide will help you replicate my development environment on your machine.

## Important Note Before Installation

**WARNING:** The configurations and scripts in this repository are **HIGHLY PERSONALIZED** to my own preferences and workflows. If you decide to use them, please be aware that they will **MODIFY** your current system, potentially making some changes that are **IRREVERSIBLE** without a fresh installation of your operating system.

While I strive to back up files wherever possible, I cannot guarantee that all files are backed up. The backup mechanism is designed to back up SOME files **ONCE**. If the script is run more than once, the initial backups will be **OVERWRITTEN**, potentially resulting in data loss. 

If you would like a development environment similar to mine, I highly encourage you to fork this repository and make your own personalized changes to these scripts instead of running them exactly as I have them written for myself.

Any kind of corrections would be welcome!. I feel free to accept pull requests if there are any errors in my scripts.

If you choose to run these scripts, please do so with **EXTREME CAUTION**. It's recommended to review the scripts and understand the changes they will make to your system before proceeding.

By using these scripts, you acknowledge and accept the risk of potential data loss or system alteration. Proceed at your own risk.

## Getting Started

### Prerequisites

- This dotfiles setup is tailored for both macOS and Linux.

### Installation

1. Clone the repository to your local machine:
   ```sh
   git clone https://github.com/itsmeakashgoyal/dotfiles.git ~/dotfiles
   ```
2. Navigate to the `dotfiles` directory:
   ```sh
   cd ~/dotfiles
   ```
3. Generate a new SSH key and add to GitHub
   ```sh
   ./scripts/utils/_setup_ssh.sh -h
   ```
4. Use the Makefile to initiate the dotfiles installation
   ```sh
   make install
   ```
   Alternatively, run install script
   ```sh
   ./install.sh
   ```

This script will:
- Create symlinks for dotfiles (e.g., `.gitconfig`, `.zshrc`, etc.)
- Run macOS and Linux-specific configurations based on the operating system.

## Configuration Files

- **`settings/`**: Contains editor settings and themes for Sublime Text, Visual Studio Code, and iTerm terminal.
- **`scripts/`**: Contains common scripts to run while setting up the dotfiles.
- **`tmux/`**: Contains tmux configuration files.
- **`zsh/`**: Contains shell configuration files for Zsh.
- **`git/`**: Contains Git configuration files.
- **`dots/`**: Contains configurations that should be linked to the home directory.
- **`nvim/`**: Contains configurations for Neovim, managed as a Git submodule.
- **`nix/`**: Contains Nix configurations specific to Linux.
- **`packages/`**: Contains Homebrew installation scripts and other packages installation.

### Customizing Your Setup

You're encouraged to modify the scripts and configuration files to suit your preferences. Here are some tips for customization:

- **Sublime Text and VS Code**: Adjust settings in the `settings/` directory to change editor preferences and themes.

## Contributing

Feel free to fork this repository and customize it for your setup. Pull requests for improvements and bug fixes are welcome.

## License

This project is licensed under the BSD 2-Clause License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Thanks to all the open-source projects used in this setup.
