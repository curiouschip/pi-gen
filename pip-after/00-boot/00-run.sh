#!/bin/bash

PIP_BOOT_DIR=$BASE_DIR/../boot

pushd $PIP_BOOT_DIR
make
popd

install -m 644 $PIP_BOOT_DIR/overlays/*.dtbo "${ROOTFS_DIR}/boot/overlays/"
install -m 644 $PIP_BOOT_DIR/config.txt "${ROOTFS_DIR}/boot/config_pip.txt"
install -m 644 $PIP_BOOT_DIR/dt-blob.bin "${ROOTFS_DIR}/boot/dt-blob.bin"

