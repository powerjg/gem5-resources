This file provides instructions on how to use the resouces in this repository to build a disk image for use with the gem5 disaggregated memory setup. For more in-depth information about building and extending your own disk image refer to the [gem5-resources directory](https://github.com/gem5/gem5-resources/tree/stable/src/ubuntu-generic-diskimages).

# Building x86 DAX Disk Image

- Download the disk image from the gem5 resources website:
	- `wget https://storage.googleapis.com/dist.gem5.org/dist/develop/images/x86/ubuntu-24-04/x86-ubuntu-24-04-v2.gz`
	- These can be found on the [gem5 resources website](https://resources.gem5.org/resources/x86-ubuntu-24.04-img?database=gem5-resources&version=2.0.0)
- Get the sha256 sum of the disk image
	- `sha256sum x86-ubuntu-24-04-v2`
- In the `packer-scripts/x86-add-dax.pkr.hcl` script, under `iso_checksum` and `iso_urls`, add the checksum and image name. Note that `iso_urls` expects a list of strings. Example:
	- `iso_checksum     = "sha256:6cedf26ebf281b823b24722341d3a2ab1f1ba26b10b536916d3f23cf92a8f4b5"`
	- `iso_urls         = ["./x86-ubuntu-24-04-v2"]`
- Download packer
	- `$ wget https://releases.hashicorp.com/packer/1.10.0/packer_${PACKER_VERSION}_linux_amd64.zip
	- `$ unzip packer_1.10.0_linux_amd64.zip`
	- `$ rm packer_1.10.0_linux_amd64.zip`
- Run the packer script
	- `$ packer init ./add-dax.pkr.hcl`
	- `$ packer build ./add-dax.pkr.hcl`
- Add the disk image to your gem5 script
    - "disk_image=DiskImageResource(
        "<path-to-this-repo>/disk-image/x86-ubuntu-24-04-dax"
    ),"
