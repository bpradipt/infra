# Nested KVM on Power
Latest Qemu and Kernel have support for nested KVM on Power.

## Terminologies

- Host: Baremetal host running KVM hypervisor.
- L1 guest (or VM): This is the KVM VM spawned on Baremetal host.
- L2 guest (or VM): This is the KVM VM spawned on an existing KVM VM (KVM on KVM). This guest can also be called as nested KVM guest.

## Setup
Ensure you have the latest 4.18+ series kernel on the host and the L1 guest. Fedora 30+, Ubuntu 18.04+ and CentOS8+ should be fine. Additionally you'll also need the latest qemu version (4.1+)
The following instructions have been tested on the following combinations:
- Fedora 31 host : Fedora 31 guest
- Feodra 31 host : Ubuntu 18.04 L1 guest
- Fedora 31 host : CentOS 8.1 L1 guest

You need to run the L1 guest using Qemu with the `cap-nested-hv=true` option.
You can boot the L1 guest using direct Qemu command line or can use the following procedure with libvirt.

1. Assuming the qemu emulator path is `/usr/bin/qemu-system-ppc64`, perform the following steps

- Rename the emulator
   ```sh
   cp /usr/bin/qemu-system-ppc64 /usr/bin/qemu-system-ppc64.bin
   ```

- Copy the contents of the following script as `/usr/bin/qemu-system-ppc64`
   ```sh
   #!/bin/bash

   ARGS="$@"

   # Check if VM name has a specific string for override (eg. kata)
   # if yes
   # then add cap-nested-hv=true to machine option

   #Machine
   MACHINE="pseries-4.1"
   NEWMACHINE="pseries-4.1,cap-nested-hv=true"
   QEMU="/usr/bin/qemu-system-ppc64.bin"
   echo "args: "  ${ARGS}

   #Check if qemu arg name have kata
   echo ${ARGS} | grep -i kata
   if [ $? -eq 0 ]
   then

      #Add nested support
      ARGS_1=$(echo ${ARGS} | sed -e 's/'"${MACHINE}"'/'"${NEWMACHINE}"'/g')

      echo "updated args: "  ${ARGS_1}
      exec ${QEMU} ${ARGS_1}
   else
      echo "args: " ${ARGS}
      exec ${QEMU} ${ARGS}
   fi
   ```

- Make the file executable
   ```sh
   chmod +x /usr/bin/qemu-system-ppc64
   chcon -t qemu_exec_t /usr/bin/qemu-system-ppc64
   ```

2. Create VM (L1 guest) using libvirt and have the string `kata` in the name. For example `kata-centos-8-vm-01` or `kata-fedora-31-vm-00` or `bionic-kata-00` and so on. Example libvirt xmls can be found in the following [directory](./libvirt-xmls)

3. Boot the VM

4. On successful boot, login to the VM and perform the following steps
   ```sh
   modprobe kvm-hv
   ```

Now you can use qemu or libvirt to create KVM VMs on L1 guest
