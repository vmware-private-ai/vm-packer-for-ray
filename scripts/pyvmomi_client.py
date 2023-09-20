import atexit
import ssl
from pyVim.connect import Disconnect, SmartConnect
from pyVmomi import vim


class PyvmomiClient:
    def __init__(self, server, user, password):
        self.smart_connect_obj = SmartConnect(
            host=server,
            user=user,
            pwd=password,
            sslContext=ssl._create_unverified_context(),
        )
        atexit.register(Disconnect, self.smart_connect_obj)

        self.pyvmomi_sdk_client = self.smart_connect_obj.content

    def get_client(self):
        return self.pyvmomi_sdk_client

    def list_pyvmomi_objs(self, vimtype):
        obj = None
        if self.pyvmomi_sdk_client is None:
            raise ValueError("Must init pyvmomi_sdk_client first.")

        container = self.pyvmomi_sdk_client.viewManager.CreateContainerView(
            self.pyvmomi_sdk_client.rootFolder, vimtype, True
        )

        return container.view

    def get_pyvmomi_obj(self, vimtype, name):
        """
        This function finds the vSphere object by the object name and the object type.
        The object type can be "VM", "Host", "Datastore", etc.
        The object name is a unique name under the vCenter server.
        To check all such object information, you can go to the managed object board
        page of your vCenter Server, such as: https://<your_vc_ip/mob
        """
        obj = None
        if self.pyvmomi_sdk_client is None:
            raise ValueError("Must init pyvmomi_sdk_client first.")

        container = self.pyvmomi_sdk_client.viewManager.CreateContainerView(
            self.pyvmomi_sdk_client.rootFolder, vimtype, True
        )

        for c in container.view:
            if c.name == name:
                obj = c
                return c

        return None
