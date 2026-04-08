#!/bin/bash

# Function to extract a variable's value from the Makefile
extract_var() {
    local var_name="$1"
    local makefile_path="$2"
    grep -E "^${var_name}([ \t]*:?=)[ \t]*" "$makefile_path" | head -n1 | sed -E "s/^${var_name}([ \t]*:?=)[ \t]*//"
}

# Exit immediately if a command exits with a non-zero status
set -e

# Define default packages to update when no arguments are provided
DEFAULT_PACKAGES=(
    "package/feeds/packages/xfrpc/Makefile"
    "package/feeds/packages/apfree-wifidog/Makefile"
    "package/feeds/packages/kcptun/Makefile"
)

# Function to display usage information
usage() {
    echo "Usage: $0 [/path/to/Makefile]"
    echo "  - If no Makefile is specified, the script will update hash values for default packages"
    echo "  - If a Makefile path is provided, the script will update only that package"
    exit 1
}

# Function to update a single Makefile's hash
update_pkg_hash() {
    local MAKEFILE_PATH="$1"
    echo "=============================================="
    echo "Processing Makefile: $MAKEFILE_PATH"
    
    # Check if the provided Makefile exists
    if [ ! -f "$MAKEFILE_PATH" ]; then
        echo "Error: Makefile not found at '$MAKEFILE_PATH'. Skipping."
        return 1
    fi
    

    # Extract necessary variables from the Makefile
    PKG_NAME=$(extract_var "PKG_NAME" "$MAKEFILE_PATH")
    PKG_VERSION=$(extract_var "PKG_VERSION" "$MAKEFILE_PATH")
    PKG_SOURCE_URL=$(extract_var "PKG_SOURCE_URL" "$MAKEFILE_PATH")
    PKG_SOURCE=$(extract_var "PKG_SOURCE" "$MAKEFILE_PATH")
    PKG_HASH=$(extract_var "PKG_HASH" "$MAKEFILE_PATH")

    # Validate extracted variables
    if [ -z "$PKG_NAME" ] || [ -z "$PKG_VERSION" ] || [ -z "$PKG_SOURCE_URL" ] || [ -z "$PKG_SOURCE" ] || [ -z "$PKG_HASH" ]; then
        echo "Error: Failed to extract one or more required variables (PKG_NAME, PKG_VERSION, PKG_SOURCE_URL, PKG_SOURCE, PKG_HASH) from Makefile."
        return 1
    fi

    echo "Package: $PKG_NAME, Version: $PKG_VERSION"

    # Resolve PKG_SOURCE by replacing variables
    PKG_SOURCE_RESOLVED=$(echo "$PKG_SOURCE" \
        | sed "s|\$(PKG_NAME)|$PKG_NAME|g" \
        | sed "s|\$(PKG_VERSION)|$PKG_VERSION|g" \
        | sed "s|\${PKG_NAME}|$PKG_NAME|g" \
        | sed "s|\${PKG_VERSION}|$PKG_VERSION|g")

    # Construct the full download URL by replacing variables in PKG_SOURCE_URL
    DOWNLOAD_URL=$(echo "$PKG_SOURCE_URL" \
        | sed "s|\$(PKG_NAME)|$PKG_NAME|g" \
        | sed "s|\$(PKG_VERSION)|$PKG_VERSION|g" \
        | sed "s|\${PKG_NAME}|$PKG_NAME|g" \
        | sed "s|\${PKG_VERSION}|$PKG_VERSION|g")

    echo "Constructed Download URL: $DOWNLOAD_URL"

    # Create the dl directory if it doesn't exist
    DL_DIR="./dl"
    mkdir -p "$DL_DIR"

    # Define the path to the downloaded file
    DOWNLOAD_PATH="$DL_DIR/$PKG_SOURCE_RESOLVED"

    # Remove the existing file if it exists
    if [ -f "$DOWNLOAD_PATH" ]; then
        echo "Removing existing file: $DOWNLOAD_PATH"
        rm -f "$DOWNLOAD_PATH"
    fi

    # Download the source tarball
    echo "Downloading source tarball..."
    wget -q -O "$DOWNLOAD_PATH" "$DOWNLOAD_URL" || {
        echo "Error: Failed to download from '$DOWNLOAD_URL'."
        return 1
    }

    # Verify that the download was successful
    if [ ! -f "$DOWNLOAD_PATH" ]; then
        echo "Error: Failed to download the source tarball from '$DOWNLOAD_URL'."
        return 1
    fi

    # Compute the SHA256 checksum
    echo "Computing SHA256 checksum..."
    NEW_HASH=$(sha256sum "$DOWNLOAD_PATH" | awk '{print $1}')

    echo "Current Hash: $PKG_HASH"
    echo "Computed Hash: $NEW_HASH"

    # Update the PKG_HASH in the Makefile if it is incorrect
    if [ "$NEW_HASH" != "$PKG_HASH" ]; then
        echo "Updating PKG_HASH in the Makefile..."

        # Use sed to replace the PKG_HASH line
        # This assumes PKG_HASH is defined as 'PKG_HASH:=<hash>'
        sed -i "s/^PKG_HASH:=.*/PKG_HASH:=${NEW_HASH}/" "$MAKEFILE_PATH"
        echo "PKG_HASH has been updated to: $NEW_HASH"
    else
        echo "PKG_HASH is already correct. No update needed."
    fi
    
    echo "Makefile update completed."
    return 0
}

# Process arguments and determine which Makefiles to update
if [ "$#" -eq 0 ]; then
    # No arguments provided, use default packages
    echo "No Makefile specified, updating default packages..."
    
    # Array to track any failed updates
    FAILED_UPDATES=()
    
    # Process each default package
    for MAKEFILE in "${DEFAULT_PACKAGES[@]}"; do
        if ! update_pkg_hash "$MAKEFILE"; then
            FAILED_UPDATES+=("$MAKEFILE")
        fi
    done
    
    # Report any failures
    if [ ${#FAILED_UPDATES[@]} -gt 0 ]; then
        echo "=============================================="
        echo "WARNING: The following packages failed to update:"
        for FAILED in "${FAILED_UPDATES[@]}"; do
            echo "  - $FAILED"
        done
        exit 1
    fi
    
    echo "=============================================="
    echo "All package hash updates completed successfully."
    
elif [ "$#" -eq 1 ]; then
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        usage
    fi
    
    MAKEFILE_PATH="$1"
    update_pkg_hash "$MAKEFILE_PATH" || exit 1
else
    echo "Error: Too many arguments provided."
    usage
fi