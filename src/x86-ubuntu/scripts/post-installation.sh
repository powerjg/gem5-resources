#!/bin/bash

# Copyright (c) 2020 The Regents of the University of California.
# SPDX-License-Identifier: BSD 3-Clause

echo 'Post Installation Started'

mv /home/gem5/serial-getty@.service /lib/systemd/system/

mv /home/gem5/exit.sh /root/
mv /home/gem5/gem5_init.sh /root/

# Add init script to bashrc
echo "/root/gem5_init.sh" >> /root/.bashrc

# Remove the motd
rm /etc/update-motd.d/*

# Build and install the m5 binary, library, and headers
echo "Building and installing m5 and libm5"
# Just get the files we need
git clone https://github.com/gem5/gem5 --depth=1 --filter=blob:none --no-checkout --sparse --single-branch --branch=stable
pushd gem5
git sparse-checkout add util/m5
git sparse-checkout add include
git checkout
# Install the headers
cp -r include/m5 /usr/local/include/
pushd util/m5
# Build the library and binary
scons build/x86/out/m5
cp build/x86/out/m5 /usr/local/bin/
cp build/x86/out/libm5.a /usr/local/lib/
popd
popd
rm -rf gem5
echo "Done building and installing m5 and libm5"

# You can extend this script to install your own packages here

# Disable network by default
echo "Disabling network by default"
mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak
netplan apply

echo 'Post Installation Done'
