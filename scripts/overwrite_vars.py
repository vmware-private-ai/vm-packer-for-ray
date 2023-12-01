# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

import hcl
import sys

DEFAULT_CONFIG_PATH = "../builds/vsphere.pkrvars.hcl"


if len(sys.argv) < 4:
    raise RuntimeError(
        f"Unexpected: Usage: python {sys.argv[0]} <CONFIG_INPUT_FILE_PATH> <CONFIG_OUTPUT_FILE_PATH> ..."
    )
SOURCE_FILE_PATH = sys.argv[1]
TARGET_FILE_PATH = sys.argv[2]
OS_TYPE = sys.argv[3]

# Load the configurations from the source file
with open(SOURCE_FILE_PATH, "r") as source_file:
    source_config = hcl.load(source_file)

# Load the configurations from the target file
with open(DEFAULT_CONFIG_PATH, "r") as default_config:
    target_config = hcl.load(default_config)
    for key, value in source_config.items():
        if key in target_config:
            target_config[key] = value

if OS_TYPE == "debian-12.0.0-amd64":
    target_config["vm_guest_os_name"] = "debian"
    target_config["vm_guest_os_version"] = "12.0"
    target_config["vm_guest_os_type"] = "other5xLinux64Guest"
    target_config["iso_name"] = "debian-12.0.0-amd64-netinst.iso"
elif OS_TYPE == "ubuntu-22.04.3-amd64":
    target_config["vm_guest_os_name"] = "ubuntu"
    target_config["vm_guest_os_version"] = "22.04-lts"
    target_config["vm_guest_os_type"] = "ubuntu64Guest"
    target_config["iso_name"] = "ubuntu-22.04.3-live-server-amd64.iso"

with open(TARGET_FILE_PATH, "w") as target_file:
    hcl_content = hcl.dumps(target_config, indent=4)
    target_file.write(hcl_content)
    print(f"saved the generated json file to {TARGET_FILE_PATH}")
