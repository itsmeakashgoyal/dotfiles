#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ Makefile
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░

# Stowable packages (directories with dotfiles)
STOW_PACKAGES := git zsh nvim tmux ohmyposh

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
	@bash scripts/setup/_sublime.sh

.PHONY: iterm
iterm: ## Setup iTerm2 preferences
	@echo "$(YELLOW)Setting up iTerm2...$(CLR)"
	@bash scripts/setup/_iterm.sh

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

##@ Utilities

.PHONY: check-stow
check-stow: ## Verify stow is installed
	@command -v stow >/dev/null 2>&1 || { \
		echo "$(RED)Error:$(CLR) stow is not installed."; \
		echo "$(YELLOW)Install:$(CLR) brew install stow (macOS) or apt install stow (Linux)"; \
		exit 1; \
	}

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
	@echo "$(YELLOW)Running health check...$(CLR)"
	@bash scripts/verification/health_check.sh || true

.PHONY: check
check: ## Run full installation verification
	@echo "$(YELLOW)Running full installation verification...$(CLR)"
	@bash scripts/verification/verify_installation.sh || true

.PHONY: sysinfo
sysinfo: ## Display system information
	@bash scripts/verification/system_info.sh

.PHONY: packages
packages: ## Check installed packages against Brewfile
	@bash scripts/verification/check_packages.sh || true

.PHONY: diagnose
diagnose: ## Run all diagnostic tools
	@echo "$(YELLOW)Running complete diagnostic suite...$(CLR)"
	@echo ""
	@bash scripts/verification/health_check.sh || true
	@echo ""
	@bash scripts/verification/verify_installation.sh || true
	@echo ""
	@bash scripts/verification/check_packages.sh || true
	@echo ""
	@echo "$(GREEN)✓ All diagnostics complete!$(CLR)"

##@ Aliases (shortcuts)

up: update      ## Alias for update
add: stow       ## Alias for stow
remove: unstow  ## Alias for unstow
