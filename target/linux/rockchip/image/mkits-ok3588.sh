#!/bin/sh
#
# Create FIT image for OK3588 that matches factory U-Boot expectations
#
# Factory U-Boot expects:
# - Configuration name: "conf" (not "config-1")
# - Kernel node: "kernel" (not "kernel-1")
# - FDT node: "fdt" (not "fdt-1")
# - Load addresses: 0xffffff01 for kernel, 0xffffff00 for fdt
# - NO COMPRESSION (factory U-Boot doesn't support gzip!)
#

KERNEL="$1"
DTB="$2"
OUTPUT="$3"
VERSION="$4"

if [ -z "$KERNEL" ] || [ -z "$DTB" ] || [ -z "$OUTPUT" ] || [ -z "$VERSION" ]; then
    echo "Usage: $0 <kernel> <dtb> <output.img> <version>"
    exit 1
fi

# Create FIT image source (.its) file matching factory format
# IMPORTANT: No compression! Factory U-Boot doesn't support gzip
cat > "${OUTPUT}.its" <<EOF
/dts-v1/;

/ {
    description = "U-Boot FIT source file for arm";
    #address-cells = <1>;

    images {
        kernel {
            description = "Linux Kernel";
            data = /incbin/("${KERNEL}");
            type = "kernel";
            arch = "arm64";
            os = "linux";
            compression = "none";
            load = <0xffffff01>;
            entry = <0xffffff01>;
            hash-1 {
                algo = "sha256";
            };
        };

        fdt {
            description = "Device Tree Blob";
            data = /incbin/("${DTB}");
            type = "flat_dt";
            arch = "arm64";
            compression = "none";
            load = <0xffffff00>;
            hash-1 {
                algo = "sha256";
            };
        };
    };

    configurations {
        default = "conf";
        conf {
            description = "OpenWrt ${VERSION} for OK3588";
            kernel = "kernel";
            fdt = "fdt";
        };
    };
};
EOF

# Build FIT image using mkimage
mkimage -f "${OUTPUT}.its" -E "${OUTPUT}"

# Clean up temporary files
rm -f "${OUTPUT}.its"

echo "Created OK3588 FIT image: ${OUTPUT} (uncompressed, ~35MB)"
