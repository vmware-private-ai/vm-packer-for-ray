#!/bin/bash
# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

set -x
exec 2>/root/ic-customization.log

echo -e "Wait for cloud init is done...\n"

STATUS_FILE="/var/lib/cloud/instance/boot-finished"

while [ ! -f "$STATUS_FILE" ]; do
    sleep 5
done

echo -e "Stop networking services...\n"

systemctl stop networking.service
systemctl stop resolvconf.service

echo -e "Freezing ...\n"

vmware-rpctool "instantclone.freeze"

echo -e "\n=== Start Post-Freeze ==="

for NETDEV in /sys/class/net/e*
do
        DEVICE_LABEL=$(basename "$(readlink -f "$NETDEV/device")")
        DEVICE_DRIVER=$(basename "$(readlink -f "$NETDEV/device/driver")")
        echo "$DEVICE_LABEL" > /sys/bus/pci/drivers/"$DEVICE_DRIVER"/unbind
        echo "$DEVICE_LABEL" > /sys/bus/pci/drivers/"$DEVICE_DRIVER"/bind
done

uuid_number=$(cat /proc/sys/kernel/random/uuid)
echo "Updating Hostname ..."
hostnamectl set-hostname "${uuid_number}"

echo "Restart networking ..."

systemctl restart networking.service
systemctl restart resolvconf.service

echo "=== End of Post-Freeze ==="

echo -e "\nCheck /root/network.log for details\n\n"

sleep 30
ping -c 1 vmware.com