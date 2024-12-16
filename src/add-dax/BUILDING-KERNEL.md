This file provides instructions on how to create a Linux Kernel that allows
sharing through DAX for the gem5 disaggregated memory setup.

# Updating and Compiling Kernel

If you simply want to use our setup without making any changes to the kernel,
the simplest way would be to update the configs provided in this repository and
compile the kernel. Note that if you wish to use a different version of the
linux kernel, you may use the commands bellow but change the version number to
your desired version (eg linux-6.11.10 -> linux-6.12.1). Bellow is an example of updating and compiling an x86 kernel:

1. Download the Linux Kernel tarball
   ([Linux Kernel v6.11.10 tarball](https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.10.tar.xz)).
   - `$ wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.10.tar.xz`
2. Download required packages for building the kernel:
   - `$ sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison`
3. Extract the kernel directory
   - `$ tar xf linux-6.11.10.tar.xz`
4. Copy the config provided into the linux directory
   - `$ cd linux-6.11.10 && cp ../configs/config.x86.6.9.9 ./.config`
5. Update the old config
   - `$ yes "" | make oldconfig`
6. Compile the kernel
   - `$ make`
7. Add the kernel to your gem5 script
   - "kernel=KernelResource("<path-to-this-repo>/linux-6.11.10/vmlinux")"


# Building ARM Kernel

This section provides instructions on how to create an ARM Linux Kernel for the
gem5 disaggregated memory setup. **_Note that kernel
versions 6.6.63 and bellow do not have the necessary configs for the gem5
disaggregated setup and thus will NOT work. Versions newer than 6.11.10 or older
than 6.10.1 are untested_**

## Updating and Compiling Kernel

If you simply want to use our setup without making any changes to the kernel,
the simplest way would be to update the configs provided in this repository and
compile the kernel. Note that if you wish to use a different version of the
linux kernel, you may use the commands bellow but change the version number to
your desired version (eg linux-6.11.10 -> linux-6.12.1). Follow these steps to
achieve this:

1. Download the Linux Kernel tarball
   ([Linux Kernel v6.11.10 tarball](https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.10.tar.xz)).
2. Download required packages for building the kernel:
   - `$ sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison`
3. Extract the kernel directory
   - `$ tar xvf linux-6.11.10.tar.xz`
4. Copy the config provided into the linux directory
   - `$ cd linux-6.11.10 && cp ../configs/config.arm64.6.11.1 ./.config`
5. Update the old config
   - `$ yes "" | make oldconfig`
6. Compile the kernel
   - `$ make`

## Creating Kernel from Scratch

If you wish to enable specific configs follow these steps to get a kernel that
is compatible with the gem5 disaggregated setup.

1. Download the Linux Kernel tarball
   ([Linux Kernel v6.11.10 tarball](https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.10.tar.xz)).
2. Download required packages for building the kernel:
   - `$ sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison`
3. Extract the kernel directory
   - `$ tar xvf linux-6.11.10.tar.xz`
4. Download the gem5 kernel config file for arm to the Linux directory
   - `$ cd linux-6.11.10 && wget https://raw.githubusercontent.com/gem5/gem5-resources/refs/heads/stable/src/linux-kernel/linux-configs/config.arm64.5.4.49`
5. Rename and update the config file with defaults
   - `$ cp config.arm64.5.4.49 ./.config && yes "" | make oldconfig`
6. Enable the following configs: `$ make menuconfig`
   1. Memory Management options -> Memory hotplug (MEMORY_HOTPLUG)
   2. Memory Management options -> Memory hotplug -> Allow for memory hot remove
      (MEMORY_HOTREMOVE)
   3. Memory Management options -> Device memory (pmem, HMM, etc...) hotplug
      support (ZONE_DEVICE)
   4. Device Drivers -> NVDIMM (Non-Volatile Memory Device) Support (LIBNVDIMM)
   5. Device Drivers -> DAX: direct access to differentiated memory -> Device
      DAX: direct access mapping device (DEV_DAX)
   6. File systems -> File system based Direct Access (DAX) support (FS_DAX)

The main configs we want to enable here are DEV_DAX, so that we can access the
device and create a devdax namespace on it, and FS_DAX. If FS_DAX is not
enabled, a dmesg error will be thrown out saying that the vma is not DAX
capable.
