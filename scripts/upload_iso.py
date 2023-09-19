# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

import ssl
import traceback
import sys
import hcl
import requests
from pyVim.connect import Disconnect, SmartConnect
from pyVmomi import vim
from pyvmomi_client import PyvmomiClient

# This is the path where we will store the iso file in our wizard container
LOCAL_ISO_PATH = "/dependencies/debian-12.0.0-amd64-netinst.iso"


class IsoUploader:
    def __init__(self, config_file):
        with open(config_file, "r") as f:
            config = hcl.load(f)
            self.vsphere_endpoint = config.get("vsphere_endpoint")
            self.vsphere_username = config.get("vsphere_username")
            self.vsphere_password = config.get("vsphere_password")
            self.iso_datastore = config.get("common_iso_datastore")
            self.iso_path = config.get("iso_path")
        self.pyvmomi_provider = PyvmomiClient(self.vsphere_endpoint, self.vsphere_username, self.vsphere_password)


    def get_dc_mo(self, datastore_mo):
        assert self.iso_datastore
        mo = datastore_mo
        while not isinstance(mo, vim.Datacenter):
            mo = mo.parent
        print(f"datacenter is {mo}")
        return mo

    def construct_upload_url(self):
        ip = self.vsphere_endpoint
        url = f"https://{ip}:443/folder/{self.iso_path}"
        return url

    def build_cookie(self):
        client_cookie = self.pyvmomi_provider.smart_connect_obj._stub.cookie
        cookie_name = client_cookie.split("=", 1)[0]
        cookie_value = client_cookie.split("=", 1)[1].split(";", 1)[0]
        cookie_path = (
            client_cookie.split(
                "=",
                1)[1].split(
                ";",
                1)[1].split(
                ";",
                1)[0].lstrip())
        cookie_text = " " + cookie_value + "; $" + cookie_path
        return {cookie_name: cookie_text}


if __name__ == "__main__":
    iu = None
    requests.packages.urllib3.disable_warnings(
        requests.packages.urllib3.exceptions.InsecureRequestWarning
    )
    if len(sys.argv) < 2:
        raise RuntimeError(
            f"Unexpected: Usage: python {sys.argv[0]} <CONFIG_FILE_PATH>"
        )
    try:
        # ssl_context = ssl.SSLContext(ssl.PROTOCOL_SSLv23)
        # ssl_context.verify_mode = ssl.CERT_NONE
        iu = IsoUploader(sys.argv[1])
        ds_mo = iu.pyvmomi_provider.get_pyvmomi_obj([vim.Datastore], iu.iso_datastore)
        dc_mo = iu.get_dc_mo(ds_mo)
        url = iu.construct_upload_url()
        print(f"the url for the upload is {url}")
        headers = {"Content-Type": "application/octet-stream"}
        cookie = iu.build_cookie()
        with open(LOCAL_ISO_PATH, "rb") as f:
            target_file_name = LOCAL_ISO_PATH.split("/")[-1]
            print("start to upload the Debian ISO file, will spend several minutes")
            res = requests.put(
                f"{url}{target_file_name}?dcPath={dc_mo.name}&dsName={ds_mo.name}",
                headers=headers,
                data=f,
                verify=False,
                cookies=cookie,
            )
            print(f"res is {res}")
        if 200 <= res.status_code < 300:
            print(f"file at {LOCAL_ISO_PATH} uploaded to datastore {ds_mo}")
        else:
            print(f"file upload with err code {res.status_code}")
            print(res.request)
    except:  # noqa: E722
        traceback.print_exc()
