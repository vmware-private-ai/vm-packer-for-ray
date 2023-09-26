
# Advanced User guide for using VM Packer for Ray

## Table of Contents

1. [Introduction](#introduction)
2. [Configurations](#configurations)
3. [Build Manually](#build-manually)
4. [Reference](#reference)

## Introduction

In the [README](README.md), we instruct the user to fill in the basic configurations in the config.hcl file.
Actually, those configs will overwrite the configurations in [the packer variable hcl file](builds/vsphere.pkrvars.hcl).
The overwritten configurations will be used to build the frozen VM. 

Check the [script](scripts/run.sh) for the steps for building the frozen VM.

## Configurations

If you have the requirements for changing more variables to customize your frozen VM, you can edit the
`config/vsphere.pkrvars.hcl` file to configure the variables. The meaning of each variable can be found in their
[definitions](builds/linux/debian/variable.pkr.hcl).

**NOTE**: Currently, Debian 12 is the only Linux Distro we support and verified:
```hcl
vm_guest_os_family   = "linux"
vm_guest_os_name     = "debian"
vm_guest_os_version  = "12.0"
iso_path           = "debian-12.0.0-amd64-netinst.iso"
iso_checksum_type  = "sha512"
iso_checksum_value = "b462643a7a1b51222cd4a569dad6051f897e815d10aa7e42b68adc8d340932d861744b5ea14794daa5cc0ccfa48c51d248eda63f150f8845e8055d0a5d7e58e6"
```
If you would like this script to support another Linux distro, you should create a new directory under
[linux](builds/linux), then modify the above variables.

Below are some common configurations which you may want to modify:

### Add docker credential
Edit the following fields of `config/vsphere.pkrvars.hcl` file to add docker crendential.
```hcl
common_ray_docker_image = "rayproject/ray:latest"
common_ray_docker_repo = "docker.io"
common_ray_docker_username = "<your-docker-username>"
common_ray_docker_password = "<your-docker-password>"
```

### Create frozen vms for each host

Create frozen vms for each host by the following command with argument `--enable-frozenvm-each-host` :
```
bash create-frozen-vm.sh --enable-frozenvm-each-host
```
and the following configuration:

```hcl
frozen_vm_pool_name     = "<frozen-vm-pool-name>"
frozen_vm_prefix_name   = "<frozen_vm_prefix_name>"
```

Then, all frozen vms are created under resource pool `<frozen-vm-pool-name>`, with name `<frozen_vm_prefix_name>-1`,  `<frozen_vm_prefix_name>-2`... and `<frozen_vm_prefix_name>-n`

### Specify frozen vm name
Create frozen vm by the following configuration:
```hcl
frozen_vm_prefix_name   = "<frozen_vm_prefix_name>"
```

Then, the frozen vm is created with name `<frozen_vm_prefix_name>-1`.

### Change the password of user "ray"

The default username for the Ray nodes would be "ray", we recommend you to DO NOT change that.

The default password for the user Ray is "rayonvsphere", you can change that. Do remember to generate the encrypted
password which will be set into the "/etc/shadow" file by Packer.

The below are the examples for how to generate the encrypted password:

**Example**: mkpasswd using Docker on macOS:

```console
rainpole@macos> docker run -it --rm alpine:latest
mkpasswd -m sha512
Password: ***************
[password hash]
```

**Example**: mkpasswd on Ubuntu:

```console
rainpole@ubuntu> mkpasswd -m sha-512
Password: ***************
[password hash]
```

### Change the virtual machine version

The vm version will evolve with the new releases of vSphere, make sure the vm version is compatible with your vSphere.
```hcl
common_vm_version           = 20
```

### You could export the OVF to local if needed

Setting below variable to true will export the ovf to local, this will spend some time, so by default the value is false.
```hcl
common_ovf_export_enabled = true
```
### Specify Disk Capacity
Setting below variable to specify the size, in megabytes, of the hard disk to create for the frozen VM.
```
vm_disk_size             = 51200
```

## Build manually

You can manually do what our [one-click-script](create-frozen-vm.sh) does for you.

Do remember to upload the iso file to `common_iso_datastore` which can be accessed by the `vsphere_host`, and create the
content library with name `common_content_library_name`.

Then run:

```console
packer init builds/linux/debian
```

```console
packer build -force \
--only vsphere-iso.linux-debian \
-var-file="builds/vsphere.pkrvars.hcl" \
builds/linux/debian
```

## Reference

- For more information please refer to [Packer Examples for VMware vSphere](https://github.com/vmware-samples/packer-examples-for-vsphere)
