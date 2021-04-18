#!/bin/bash

PIP_BOOT_DIR=$BASE_DIR/../boot
LINUX_PACKAGE=$BASE_DIR/../kernel.tar.xz

# 1) Install kernel from package

tar -xf ${LINUX_PACKAGE} -C "${ROOTFS_DIR}/"

# 2) Build Pip custom overlays and install

pushd $PIP_BOOT_DIR
make
popd

install -m 644 $PIP_BOOT_DIR/overlays/*.dtbo "${ROOTFS_DIR}/boot/overlays/"
install -m 644 $PIP_BOOT_DIR/config.txt "${ROOTFS_DIR}/boot/config.txt"
install -m 644 $PIP_BOOT_DIR/cmdline.txt "${ROOTFS_DIR}/boot/cmdline.txt"
install -m 644 $PIP_BOOT_DIR/dt-blob.bin "${ROOTFS_DIR}/boot/dt-blob.bin"

on_chroot << EOF
apt-get update
EOF

