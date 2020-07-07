# Requirement

How a Kata container can use SRIOV device for DPDK applications.

## Problem

The SRIOV device needs to be made available as a VFIO device for containers to use. When using Kata containers,
the VFIO device will be attached to the Kata VM and the container will see it as a PCI device and not as a VFIO device.
When using runc containers, the container will get a VFIO device and can start using it as-is.

## Solution

Before a Kata container starts, the Kata VM needs to rebind the PCI device to VFIO driver so that the container sees
a VFIO device and start working on it.

The approach taken is to use OCI hook and do the rebinding in the container `prestart` stage.
This will ensure that container sees the VFIO device

## Quick Test

A container image with Kata kernel and initrd having driver rebinding hook is available at `docker.io/bpradipt/kata-initrd`.

Extract the kernel and initrd from the image and use it to spin up a Kata container. A helper script to extract the kernel
and initrd is provided [here](./extract-kata-kernel-initrd.sh)

Ensure the configuration.toml has the following entries under `[hypervisor.qemu]`

```sh
kernel="/usr/share/kata-containers/vmlinuz-vfio"
initrd="/usr/share/kata-containers/initrd-vfio"
machine_type="q35"
```
