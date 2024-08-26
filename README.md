# Development Environment Setup

This repository contains scripts and configuration files to set up a development environment for macOS. It's tailored for software development, focusing on a clean, minimal, and efficient setup.

## Overview

The setup includes automated scripts for installing essential software, configuring Bash and Zsh shells, and setting up Sublime Text and Visual Studio Code editors. This guide will help you replicate my development environment on your machine if you desire to do so.

## Important Note Before Installation

**WARNING:** The configurations and scripts in this repository are **HIGHLY PERSONALIZED** to my own preferences and workflows. If you decide to use them, please be aware that they will **MODIFY** your current system, potentially making some changes that are **IRREVERSIBLE** without a fresh installation of your operating system.

Furthermore, while I strive to backup files wherever possible, I cannot guarantee that all files are backed up. The backup mechanism is designed to backup SOME files **ONCE**. If the script is run more than once, the initial backups will be **OVERWRITTEN**, potentially resulting in loss of data. While I could implement timestamped backups to preserve multiple versions, this setup is optimized for my personal use, and a single backup suffices for me.

If you would like a development environment similar to mine, I highly encourage you to fork this repository and make your own personalized changes to these scripts instead of running them exactly as I have them written for myself.

I likely won't accept pull requests unless they align closely with my personal preferences and the way I use my development environment. But if there are some obvious errors in my scripts then corrections would be welcome!

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
3. Run the installation script:
   ```sh
   ./setup.sh
   ```

This script will:

- Create symlinks for dotfiles (`.bashrc`, `.zshrc`, etc.)
- Run macOS-specific configurations
- Install Homebrew packages and casks
- Configure Sublime Text and Visual Studio Code

## Configuration Files



- `settings/`: Directory containing editor settings and themes for Sublime Text, Visual Studio Code and iterm terminal.
- `scripts/`: Containing common scripts to run while setting up the dotfiles.
- `tmux/`: Containing tmux config files
- `nvim/`: Containing nvim config files
- `git/`: Containing git config file
- `homebrew/`: Homebrew installed packages in my macbook.
- `zshrc/`: Containing Shell configuration files for Zsh.
    - `.aliases`: Aliases for common commands. Some are personalized to my machines specifically.
    - `.exports`: Exports for packages path.
    - `.functions`: Common useful functions.
    - `.private`: This is a file you'll create locally to hold private information and shouldn't be uploaded to version control
    - `.zshrc`: Shell configuration files for Bash and Zsh.
- `bashrc/`: Containing Shell configuration files for Bash.
    - `.bashrc`: Shell configuration files for Bash.
    - `.bash_profile`: Setting system-wide environment variables

### Customizing Your Setup

You're encouraged to modify the scripts and configuration files to suit your preferences. Here are some tips for customization:

- **Sublime Text and VS Code**: Adjust settings in the `settings/` directory to change editor preferences and themes.

## Contributing

Feel free to fork this repository and customize it for your setup. Pull requests for improvements and bug fixes are welcome, but as said above, I likely won't accept pull requests that simply add additional brew installations or change some settings unless they align with my personal preferences.

## License

This project is licensed under the BSD 2-Clause License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- My dotfiles repo is inspired from [Corey M Schafer' dotfiles](https://github.com/CoreyMSchafer/dotfiles) and [Omer Hamerman](https://github.com/omerxx/dotfiles)
- Thanks to all the open-source projects used in this setup.
