#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ Makefile
# ░▓▓▓▓▓▓▓▓▓▓
#
# Stowable packages (directories with dotfiles)
STOW_PACKAGES := git zsh nvim tmux television bin atuin fastfetch starship

# Color codes
YELLOW := \033[33m
GREEN := \033[32m
RED := \033[31m
BLUE := \033[34m
WHITE := \033[37m
CLR := \033[0m

# Default target
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message (default)
	@echo "$(BLUE)╔════════════════════════════════════════════════════════╗$(CLR)"
	@echo "$(BLUE)║          Dotfiles Makefile - Available Commands        ║$(CLR)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════╝$(CLR)"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "}; \
		/^[^\t][a-zA-Z0-9_-]+:.*?##/ \
		{ printf "  $(GREEN)%-20s$(CLR) %s\n", $$1, $$2 } \
		/^##@/ { printf "\n$(YELLOW)%s$(CLR)\n", substr($$0, 5) }' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(WHITE)Available packages:$(CLR) $(STOW_PACKAGES)"
	@echo ""

##@ Installation

.PHONY: install
install: ## Bootstrap and install dotfiles
	@echo "$(YELLOW)Running bootstrap to provision the system...$(CLR)"
	@./install.sh
	@echo ""
	@echo "$(GREEN)✓ System provisioning complete!$(CLR)"
	@echo ""
	@echo "$(YELLOW)💡 Tip: Run 'make health' anytime to verify your setup$(CLR)"

##@ App Settings

.PHONY: apps
apps: sublime iterm ## Setup all app settings (Sublime Text + iTerm2)
	@echo "$(GREEN)✓ All app settings applied$(CLR)"

.PHONY: sublime
sublime: ## Setup Sublime Text settings
	@echo "$(YELLOW)Setting up Sublime Text...$(CLR)"
	@bash scripts/setup/sublime.sh

.PHONY: iterm
iterm: ## Setup iTerm2 preferences
	@echo "$(YELLOW)Setting up iTerm2...$(CLR)"
	@bash scripts/setup/iterm.sh

##@ Nix (the only package manager used on Linux)

# Flake lives in nix/; always applies the single "default" config (see
# nix/flake.nix) — no per-machine username/arch bookkeeping needed here.
NIX_FLAKE := ./nix

.PHONY: nix-setup
nix-setup: ## Install Nix + apply Home Manager packages (Linux, first-time)
	@echo "$(YELLOW)Setting up Nix + Home Manager...$(CLR)"
	@bash scripts/setup/nix.sh

.PHONY: nix-switch
nix-switch: ## Apply nix/home.nix changes (run after editing the package list)
	@command -v home-manager >/dev/null 2>&1 || { \
		echo "$(RED)Error:$(CLR) home-manager not found. Run 'make nix-setup' first,"; \
		echo "       then open a new shell so the Nix profile is on PATH."; \
		exit 1; \
	}
	@echo "$(BLUE)→$(CLR) Applying $(NIX_FLAKE)#default ..."
	@home-manager switch -b backup --flake "$(NIX_FLAKE)#default" --impure
	@echo "$(GREEN)✓ Home Manager packages applied$(CLR)"

.PHONY: nix-update
nix-update: ## Update package versions (flake update + switch)
	@command -v nix >/dev/null 2>&1 || { \
		echo "$(RED)Error:$(CLR) nix not found. Run 'make nix-setup' first."; \
		exit 1; \
	}
	@echo "$(YELLOW)Updating flake inputs...$(CLR)"
	@nix flake update --flake "$(NIX_FLAKE)"
	@$(MAKE) nix-switch
	@echo "$(GREEN)✓ Packages updated$(CLR)"

##@ Stow Management

.PHONY: run
run: check-stow ## Symlink all dotfiles with Stow
	@echo "$(YELLOW)Stowing all packages...$(CLR)"
	@for pkg in $(STOW_PACKAGES); do \
		if [ -d "$$pkg" ]; then \
			echo "  $(BLUE)→$(CLR) Stowing $$pkg..."; \
			stow $$pkg || exit 1; \
		else \
			echo "  $(RED)✗$(CLR) Package $$pkg not found"; \
			exit 1; \
		fi \
	done
	@echo "$(GREEN)✓ All dotfiles stowed successfully$(CLR)"

.PHONY: stow add
stow: check-stow ## Add individual package with Stow (usage: make stow pkg=<name>)
	@if [ -z "$(pkg)" ]; then \
		echo "$(RED)Error:$(CLR) Please specify a package to stow."; \
		echo "$(YELLOW)Usage:$(CLR) make stow pkg=<packageName>"; \
		echo "$(WHITE)Available packages:$(CLR) $(STOW_PACKAGES)"; \
		exit 1; \
	fi
	@if ! echo " $(STOW_PACKAGES) " | grep -q " $(pkg) "; then \
		echo "$(RED)Error:$(CLR) Package '$(pkg)' not found in STOW_PACKAGES"; \
		echo "$(WHITE)Available packages:$(CLR) $(STOW_PACKAGES)"; \
		exit 1; \
	fi
	@if [ ! -d "$(pkg)" ]; then \
		echo "$(RED)Error:$(CLR) Directory '$(pkg)' does not exist"; \
		exit 1; \
	fi
	@echo "$(BLUE)→$(CLR) Stowing $(pkg)..."
	@stow $(pkg)
	@echo "$(GREEN)✓$(CLR) $(pkg) stowed successfully"

.PHONY: unstow remove
unstow: check-stow ## Remove individual package with Stow (usage: make unstow pkg=<name>)
	@if [ -z "$(pkg)" ]; then \
		echo "$(RED)Error:$(CLR) Please specify a package to unstow."; \
		echo "$(YELLOW)Usage:$(CLR) make unstow pkg=<packageName>"; \
		echo "$(WHITE)Available packages:$(CLR) $(STOW_PACKAGES)"; \
		exit 1; \
	fi
	@if ! echo " $(STOW_PACKAGES) " | grep -q " $(pkg) "; then \
		echo "$(RED)Error:$(CLR) Package '$(pkg)' not found in STOW_PACKAGES"; \
		echo "$(WHITE)Available packages:$(CLR) $(STOW_PACKAGES)"; \
		exit 1; \
	fi
	@echo "$(BLUE)→$(CLR) Unstowing $(pkg)..."
	@stow --delete $(pkg)
	@echo "$(GREEN)✓$(CLR) $(pkg) unstowed successfully"

.PHONY: update up
update: check-stow ## Update all stowed packages
	@echo "$(YELLOW)Updating all stowed packages...$(CLR)"
	@for pkg in $(STOW_PACKAGES); do \
		if [ -d "$$pkg" ]; then \
			echo "  $(BLUE)→$(CLR) Restowing $$pkg..."; \
			stow --restow $$pkg || exit 1; \
		fi \
	done
	@echo "$(GREEN)✓ Dotfiles updated successfully$(CLR)"
	@echo "$(YELLOW)→$(CLR) Run $(BLUE)exec zsh$(CLR) to apply changes"

.PHONY: delete
delete: check-stow ## Delete all stowed dotfiles
	@echo "$(YELLOW)Removing all stowed packages...$(CLR)"
	@for pkg in $(STOW_PACKAGES); do \
		if [ -d "$$pkg" ]; then \
			echo "  $(BLUE)→$(CLR) Unstowing $$pkg..."; \
			stow --delete $$pkg || exit 1; \
		fi \
	done
	@echo "$(GREEN)✓ Dotfiles removed! ⚡️$(CLR)"

.PHONY: uninstall
uninstall: ## Gracefully uninstall everything (shell, symlinks, caches; opt-in packages/Nix)
	@STOW_PACKAGES="$(STOW_PACKAGES)" DRY_RUN="$(dry)" FORCE="$(force)" \
		bash scripts/setup/uninstall.sh

##@ Utilities

.PHONY: check-stow
check-stow: ## Verify stow is installed
	@command -v stow >/dev/null 2>&1 || { \
		echo "$(RED)Error:$(CLR) stow is not installed."; \
		echo "$(YELLOW)Install:$(CLR) brew install stow (macOS) or apt install stow (Linux)"; \
		exit 1; \
	}

.PHONY: print-%
print-%: ## Print a Makefile variable's value (usage: make print-STOW_PACKAGES)
	@echo $($*)

.PHONY: list
list: ## List all available stow packages
	@echo "$(BLUE)Available stow packages:$(CLR)"
	@for pkg in $(STOW_PACKAGES); do \
		if [ -d "$$pkg" ]; then \
			echo "  $(GREEN)✓$(CLR) $$pkg"; \
		else \
			echo "  $(RED)✗$(CLR) $$pkg (not found)"; \
		fi \
	done

.PHONY: verify
verify: ## Verify all package directories exist
	@echo "$(YELLOW)Verifying package directories...$(CLR)"
	@error=0; \
	for pkg in $(STOW_PACKAGES); do \
		if [ -d "$$pkg" ]; then \
			echo "  $(GREEN)✓$(CLR) $$pkg exists"; \
		else \
			echo "  $(RED)✗$(CLR) $$pkg missing"; \
			error=1; \
		fi \
	done; \
	if [ $$error -eq 0 ]; then \
		echo "$(GREEN)✓ All packages verified$(CLR)"; \
	else \
		echo "$(RED)✗ Some packages are missing$(CLR)"; \
		exit 1; \
	fi

.PHONY: clean
clean: ## Remove backup files created by stow
	@echo "$(YELLOW)Cleaning backup files...$(CLR)"
	@find ~ -maxdepth 1 -name ".*~" -type f -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(CLR)"

##@ Verification & Diagnostics

.PHONY: health
health: ## Run quick health check
	@bash scripts/verify/check.sh --quick || true

.PHONY: check
check: ## Run full installation verification
	@bash scripts/verify/check.sh --full || true

.PHONY: sysinfo
sysinfo: ## Display system information
	@bash scripts/verify/check.sh --system

.PHONY: packages
packages: ## Check installed packages against Brewfile
	@bash scripts/verify/check.sh --packages || true

.PHONY: diagnose
diagnose: ## Run all diagnostic tools
	@bash scripts/verify/check.sh --all || true

##@ Performance

.PHONY: bench
bench: ## Benchmark zsh startup time (requires hyperfine)
	@command -v hyperfine >/dev/null 2>&1 || { \
		echo "$(RED)Error:$(CLR) hyperfine is not installed."; \
		echo "$(YELLOW)Install:$(CLR) brew install hyperfine (macOS) or make nix-switch (Linux)"; \
		exit 1; \
	}
	@hyperfine --warmup 5 --shell=none 'zsh -i -c exit'

.PHONY: bench-detail
bench-detail: ## Profile zsh startup with zprof (function-level breakdown)
	@zsh scripts/dutils/profile_zsh.sh

##@ Windows

.PHONY: windows
windows: ## Show Windows setup instructions
	@echo "$(BLUE)Windows Setup$(CLR)"
	@echo ""
	@echo "  Run in PowerShell (as Admin or with Developer Mode enabled):"
	@echo ""
	@echo "  $(GREEN)Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser$(CLR)"
	@echo "  $(GREEN).\\install.ps1$(CLR)"
	@echo ""
	@echo "  Or run the setup script directly:"
	@echo "  $(GREEN)powershell -ExecutionPolicy Bypass -File scripts\\setup\\windows.ps1$(CLR)"
	@echo ""
	@echo "  Flags: -Force (overwrite existing), -SkipPackages, -SkipSymlinks"

##@ Aliases (shortcuts)

up: update      ## Alias for update
add: stow       ## Alias for stow
remove: unstow  ## Alias for unstow
