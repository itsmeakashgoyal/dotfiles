#!/usr/bin/env zsh

# ------------------------------------------------------------------------------
# General Functions
# ------------------------------------------------------------------------------

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_"
}

# Wrapper for easy extraction of compressed files
function extract () {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.xz)    tar xvJf $1    ;;
			*.tar.bz2)   tar xvjf $1    ;;
			*.tar.gz)    tar xvzf $1    ;;
			*.bz2)       bunzip2 $1     ;;
			*.rar)       unrar e $1     ;;
			*.gz)        gunzip $1      ;;
			*.tar)       tar xvf $1     ;;
			*.tbz2)      tar xvjf $1    ;;
			*.tgz)       tar xvzf $1    ;;
			*.apk)       unzip $1       ;;
			*.epub)      unzip $1       ;;
			*.xpi)       unzip $1       ;;
			*.zip)       unzip $1       ;;
			*.war)       unzip $1       ;;
			*.jar)       unzip $1       ;;
			*.Z)         uncompress $1  ;;
			*.7z)        7z x $1        ;;
			*)           echo "don't know how to extract '$1'..." ;;
		esac
	else
		echo "'$1' is not a valid file!"
	fi
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
	local tmpFile="${@%/}.tar"
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1

	size=$(
		stat -f"%z" "${tmpFile}" 2>/dev/null # macOS `stat`
		stat -c"%s" "${tmpFile}" 2>/dev/null # GNU `stat`
	)

	local cmd=""
	if ((size < 52428800)) && hash zopfli 2>/dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli"
	else
		if hash pigz 2>/dev/null; then
			cmd="pigz"
		else
			cmd="gzip"
		fi
	fi

	echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…"
	"${cmd}" -v "${tmpFile}" || return 1
	[ -f "${tmpFile}" ] && rm "${tmpFile}"

	zippedSize=$(
		stat -f"%z" "${tmpFile}.gz" 2>/dev/null # macOS `stat`
		stat -c"%s" "${tmpFile}.gz" 2>/dev/null # GNU `stat`
	)

	echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully."
}

# Create a data URL from a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1")
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8"
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
	tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Creates a folder named with the current or prefixed date, using the format "prefix-YYYY-MM-DD" if a prefix is provided.
function mkdd() {
	mkdir -p ${1:+$1$prefix_separator}"$(date +%F)"
}

