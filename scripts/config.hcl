# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

# vSphere credentials
vsphere_endpoint = "your_vsphere_endpoint"
vsphere_username = "your_vsphere_user_name"
vsphere_password = "your_vsphere_password"

# Frozen VM settings
# The vSphere cluster name for building the frozen VM.
vsphere_cluster = "your_vsphere_cluster_name"
# The ESXi host for building the frozen VM.
vsphere_host = "your_vsphere_host_name"
# The network for the frozen VM
vsphere_network = "your_vsphere_network_name"
# The datastore for the frozen VM's vmdk, must be accessible by the vsphere_host
vsphere_datastore  = "your_vsphere_datastore_name"

# The datastore for the iso image of the Frozen vm, the iso image will be uploaded
# to the root directory of this datastore by default
common_iso_datastore = "your_vsphere_datastore_name"

# The iso will be uploaded under this path of the datastore
# example: "" is the default config and means to upload to the root directory of the datastore.
# example: "iso_files/" means to upload to the "[Datastore] iso_files/" path.
# example: "linux_iso/debian/" means to upload to the "[Datastore] linux_iso/debian/" path
# If the path doesn't exist, it will be created on the datastore automatically
iso_path = "iso_files/"

# The content library name for exporting the OVF of the Frozen VM. If the content
# library doesn't exist, a new one will be created automatically
common_content_library_name = "your_content_library_name"
common_ray_docker_image = "rayproject/ray:2.7.0"