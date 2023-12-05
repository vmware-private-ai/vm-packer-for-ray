#!/bin/bash
# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

set -e

cd "$(dirname "$0")"

skip_uploading_iso=false
enable_frozenvm_each_host=false
os=debian-12.0.0-amd64
repository="packer-builder"
version=latest


# Loop through the command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
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
            os=$2
            shift 2 # Move to the next argument
            ;;
        *)
            # If the argument doesn't match --skip-uploading-iso, skip it
            shift
            ;;
    esac
done

packer_builder_image="${repository}-${os}:${version}"
# Build packer-builder image if not exists
if [[ "$(docker images -q "${packer_builder_image}" 2> /dev/null)" == "" ]]; then
  ./build-packer-image.sh --os "${os}"
fi

# Generate key pairs if not exists
private_key_name=~/ray-bootstrap-key.pem
public_key_name=~/ray_bootstrap_public_key.key
if [[ -f ${private_key_name} && -f ${public_key_name} ]]; then
  echo "Skipping generate key pairs"
else
  rm -f ${private_key_name} ${public_key_name}
  ssh-keygen -t rsa -b 2048 -f ${private_key_name} -q -N ""
  cp -f ${private_key_name}.pub ${public_key_name}
  rm -f ${private_key_name}.pub
  echo "Generated a public key under ${public_key_name}, and generate its private key under ${private_key_name}."
  echo 'Note: When running "ray up" on another machine with the Frozen VM created by this script, above key pair must be
copied to the same directory with the same name on the other machine.'
fi

# Read public key and write to config.hcl
public_key=$(cat ~/ray_bootstrap_public_key.key)

base_config_file=scripts/config.hcl
config_file=config/config.hcl
mkdir -p config
cp -f ${base_config_file} ${config_file}
echo "" >> ${config_file}
# Check if build_key already exists
if grep -q ansible_key ${config_file}; then
  echo "ansible_key already exists in ${config_file}"
else
  echo "ansible_key: \"$public_key\"" >> ${config_file}
fi

# Check if build_key already exists
if grep -q build_key ${config_file}; then
  echo "build_key already exists in ${config_file}"
else
  echo "build_key: \"$public_key\"" >> ${config_file}
fi
echo "Generated key written to ${config_file}"

command_in_container="bash /home/packer/scripts/run.sh /home/packer"

if [ "$skip_uploading_iso" = true ]; then
    command_in_container="${command_in_container} --skip-uploading-iso"
fi

if [ "$enable_frozenvm_each_host" = true ]; then
    command_in_container="${command_in_container} --enable-frozenvm-each-host"
fi

command_in_container="${command_in_container} --os ${os}"

chmod o+w config
chmod o+w manifests
# Launch packer build
container_name=${repository}

docker run --tty --rm --name ${container_name} -v \
"$(pwd)":/home/packer:rw "${packer_builder_image}" \
bash -c "$command_in_container"


chmod o-w config
chmod o-w manifests
echo "Packer build finished."