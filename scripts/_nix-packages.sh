#!/usr/bin/env bash

# install packages
nix-env -iA \
	nixpkgs.yarn \
	nixpkgs.direnv \
	nixpkgs.diff-so-fancy \
	nixpkgs.eza \
	nixpkgs.go \
	nixpkgs.gh
