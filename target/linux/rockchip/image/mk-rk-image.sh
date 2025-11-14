#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Rockchip update.img packing script for OpenWrt
# Based on Rockchip official tools

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="$1"
PARAMETER_FILE="$2"
OUTPUT_IMG="$3"
MINILOADER="$4"

if [ ! -d "$WORK_DIR" ] || [ ! -f "$PARAMETER_FILE" ] || [ -z "$OUTPUT_IMG" ]; then
    echo "Usage: $0 <work_dir> <parameter.txt> <output.img> <miniloader.bin>"
    echo "  work_dir: directory containing partition images"
    echo "  parameter.txt: partition table definition"
    echo "  output.img: output update image"
    echo "  miniloader.bin: optional miniloader binary"
    exit 1
fi

cd "$WORK_DIR"

# Parse partition names from parameter.txt
parse_partitions() {
    local param_file="$1"
    grep "^CMDLINE:" "$param_file" | sed 's/.*mtdparts=//' | \
        tr ',' '\n' | grep -oP '\(\K[^:)]+' || true
}

# Generate package-file
generate_package_file() {
    local pkg_file="package-file"
    
    {
        echo -e "# NAME\tPATH"
        echo -e "package-file\tpackage-file"
        echo -e "parameter\tparameter.txt"
    } > "$pkg_file"
    
    # Add bootloader if present
    if [ -n "$MINILOADER" ] && [ -f "$MINILOADER" ]; then
        echo -e "bootloader\t$(basename "$MINILOADER")" >> "$pkg_file"
    fi
    
    # Add partition images
    for part in $(parse_partitions "$PARAMETER_FILE"); do
        case "$part" in
            backup)
                echo -e "backup\tRESERVED" >> "$pkg_file"
                ;;
            *)
                local img_file="${part}.img"
                if [ -f "$img_file" ]; then
                    echo -e "$part\t$img_file" >> "$pkg_file"
                fi
                ;;
        esac
    done
    
    echo "Generated package-file:"
    cat "$pkg_file"
}

# Check required tools
check_tools() {
    local rk_tools_dir="$SCRIPT_DIR/rk-tools"
    
    if [ ! -f "$rk_tools_dir/afptool" ]; then
        echo "Error: afptool not found in $rk_tools_dir"
        echo "Please copy afptool from Rockchip SDK to $rk_tools_dir/"
        return 1
    fi
    
    # Make afptool executable
    chmod +x "$rk_tools_dir/afptool" 2>/dev/null || true
    
    export PATH="$rk_tools_dir:$PATH"
}

# Main packing process
main() {
    echo "=========================================="
    echo "  Rockchip Update Image Packing for OpenWrt"
    echo "=========================================="
    
    check_tools
    
    # Copy parameter file
    if [ "$PARAMETER_FILE" != "$PWD/parameter.txt" ]; then
        cp "$PARAMETER_FILE" parameter.txt
    fi
    
    # Link or copy miniloader
    if [ -n "$MINILOADER" ] && [ -f "$MINILOADER" ]; then
        local miniloader_name="$(basename "$MINILOADER")"
        if [ "$MINILOADER" != "$PWD/$miniloader_name" ]; then
            ln -sf "$MINILOADER" "$miniloader_name" 2>/dev/null || \
                cp "$MINILOADER" "$miniloader_name"
        fi
    fi
    
    # Generate package-file
    generate_package_file
    
    # Pack with afptool
    echo ""
    echo "Step 1: Packing images with afptool..."
    if ! command -v afptool >/dev/null 2>&1; then
        echo "Error: afptool not available"
        return 1
    fi
    
    # Create update.raw.img with afptool
    afptool -pack . update.raw.img
    
    if [ ! -f update.raw.img ]; then
        echo "Error: afptool failed to create update.raw.img"
        return 1
    fi
    
    echo "✓ afptool packing completed"
    
    # Step 2: Add bootloader signature with rkImageMaker
    if [ -n "$MINILOADER" ] && [ -f "$MINILOADER" ]; then
        echo ""
        echo "Step 2: Adding bootloader signature with rkImageMaker..."
        
        if ! command -v rkImageMaker >/dev/null 2>&1; then
            echo "Warning: rkImageMaker not available"
            echo "         Using update.raw.img without bootloader signature"
            mv update.raw.img "$OUTPUT_IMG"
        else
            # Use rkImageMaker to add bootloader signature
            # Syntax: rkImageMaker -RK3588 <miniloader> <input> <output> -os_type:androidos
            rkImageMaker -RK3588 "$(basename "$MINILOADER")" update.raw.img update.img -os_type:androidos
            
            if [ -f update.img ]; then
                echo "✓ rkImageMaker completed"
                if [ "$OUTPUT_IMG" != "$PWD/update.img" ]; then
                    mv update.img "$OUTPUT_IMG"
                fi
            else
                echo "Warning: rkImageMaker failed, using update.raw.img"
                mv update.raw.img "$OUTPUT_IMG"
            fi
        fi
    else
        echo ""
        echo "Warning: No miniloader provided, skipping rkImageMaker"
        echo "         Using update.raw.img as output"
        mv update.raw.img "$OUTPUT_IMG"
    fi
    
    echo ""
    echo "=========================================="
    echo "Successfully created: $OUTPUT_IMG"
    ls -lh "$OUTPUT_IMG"
    echo "=========================================="
}

main
