# User Guide for building a Frozen VM

When running Ray on vSphere, you must have a frozen VM, which is a VM with Ray and its dependencies already installed. 
The Ray nodes will be instantly cloned from the frozen VM to compose an autoscaling Ray cluster.

This guide is about how to use the scripts to build a Frozen VM on your vSphere environment before running `ray up`.

## Prerequisites

1. A linux machine with Docker installed.
2. The machine should have ssh-keygen installed.
3. The machine should have access to your vCenter Server of the vSphere environment.
4. The machine should have the Internet access.

## Build a Frozen VM


### Step1: Modify Configuration Files

The meaning of each config is well explained in the comments.

```bash
vi scripts/config.hcl
```

### Step2: Build the Frozen VM with one click

```bash
bash create-frozen-vm.sh
```

This step will launch a container with dependency pre-installed, and run packer build inside the container.

One of the step is to upload the Debian 12 ISO file onto the specific datastore configured in config.hcl.
If you have already uploaded the iso file to the datastore, you can skip this step by adding an argument:

```bash
bash create-frozen-vm.sh --skip-uploading-iso
```

Once the script finishes successfully, you will be able to see the Frozen VM on vSphere, and the OVF of the Frozen VM
will be exported to the content library specified in the config file. 

For more detailed guidance, check the [Advanced user guide](Advanced-user-guide.md).
