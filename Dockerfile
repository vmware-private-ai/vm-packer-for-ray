# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

FROM ubuntu:22.04
ARG ISO_DOWNLOAD_LINK

RUN apt update -y
RUN apt install -y wget  gpg lsb-release sudo
RUN bash -c 'wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg'
RUN gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
RUN bash -c 'echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list'
RUN apt update -y
RUN apt install -y packer terraform git jq xorriso whois curl

ARG GOMPLATE_VERSION="3.11.5"
ARG LINUX_ARCH="amd64"
RUN curl -o /usr/local/bin/gomplate -sSL https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-${LINUX_ARCH}
RUN chmod 755 /usr/local/bin/gomplate

RUN mkdir /dependencies
RUN wget -P /dependencies ${ISO_DOWNLOAD_LINK}
COPY dependencies/vmware-gosc_12.1.0.25580-20029049_amd64.deb /dependencies

ARG DEBIAN_FRONTEND=noninteractive
RUN apt install -y pipx

#RUN useradd -m ray
RUN adduser --disabled-password --gecos '' ray
RUN adduser ray sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ray
RUN pipx install ansible-core==2.15
RUN pipx ensurepath
ENV PATH /home/ray/.local/bin:/home/ray/.local/pipx/shared/bin:$PATH
RUN pip install pyhcl==0.4.5
RUN pip install requests
RUN pip install --upgrade git+https://github.com/vmware/vsphere-automation-sdk-python.git@v8.0.1.0
ENV PYTHONDONTWRITEBYTECODE=1
