#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
usage() {
    echo "Usage: $0 /path/to/Makefile"
    exit 1
}

# Check if exactly one argument (Makefile path) is provided
if [ "$#" -ne 1 ]; then
    usage
fi

MAKEFILE_PATH="$1"

# Check if the provided Makefile exists
if [ ! -f "$MAKEFILE_PATH" ]; then
    echo "Error: Makefile not found at '$MAKEFILE_PATH'."
    exit 1
fi

# Function to extract a variable's value from the Makefile
extract_var() {
    local var_name="$1"
    grep -E "^${var_name}[:]?=" "$MAKEFILE_PATH" | head -n1 | cut -d'=' -f2 | tr -d ' ' || echo ""
}

# Extract necessary variables from the Makefile
PKG_NAME=$(extract_var "PKG_NAME")
PKG_VERSION=$(extract_var "PKG_VERSION")
PKG_SOURCE_URL=$(extract_var "PKG_SOURCE_URL")
PKG_SOURCE=$(extract_var "PKG_SOURCE")
PKG_HASH=$(extract_var "PKG_HASH")

# Validate extracted variables
if [ -z "$PKG_NAME" ] || [ -z "$PKG_VERSION" ] || [ -z "$PKG_SOURCE_URL" ] || [ -z "$PKG_SOURCE" ] || [ -z "$PKG_HASH" ]; then
    echo "Error: Failed to extract one or more required variables (PKG_NAME, PKG_VERSION, PKG_SOURCE_URL, PKG_SOURCE, PKG_HASH) from Makefile."
    exit 1
fi

# Resolve PKG_SOURCE by replacing variables (e.g., $(PKG_NAME), $(PKG_VERSION))
PKG_SOURCE_RESOLVED=$(echo "$PKG_SOURCE" | sed "s/\$(PKG_NAME)/$PKG_NAME/g" | sed "s/\$(PKG_VERSION)/$PKG_VERSION/g")

# Construct the full download URL by replacing variables in PKG_SOURCE_URL
DOWNLOAD_URL=$(echo "$PKG_SOURCE_URL" | sed "s/\$(PKG_NAME)/$PKG_NAME/g" | sed "s/\$(PKG_VERSION)/$PKG_VERSION/g")

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
wget -q -O "$DOWNLOAD_PATH" "$DOWNLOAD_URL"

# Verify that the download was successful
if [ ! -f "$DOWNLOAD_PATH" ]; then
    echo "Error: Failed to download the source tarball from '$DOWNLOAD_URL'."
    exit 1
fi

# Compute the SHA256 checksum
echo "Computing SHA256 checksum..."
NEW_HASH=$(sha256sum "$DOWNLOAD_PATH" | awk '{print $1}')

echo "Computed SHA256: $NEW_HASH"

# Update the PKG_HASH in the Makefile if it is incorrect
if [ "$NEW_HASH" != "$PKG_HASH" ]; then
    echo "Updating PKG_HASH in the Makefile..."

    # Use sed to replace the PKG_HASH line
    # This assumes PKG_HASH is defined as 'PKG_HASH:=<hash>'
    echo "Updating PKG_HASH in the Makefile..."
    sed -i "s/^PKG_HASH:=.*/PKG_HASH:=${NEW_HASH}/" "$MAKEFILE_PATH"

    echo "PKG_HASH has been updated to: $NEW_HASH"
else
    echo "PKG_HASH is already correct. No update needed."
fi

echo "Makefile update completed successfully."