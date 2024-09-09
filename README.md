# Development Environment Setup

This repository contains scripts and configuration files to set up a development environment for macOS. It's tailored for software development, focusing on a clean, minimal, and efficient setup.

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

- macOS (The scripts are tailored for macOS but can be easily configured for linux as well)

### Installation

1. Clone the repository to your local machine:
   ```sh
   git clone https://github.com/itsmeakashgoyal/dotfiles-dev.git ~/dotfiles-dev
   ```
2. Navigate to the `dotfiles-dev` directory:
   ```sh
   cd ~/dotfiles-dev
   ```
3. Checkout master branch as master branch is specific to macOS setup.
    ```sh
    git checkout master
    ```
4. Run the installation script:
   ```sh
   ./setup.sh
   ```
5. Update the nvim git submodule
   - If it's the first time you check-out a repo you need to use --init first
    ```sh
    git submodule update --init --recursive
    ```
   - If its already checkout than, update the submodule
    ```sh
    git submodule update --recursive --remote
    ```

This script will:

- Create symlinks for dotfiles (`.gitconfig`, `.zshrc`, etc.)
- Run macOS-specific configurations
- Install Homebrew packages and casks
- Configure Sublime Text and Visual Studio Code

## Configuration Files

- `settings/`: Directory containing editor settings and themes for Sublime Text, Visual Studio Code and iterm terminal.
- `scripts/`: Containing common scripts to run while setting up the dotfiles.
- `tmux/`: Containing tmux config files
- `git/`: Containing git config file
- `zshrc/`: Containing Shell configuration files for Zsh.
- `bashrc/`: Containing Shell configuration files for Bash.
- `nvim/`: Another git submodule for my nvim config.

### Customizing Your Setup

You're encouraged to modify the scripts and configuration files to suit your preferences. Here are some tips for customization:

- **Sublime Text and VS Code**: Adjust settings in the `settings/` directory to change editor preferences and themes.

## Contributing

Feel free to fork this repository and customize it for your setup. Pull requests for improvements and bug fixes are welcome.

## License

This project is licensed under the BSD 2-Clause License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Thanks to all the open-source projects used in this setup.
