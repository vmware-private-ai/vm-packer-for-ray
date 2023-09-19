import traceback
import sys
import json
from pyvmomi_client import PyvmomiClient
from pyVmomi import vim
from pyVim.task import WaitForTask

class CloneFrozenVMService:
    def __init__(self, config_file):
        with open(config_file, "r") as f:
            f = open(config_file)
            config = json.load(f)
            self.frozen_vm_pool_name = config.get("frozen_vm_pool_name")
            self.vsphere_endpoint = config.get("vsphere_endpoint")
            self.vsphere_username = config.get("vsphere_username")
            self.vsphere_password = config.get("vsphere_password")
            self.frozen_vm_prefix_name = config.get("frozen_vm_prefix_name")
        self.pyvmomi_provider = PyvmomiClient(self.vsphere_endpoint, self.vsphere_username, self.vsphere_password)
        
    def create_resource_pool_if_not_exists(self):
        # create resource pool if not exists
        frozen_vm_pool = self.pyvmomi_provider.get_pyvmomi_obj([vim.ResourcePool], self.frozen_vm_pool_name)
        if frozen_vm_pool is not None:
            return frozen_vm_pool
        
        resource_pool_spec = vim.ResourceConfigSpec()
        resource_pool_spec.cpuAllocation = vim.ResourceAllocationInfo()
        resource_pool_spec.cpuAllocation.limit = -1  # Unlimited CPU
        resource_pool_spec.cpuAllocation.reservation = 0
        resource_pool_spec.cpuAllocation.expandableReservation = True
        resource_pool_spec.cpuAllocation.shares = vim.SharesInfo()
        resource_pool_spec.cpuAllocation.shares.level = "normal"
        
        resource_pool_spec.memoryAllocation = vim.ResourceAllocationInfo()
        resource_pool_spec.memoryAllocation.limit = -1  # Unlimited memory
        resource_pool_spec.memoryAllocation.reservation = 0
        resource_pool_spec.memoryAllocation.expandableReservation = True
        resource_pool_spec.memoryAllocation.shares = vim.SharesInfo()
        resource_pool_spec.memoryAllocation.shares.level = "normal"
        
        pyvmomi_client = self.pyvmomi_provider.get_client()
        
        root_resource_pool = pyvmomi_client.rootFolder.childEntity[0].hostFolder.childEntity[0].resourcePool
        frozen_vm_pool = root_resource_pool.CreateResourcePool(name=self.frozen_vm_pool_name, spec=resource_pool_spec)
        
        print(f"frozen vm pool {self.frozen_vm_pool_name} created {frozen_vm_pool}") 
        return  frozen_vm_pool
        
    def move_vm_2_resource_pool(self, vm, resource_pool):
        relocate_spec = vim.vm.RelocateSpec(pool=resource_pool)
        WaitForTask(vm.Relocate(relocate_spec))
        return
    
    def get_hosts_not_have_frozen_vm(self, frozen_vm):
        # get all hosts
        hosts = cf.pyvmomi_provider.list_pyvmomi_objs([vim.HostSystem])
        print(f"all_hosts= {hosts}")
        
        froze_vm_host = frozen_vm.summary.runtime.host
        print(f"The frozen vm is on host {froze_vm_host}")
        
        for host in hosts:
            if host.name == froze_vm_host.name:
                hosts.remove(host)
                
        print(f"hosts_not_have_frozen_vm(= {hosts}")
        
        return hosts
    
    def clone_vm_to_hosts(self, hosts, source_vm):   
   
        # set relospec
        relospec = vim.vm.RelocateSpec()
        relospec.datastore = source_vm.datastore[0]
        relospec.pool = source_vm.resourcePool
        

        clonespec = vim.vm.CloneSpec()
        clonespec.location = relospec
        clonespec.powerOn = False
        
        i  = 2
        for host in hosts:
            relospec.host = host
            new_frozen_vm_name = self.frozen_vm_prefix_name + "-" + str(i)
            i += 1
            WaitForTask(source_vm.Clone(folder=source_vm.parent, name=new_frozen_vm_name, spec=clonespec))
        return
        
        
if __name__ == "__main__":
    cf = None
    if len(sys.argv) < 2:
        raise RuntimeError(
            f"Unexpected: Usage: python {sys.argv[0]} <CONFIG_FILE_PATH>"
    )
    try:
        cf = CloneFrozenVMService(sys.argv[1])
        
        if cf.frozen_vm_pool_name is None:
            print(f"Skipping clone vm")
            exit
        
        frozen_vm_pool = cf.create_resource_pool_if_not_exists()
        
        first_frozen_vm_name = cf.frozen_vm_prefix_name + "-1"
        first_frozen_vm = cf.pyvmomi_provider.get_pyvmomi_obj([vim.VirtualMachine], first_frozen_vm_name)
        if first_frozen_vm is None:
            raise ValueError(f"Couldn't found the frozen vm {first_frozen_vm_name}")

        cf.move_vm_2_resource_pool(first_frozen_vm, frozen_vm_pool)
        
        hosts = cf.get_hosts_not_have_frozen_vm(first_frozen_vm)
        
        cf.clone_vm_to_hosts(hosts, first_frozen_vm)
        
    except:  # noqa: E722
        traceback.print_exc()
