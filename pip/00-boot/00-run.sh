#!/bin/bash

PIP_BOOT_DIR=$BASE_DIR/../boot

# 1) Install kernel from package

tar -xf ${KERNEL_PACKAGE} -C "${ROOTFS_DIR}/"

# 2) Build Pip custom overlays and install

pushd $PIP_BOOT_DIR
make clean && make
popd

install -m 644 $PIP_BOOT_DIR/overlays/*.dtbo "${ROOTFS_DIR}/boot/overlays/"
install -m 644 $PIP_BOOT_DIR/config.txt "${ROOTFS_DIR}/boot/config.txt"
install -m 644 $PIP_BOOT_DIR/dt-blob.bin "${ROOTFS_DIR}/boot/dt-blob.bin"

if [ "$DEBUG" = "1" ]; then
	install -m 644 $PIP_BOOT_DIR/cmdline-debug.txt "${ROOTFS_DIR}/boot/cmdline.txt"
	sudo install -m 600 -o root -g root files/wpa_supplicant.conf "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"
else
	install -m 644 $PIP_BOOT_DIR/cmdline.txt "${ROOTFS_DIR}/boot/cmdline.txt"
fi

# 3) Don't blacklist Realtek drivers

sudo rm -f "${ROOTFS_DIR}/etc/modprobe.d/blacklist-8192cu.conf"
sudo rm -f "${ROOTFS_DIR}/etc/modprobe.d/blacklist-rtl8xxxu.conf"

# 4) Network setup, for some reason this is missing

sudo install -m 644 -o root -g root files/interfaces "${ROOTFS_DIR}/etc/network/interfaces"

on_chroot << EOF
apt-get update
echo "Enabling wpa_supplicant..."
systemctl enable wpa_supplicant
EOF
