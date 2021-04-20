#!/bin/bash -e

if [ "${NO_PRERUN_QCOW2}" = "0" ]; then

	#IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"

	#IMGID="$(dd if="${IMG_FILE}" skip=440 bs=1 count=4 2>/dev/null | xxd -e | cut -f 2 -d' ')"

	#BOOT_PARTUUID="${IMGID}-01"
	#ROOT_PARTUUID="${IMGID}-02"

	sed -i "s;BOOTDEV;/dev/mmcblk0p1;" "${ROOTFS_DIR}/etc/fstab"
	sed -i "s;ROOTDEV;/dev/mmcblk0p2;" "${ROOTFS_DIR}/etc/fstab"
	echo "/dev/mmcblk0p4  /home           ext4    defaults,noatime  0       1" >> "${ROOTFS_DIR}/etc/fstab"

fi

