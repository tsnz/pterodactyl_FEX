#!/bin/bash
set -e

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -d INSTALL_DIR
Install Steam CMD to directory INSTALL_DIR

    -h      display this help and exit
    -d      target installation directory
EOF
}

while getopts hd: opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        d)
            dir="$OPTARG"
            ;;
        *)
            show_help >&2
            exit 1
            ;;
    esac
done

if [ -z "$dir" ]; then
    echo "Missing required argument for 'dir'" >&2
    show_help >&2
    exit 1
fi


# Download and extract
mkdir -p "$dir"
url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
curl --silent --show-error -f -L "$url" | tar -zxv -C "$dir"

# Run Steam CMD to finish set up
FEXBash "$dir/steamcmd.sh +quit"

# Create links needed for proton
mkdir -p "$HOME/.steam"
ln -sf "$(realpath --no-symlinks "$dir")/linux64" "$HOME/.steam/sdk64"
ln -sf "./steamclient.so" "$dir/linux64/steamservice.so"
ln -sf "$(realpath --no-symlinks "$dir")/linux32" "$HOME/.steam/sdk32"
ln -sf "./steamclient.so" "$dir/linux32/steamservice.so"
