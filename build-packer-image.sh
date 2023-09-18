#!/bin/bash
# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

repository="packer-builder"
version=latest

if docker build -t $repository:$version .; then
  echo "Docker build succeeded"
else
  echo "Docker build failed"
  exit 1
fi
