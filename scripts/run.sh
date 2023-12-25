#!/bin/bash
# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

set -o errexit

skip_uploading_iso=false
enable_frozenvm_each_host=false
os=debian-12.0.0-amd64
if [ $# -lt 1 ]; then
    echo "Unexpected: Usage: $0 <packer_dir>"
    exit 1
fi

workdir=$1

# Loop through the command-line arguments
while [[ $# -gt 1 ]]; do
    case "$2" in
        --skip-uploading-iso)
            # Set the skip_uploading_iso variable to true if the parameter is provided
            skip_uploading_iso=true
            shift # Move to the next argument
            ;;
        --enable-frozenvm-each-host)
            # Set the enable_frozenvm_each_host variable to true if the parameter is provided
            enable_frozenvm_each_host=true
            shift # Move to the next argument
            ;;
        --os)
            # Set the os of frozen vm
            os=$3
            shift 2 # Move to the next argument
            ;;
        *)
            # If the argument doesn't match --skip-uploading-iso, skip it
            shift
            ;;
    esac
done

script_dir="${workdir}/scripts"
plugin_dir="${workdir}/plugins"
config_dir="${workdir}/config"
config_input_file="${config_dir}/config.hcl"
config_output_file="${config_dir}/vsphere.pkr.json"

# Use the variables in config/config.hcl to overwrite builds/vsphere.pkrvars.hcl, then generate config/vsphere.pkr.json
# packer can also take json file as an input.
cd "${script_dir}"
python overwrite_vars.py "${config_input_file}" "${config_output_file}" "${os}"

# Create a content library if it doesn't exist
python create_content_library.py "${config_input_file}"

# If skip_uploading_iso is not set, then the Debian iso will be uploaded to the datastore automatically.
if [ "$skip_uploading_iso" = true ]; then
    echo "Skipping uploading ISO"
else
    # Run the command to upload the ISO if the parameter is not provided
    python upload_iso.py "${config_output_file}"
fi

# Execute the packer commands
cd "${workdir}"
export PACKER_PLUGIN_PATH=${plugin_dir}

if [ "$os" == "debian-12.0.0-amd64" ]; then
    cp -f "${script_dir}"/customize-debian.sh "${script_dir}"/customize.sh
    packer init builds/linux/debian
    packer build -force --only vsphere-iso.linux-debian -var-file="${config_output_file}" builds/linux/debian
elif [ "$os" == "ubuntu-22.04.3-amd64" ]; then
    cp -f "${script_dir}"/customize-ubuntu.sh "${script_dir}"/customize.sh
    packer init builds/linux/ubuntu/22-04-lts
    packer build -force --only vsphere-iso.linux-ubuntu -var-file="${config_output_file}" builds/linux/ubuntu/22-04-lts
elif [ "$os" == "ubuntu-20.04.6-amd64" ]; then
    cp -f "${script_dir}"/customize-ubuntu.sh "${script_dir}"/customize.sh
    packer init builds/linux/ubuntu/20-04-lts
    packer build -force --only vsphere-iso.linux-ubuntu -var-file="${config_output_file}" builds/linux/ubuntu/20-04-lts
else
  echo "Unsupported OS"
  exit 1
fi

# If enable_frozenvm_each_host is set, then clone frozen-vm to each host
if [ "$enable_frozenvm_each_host" = true ]; then
    echo "Cloning frozen vm to each host"
    cd "${script_dir}"
    python clone_frozen_vm.py "${config_output_file}"
fi

cd -
