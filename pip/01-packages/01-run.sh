#!/bin/bash

on_chroot << EOF
echo "Disabling lighttpd..."
systemctl disable lighttpd
EOF
