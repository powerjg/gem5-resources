# How to enable sharing through DAX on the ARM Kernel
## Dependencies
- linux-6.11.1 directory ([Linux Kernel v6.11.1 tarball](https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.1.tar.xz)).
- [gem5 repository]([GitHub - gem5/gem5: The official repository for the gem5 computer-system architecture simulator.](https://github.com/gem5/gem5)).
## Updating config file and adding DAX support
1. Download the gem5 kernel config file for arm to the Linux directory
	- `$ wget https://raw.githubusercontent.com/gem5/gem5-resources/refs/heads/stable/src/linux-kernel/linux-configs/config.arm64.5.4.49`
2. Rename and update the config file with defaults
	- `$ cp config.arm64.5.4.49 ./.config && yes "" | make oldconfig`
3. Enable the following configs in `make menuconfig`
	1. Memory Management options -> Memory hotplug (MEMORY_HOTPLUG)
	2. Memory Management options -> Memory hotplug  -> Allow for memory hot remove (MEMORY_HOTREMOVE)
	3. Memory Management options -> Device memory (pmem, HMM, etc...) hotplug support (ZONE_DEVICE)
	4. Device Drivers -> NVDIMM (Non-Volatile Memory Device) Support (LIBNVDIMM)
	5. Device Drivers -> DAX: direct access to differentiated memory -> Device DAX: direct access mapping device (DEV_DAX)
	6. File systems -> File system based Direct Access (DAX) support (FS_DAX)

The main configs we want to enable here are DEV_DAX, so that we can access the device and create a devdax namespace on it, and FS_DAX. If FS_DAX is not enabled, a dmesg error will be thrown out saying that the vma is not DAX capable.
