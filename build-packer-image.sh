#!/bin/bash
# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

repository="packer-builder"
version=latest
os=debian-12.0.0-amd64

# Loop through the command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
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

if [ "$os" == "debian-12.0.0-amd64" ]; then
  iso_download_link="https://laotzu.ftp.acc.umu.se/cdimage/archive/12.0.0/amd64/iso-cd/debian-12.0.0-amd64-netinst.iso"
elif [ "$os" == "ubuntu-22.04.3-amd64" ]; then
  iso_download_link="https://releases.ubuntu.com/jammy/ubuntu-22.04.3-live-server-amd64.iso"
elif [ "$os" == "ubuntu-20.04.6-amd64" ]; then
  iso_download_link="https://releases.ubuntu.com/focal/ubuntu-20.04.6-live-server-amd64.iso"
else
  echo "Unsupported OS"
  exit 1
fi

if docker build --build-arg ISO_DOWNLOAD_LINK=${iso_download_link} -t ${repository}-"${os}":${version} .; then
  echo "Docker build succeeded"
else
  echo "Docker build failed"
  exit 1
fi
