# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

/*
    DESCRIPTION:
    VMware vSphere variables used for all builds.
    - Variables are use by the source blocks.
*/

// vSphere Credentials
vsphere_endpoint            = "sfo-w01-vc01.rainpole.io"
vsphere_username            = "svc-packer-vsphere@rainpole.io"
vsphere_password            = "R@in!$aG00dThing."
vsphere_insecure_connection = true

// vSphere Settings
vsphere_cluster    = "sfo-w01-cl01"
vsphere_datastore  = "sfo-w01-cl01-ds-vsan01"
vsphere_network    = "sfo-w01-seg-dhcp"
vsphere_host       = "10.78.121.57"

// Ansible credential variables used for Linux builds.
// Variables are passed to and used by configuration scripts.
ansible_username = "ansible"
ansible_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxH/gSS8kErNVCfFxiYLJpi0t0/JrkcuAsGbUn20W2DSP1iqhJ/5cmEx2eHrEh3e5+qH/H4jZzY7zooz4qiEJ8yiWF09KcptKOlAq4JrIFzM+APR+74Qe9OBj4Jp+I5QmdomPgcz659X3iYfqYL4Kxs3vZ9sY4CnvIaY+lhqPyBpomZdBo6Dcek/HGb/ljKTfpHKujc9+5NouowAXhoRyS/rPMmZbt+xy+QUTBBe0VsbMfy7R8eSkHmbQhDugnqZ8Iyiy4zgQFFocWD38lBiXaPzYbDgcDM/JpQlhFuH4Xve/vr2KGef765699G+3Ia8t+MTlTUEbFxc395/YTUgmR"

// Default Account Credentials
// Variables are passed to and used by guest operating system configuration files (e.g., ks.cfg, autounattend.xml).
build_username           = "ray" //do not change the username as it is used by the Ray cluster
build_password           = "rayonvsphere"
build_password_encrypted = "$6$nJRHFmOOtbg2rYU4$FlFMaZ3BFMisZZ1C55jn7xwQUMTxGzdVptZfztPjWEOJuDOSFnKTXsjULxm3w/fsbAKb6s.AKKYhvLt2tqaLI0"
build_key                = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxH/gSS8kErNVCfFxiYLJpi0t0/JrkcuAsGbUn20W2DSP1iqhJ/5cmEx2eHrEh3e5+qH/H4jZzY7zooz4qiEJ8yiWF09KcptKOlAq4JrIFzM+APR+74Qe9OBj4Jp+I5QmdomPgcz659X3iYfqYL4Kxs3vZ9sY4CnvIaY+lhqPyBpomZdBo6Dcek/HGb/ljKTfpHKujc9+5NouowAXhoRyS/rPMmZbt+xy+QUTBBe0VsbMfy7R8eSkHmbQhDugnqZ8Iyiy4zgQFFocWD38lBiXaPzYbDgcDM/JpQlhFuH4Xve/vr2KGef765699G+3Ia8t+MTlTUEbFxc395/YTUgmR"

// Frozen Virtual Machine Settings
frozen_vm_pool_name     = "frozen-vms"
frozen_vm_prefix_name   = "frozen-vm"

// Virtual Machine Settings
common_vm_version           = 20
common_tools_upgrade_policy = true
common_remove_cdrom         = true

// Template and Content Library Settings
common_template_conversion         = false
common_content_library_name        = "sfo-w01-lib01"
common_content_library_ovf         = true
common_content_library_destroy     = false
common_content_library_skip_export = false

// OVF Export Settings
common_ovf_export_enabled   = false
common_ovf_export_overwrite = false

// Removable Media Settings
common_iso_datastore = "sfo-w01-cl01-ds-nfs01"

// Boot and Provisioning Settings
common_data_source      = "disk"
common_http_ip          = null
common_http_port_min    = 8000
common_http_port_max    = 8099
common_ip_wait_timeout  = "20m"
common_shutdown_timeout = "15m"

// Ray docker image
common_ray_docker_image = "rayproject/ray:latest"
common_ray_docker_repo = ""
common_ray_docker_username = ""
common_ray_docker_password = ""

// Guest Operating System Metadata
vm_guest_os_language = "en_US"
vm_guest_os_keyboard = "us"
vm_guest_os_timezone = "UTC"
vm_guest_os_family   = "linux"
vm_guest_os_name     = "debian"
vm_guest_os_version  = "12.0"

// Virtual Machine Guest Operating System Setting
vm_guest_os_type = "other5xLinux64Guest"

// Virtual Machine Hardware Settings
vm_firmware              = "efi"
vm_cdrom_type            = "sata"
vm_cpu_count             = 1
vm_cpu_cores             = 1
vm_cpu_hot_add           = true
vm_mem_size              = 4096
vm_mem_hot_add           = true
vm_disk_size             = 51200
vm_disk_controller_type  = ["pvscsi"]
vm_disk_thin_provisioned = true
vm_network_card          = "vmxnet3"

// Removable Media Settings
iso_path           = ""
iso_name           = "debian-12.0.0-amd64-netinst.iso"

// Boot Settings
vm_boot_order = "disk,cdrom"
vm_boot_wait  = "5s"

// Communicator Settings
communicator_port    = 22
communicator_timeout = "30m"

// Instant Clone Customization Engine setup path
instant_clone_customization_engine_path = "/dependencies/vmware-gosc_12.1.0.25580-20029049_amd64.deb"

// The url for the GPU driver
gpu_driver_download_url = ""