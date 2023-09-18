#!/bin/bash
# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

version=latest
repository="packer-builder"

if [ $? -ne 0 ]
then
    echo "Login failed"
    exit 1
fi
docker build -t harbor-repo.vmware.com/ray/$repository:$version .
if [ $? -ne 0 ]
then
    echo "Docker build failed"
    exit 1
fi
