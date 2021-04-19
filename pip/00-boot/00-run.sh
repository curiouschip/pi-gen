#!/bin/bash

PIP_BOOT_DIR=$BASE_DIR/../boot

#
# Install kernel from package

tar -xf ${KERNEL_PACKAGE} -C "${ROOTFS_DIR}/"

#
# Create Pip directory structure

sudo install -d 755 -o root -g root "${ROOTFS_DIR}/opt/pip/etc"
sudo install -d 755 -o root -g root "${ROOTFS_DIR}/opt/pip/bin"
sudo install -d 755 -o root -g root "${ROOTFS_DIR}/opt/pip/var"
sudo install -d 755 -o root -g root "${ROOTFS_DIR}/opt/pip/lib"
sudo install -d 755 -o root -g root "${ROOTFS_DIR}/opt/pip/share/misc"

#
# Build Pip custom overlays

pushd $PIP_BOOT_DIR
make clean && make
popd

#
# Rejig /boot to support bank switching

# Create bank dir
install -d 755 "${ROOTFS_DIR}/boot/bank_a"

# Move everything to bank A then move the root stuff back
mv ${ROOTFS_DIR}/boot/* "${ROOTFS_DIR}/boot/bank_a"
mv "${ROOTFS_DIR}/boot/bank_a/bootcode.bin" "${ROOTFS_DIR}/boot/"
mv "${ROOTFS_DIR}/boot/bank_a/fixup_x.dat" "${ROOTFS_DIR}/boot/"
mv "${ROOTFS_DIR}/boot/bank_a/start_x.elf" "${ROOTFS_DIR}/boot/"

# Install dt-blob.bin in root
install -m 644 $PIP_BOOT_DIR/dt-blob.bin "${ROOTFS_DIR}/boot/dt-blob.bin"

# Install overlays and main config to bank A
install -m 644 $PIP_BOOT_DIR/overlays/*.dtbo "${ROOTFS_DIR}/boot/bank_a/overlays/"
install -m 644 $PIP_BOOT_DIR/config-bank.txt "${ROOTFS_DIR}/boot/bank_a/config.txt"

# Install root config
install -m 644 $PIP_BOOT_DIR/config-root.txt "${ROOTFS_DIR}/boot/config.txt"

# Install environment specific cmdline.txt
if [ "$DEBUG" = "1" ]; then
	install -m 644 $PIP_BOOT_DIR/cmdline-debug.txt "${ROOTFS_DIR}/boot/bank_a/cmdline.txt"
else
	install -m 644 $PIP_BOOT_DIR/cmdline.txt "${ROOTFS_DIR}/boot/bank_a/cmdline.txt"
fi

#
# Install /boot update files in image

sudo install -d 755 -o root -g root "${ROOTFS_DIR}/opt/pip/boot/root"
sudo cp -R ${ROOTFS_DIR}/boot/* "${ROOTFS_DIR}/opt/pip/boot/root"
sudo mv "${ROOTFS_DIR}/opt/pip/boot/root/bank_a" "${ROOTFS_DIR}/opt/pip/boot/bank"

#
# Don't blacklist Realtek drivers

sudo rm -f "${ROOTFS_DIR}/etc/modprobe.d/blacklist-8192cu.conf"
sudo rm -f "${ROOTFS_DIR}/etc/modprobe.d/blacklist-rtl8xxxu.conf"

#
# SAMD21 Firmware

sudo install -m 644 -o root -g root "${PIP_SAMD_FW}" "${ROOTFS_DIR}/opt/pip/share/misc/gpiobridge-firmware.bin"

#
# Network setup

# Interaces - for some reason this is missing
sudo install -m 644 -o root -g root files/interfaces "${ROOTFS_DIR}/etc/network/interfaces"

# Debug network config
if [ "$DEBUG" = "1" ]; then
	sudo install -m 600 -o root -g root files/wpa_supplicant.conf "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"
fi

# Enable wpa_supplicant
on_chroot << EOF
echo "Enabling wpa_supplicant..."
systemctl enable wpa_supplicant
EOF

#
# Install certificate

sudo install -d 755 -o root -g root "${ROOTFS_DIR}/opt/pip/etc/pip-updater"
sudo install -m 444 -o root -g root files/certificate.pem "${ROOTFS_DIR}/opt/pip/etc/pip-updater/certificate.pem"

#
# Set version

VERSION_FILE="${ROOTFS_DIR}/opt/pip/VERSION"
echo $PIP_VERSION | sudo tee $VERSION_FILE
sudo chown root:root VERSION_FILE
sudo chmod 444 VERSION_FILE
