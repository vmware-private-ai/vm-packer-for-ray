# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

# vSphere credentials
vsphere_endpoint = "10.78.126.248"
vsphere_username = "administrator@vsphere.local"
vsphere_password = "JWNJ.Ww0bqkk6Zc."

# Frozen VM settings
# The vSphere cluster name for building the frozen VM.
vsphere_cluster = "x77-cluster"
# The ESXi host for building the frozen VM.
vsphere_host = "10.78.121.57"
# The network for the frozen VM
vsphere_network = "VM Network"
# The datastore for the frozen VM's vmdk, must be accessible by the vsphere_host
vsphere_datastore  = "vsanDatastore"

# The datastore for the iso image of the Frozen vm, the iso image will be uploaded
# to the root directory of this datastore by default
common_iso_datastore = "Datastore"

# The iso will be uploaded under this path of the datastore
# example: "" is the default config and means to upload to the root directory of the datastore.
# example: "iso_files/" means to upload to the "[Datastore] iso_files/" path.
# example: "linux_iso/debian/" means to upload to the "[Datastore] linux_iso/debian/" path
# If the path doesn't exist, it will be created on the datastore automatically
iso_path = "iso_files/"

# The content library name for exporting the OVF of the Frozen VM. If the content
# library doesn't exist, a new one will be created automatically
common_content_library_name = "test"
common_ray_docker_image = "harbor-repo.vmware.com/fudata/ray-on-vsphere:py38"