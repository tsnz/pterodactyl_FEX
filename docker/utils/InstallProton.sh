#!/bin/bash
set -o pipefail

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -t PROTON_TAG -d INSTALL_DIR
Install proton version with tag PROTON_TAG to directory INSTALL_DIR
Environment variable PROTON_REPO_API_URL needs to be set to proton git hub repo's API URL

    -h          display this help and exit
    -t      proton version tag
    -d      target installation directory
EOF
}

get_tag() {
    jq -r ".tag_name" <<< "$1"
}

get_download_url() {
    jq -r ".assets[]|select(.content_type==\"application/gzip\").browser_download_url" <<< "$1"
}

while getopts ht:d: opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        t)
            tag="$OPTARG"
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

# Check if all needed arguments were provided
if [ -z "$PROTON_REPO_API_URL" ]; then
    echo "Environment variable PROTON_REPO_API_URL is not set"
    show_help >&2
    exit 1
fi

for arg in tag dir; do
    if [ -z "${!arg}" ]; then
        echo "Missing required argument for ${arg@Q}" >&2
        show_help >&2
        exit 1
    fi
done

# Create API URL
if [ "$tag" == "latest" ]; then
    api_endpoint="$PROTON_REPO_API_URL/releases/latest"
else
    api_endpoint="$PROTON_REPO_API_URL/releases/tags/$tag"
fi

# Request, exit if request fails
echo "requesting from url: ${api_endpoint@Q}"
if ! request_result=$(curl -f --silent --show-error "$api_endpoint"); then
    exit 1
fi

# Download proton and extract
url=$(get_download_url "$request_result")
mkdir -p "$dir"
echo "downloading from url: ${url@Q}"
if ! curl --silent --show-error -f -L "$url" | tar -zxv -C "$dir"; then
    exit 1
fi

# Create link if tag is latest
if [ "$tag" == "latest" ]; then
    result_tag=$(get_tag "$request_result")
    ln -sf "./$result_tag" "$dir/latest"
fi
