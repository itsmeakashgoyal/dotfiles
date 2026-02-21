#!/usr/bin/env bash
# Compatibility shim: all logging is now in _helper.sh
# This file exists so scripts that source _logger.sh directly continue to work.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_helper.sh"
