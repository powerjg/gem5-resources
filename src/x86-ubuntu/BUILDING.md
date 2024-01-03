---
title: Building the base x86-ubuntu image
authors:
    - Ayaz Akram
---

This document provides instructions to create the "x86-ubuntu" image.

## Directory map

- `files`: Files that are copied to the disk image.
- `scripts`: Scripts run on the disk image after installation.
- `http`: cloud-init Ubuntu autoinstall files
- `disk-image`: The disk image output directory.

## Disk Image

Run `./build.sh` in the `disk-image` directory to build the disk image.
This will download the packer binary, initialize packer, and build the disk image.

Note: This can take a while to run.
You will see `qemu.initialize: Waiting for SSH to become available...` while the installation is running.
You can watch the installation with a VNC viewer.
See [Troubleshooting](#troubleshooting) for more information.

## Extending this disk image

You can extend the disk image by specializing what is run after installation by modifying the `x86-ubuntu/post-installation.sh` file.

## Creating a disk image from scratch

Instead of starting with our base image, if you want to create an image from scratch, you can automate the Ubuntu installation process after the first manual time by getting the `/var/log/installer/autoinstall-user-data` file from the guest OS and using it as the `user-data` file in the `shared` directory.

## Troubleshooting

To see what `packer` is doing, you can use the environment variable `PACKER_LOG=INFO` when running `./build.sh`.

Packer seems to have a bug that aborts the VM build after 2-5 minutes regardless of the ssh_timeout setting.
As a workaround, set ssh_handshake_attempts to a high value.
Thus, I have `ssh_handshake_attempts = 1000`.
From <https://github.com/rlaun/packer-ubuntu-22.04>

To see what is happening while packer is running, you can connect with a vnc viewer.
The port for the vnc viewer is shown in the terminal while packer is running.

You can mount the disk image to see what is inside.
Use the following command to mount the disk image:
(note `norecovery` is needed if you get the error "cannot mount ... read-only")

```sh
mkdir x86-ubuntu/mount
sudo mount -o loop,offset=2097152,norecovery x86-ubuntu/x86-ubuntu-image/x86-ubuntu x86-ubuntu/mount
```

Useful documentation: https://ubuntu.com/server/docs/install/autoinstall