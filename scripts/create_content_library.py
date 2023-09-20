# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: Apache-2.0

import ssl
import traceback
import uuid
import sys
import hcl
import requests
from com.vmware.cis_client import Session
from com.vmware.content.library_client import StorageBacking
from com.vmware.content_client import LibraryModel, LocalLibrary
from pyVim.connect import Disconnect, SmartConnect
from pyVmomi import vim
from vmware.vapi.lib.connect import get_requests_connector
from vmware.vapi.security.session import create_session_security_context
from vmware.vapi.security.user_password import create_user_password_security_context
from vmware.vapi.stdlib.client.factories import StubConfigurationFactory
from pyvmomi_client import PyvmomiClient


def get_unverified_session():
    session = requests.session()
    session.verify = False
    requests.packages.urllib3.disable_warnings()
    return session


def login(stub_config, user, pwd):
    user_password_security_context = create_user_password_security_context(
        user, pwd)
    stub_config.connector.set_security_context(user_password_security_context)
    session_svc = Session(stub_config)
    session_id = session_svc.create()
    session_security_context = create_session_security_context(session_id)
    stub_config.connector.set_security_context(session_security_context)
    return stub_config


class ContentLibService:
    def __init__(self, config_file):
        with open(config_file, "r") as f:
            config = hcl.load(f)
            self.vsphere_endpoint = config.get("vsphere_endpoint")
            self.vsphere_username = config.get("vsphere_username")
            self.vsphere_password = config.get("vsphere_password")
            self.vm_datastore = config.get("vsphere_datastore")
            self.common_content_library_name = config.get(
                "common_content_library_name")
        self.pyvmomi_provider = PyvmomiClient(
            self.vsphere_endpoint,
            self.vsphere_username,
            self.vsphere_password)
        self.cls = self.init_content_library_service()

    def connect(self):
        def get_jsonrpc_endpoint_url(host):
            # The URL for the stub requests are made against the /api HTTP endpoint
            # of the vCenter system.
            return "https://{}/api".format(host)

        vc_url = get_jsonrpc_endpoint_url(self.vsphere_endpoint)
        connector = get_requests_connector(
            session=get_unverified_session(), url=vc_url)
        stub_config = StubConfigurationFactory.new_std_configuration(connector)
        return login(stub_config, self.vsphere_username, self.vsphere_password)

    def init_content_library_service(self):
        local_library = LocalLibrary(self.connect())
        print("content library service inited")
        return local_library

    def list_content_libs(self):
        return self.cls.list()

    def get_content_lib_mo_with_uuid(self, uuid):
        return self.cls.get(uuid)

    def create_content_lib(self):
        storage_backing = [
            StorageBacking(
                type=StorageBacking.Type.DATASTORE,
                datastore_id=self.pyvmomi_provider.get_pyvmomi_obj([vim.Datastore], self.vm_datastore)._moId,
            )
        ]
        spec = LibraryModel(
            name=self.common_content_library_name,
            description="The content library to store the Frozen VM's OVF",
            type=LibraryModel.LibraryType.LOCAL,
            storage_backings=storage_backing,
        )
        self.cls.create(spec, str(uuid.uuid4()))
        print("submit the create content library task to VC successfully")


if __name__ == "__main__":
    s = None
    if len(sys.argv) < 2:
        raise RuntimeError(
            f"Unexpected: Usage: python {sys.argv[0]} <CONFIG_FILE_PATH>"
        )
    try:
        s = ContentLibService(sys.argv[1])
        libs = s.list_content_libs()
        content_lib_exist = False
        for lib_uuid in libs:
            lib_mo = s.get_content_lib_mo_with_uuid(lib_uuid)
            if lib_mo.name == s.common_content_library_name:
                print(
                    f"content lib with name {s.common_content_library_name} exists,"
                    f"no need to create one")
                content_lib_exist = True
                break
        if not content_lib_exist:
            s.create_content_lib()
    except:  # noqa: E722
        traceback.print_exc()
