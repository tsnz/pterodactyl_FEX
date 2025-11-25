#!/bin/bash
set -e

supported_version=$(GetCPUFeaturesVersion.py)
installed_version=$([[ $(apt list --installed fex-emu-armv8*) =~ fex-emu-armv([0-9\.]+) ]] && echo "${BASH_REMATCH[1]}")

if [ "$supported_version" != "$installed_version" ]; then
    echo "WARNING! Detected FEX version mismatch! Supported: ${supported_version@Q} Installed : ${installed_version@Q}"
fi
