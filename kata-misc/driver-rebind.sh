#!/bin/bash
# Kata guest OCI hook to rebind driver to vfio-pci for supported devices
# This will run as during `prestart` phase of container lifecycle
# Author: pradipta.banerjee@redhat.com
set -e
# Trap exit codes to return success for container startup to continue
trap "{ echo 'Stopping prestart hook' ; exit 0; }" EXIT

# Redirect all outputs to a file
exec &> /tmp/prestart-hook.txt

# Supported vendor:device list
# List taken from https://docs.openshift.com/container-platform/4.2/networking/multiple_networks/configuring-sr-iov.html#supported-devices_configuring-sr-iov
# 8086:1521 is for test infra
supported_devices=("8086:1521" "8086:1520" "8086:158b" "15b3:1015" "15b3:1017")

#Load the modules.
#This is not needed if configuration.toml has the following entry kernel_modules=["vfio", "vfio-pci"]
modprobe vfio 2>/dev/null
modprobe vfio-pci 2>/dev/null

echo "Starting prestart hook"


if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root"
    exit 1
fi

for VD in ${supported_devices[@]}; do
    #Handle multiple devices
    #01:00.0 0200: 8086:1521 (rev 01)
    #01:00.1 0200: 8086:1521 (rev 01)
   
    #Should /proc/bus/pci/devices be used directly ?
    BDF_LIST+=($(lspci -n | grep ${VD} | cut -d " " -f1 | tr " " "\n"))
done

echo "BDF List ${BDF_LIST[@]}"

for BDF in ${BDF_LIST[@]}; do
    #FIXME: Add the PCI domain which is hardcoded to 0000. This will not work with non-Intel architecture like Power
    
    BDF="0000:${BDF}"

    DEVICE_DIR="/sys/bus/pci/devices/$BDF"
    if [ ! -L $DEVICE_DIR ]; then
        echo "No such PCI device $BDF"
        continue
    fi

    VENDOR=$(cat "$DEVICE_DIR/vendor")
    DEVICE=$(cat "$DEVICE_DIR/device")

    VFIO_DIR=/sys/bus/pci/drivers/vfio-pci

    #Inside Kata-VM the driver might not be bounded. So check if the path exists
    if [ -e "$DEVICE_DIR/driver" ]; then
        DRIVER=$(basename $(readlink $DEVICE_DIR/driver))
        if [ $DRIVER == vfio-pci ]; then
            echo "Device $BDF already bound to vfio"
            continue
        else
            echo "Unbinding $BDF from $DRIVER"
            echo "$BDF" > "$DEVICE_DIR/driver/unbind"
            echo "Unbound $BDF from current driver"
        fi
    fi

    echo "Binding $BDF to VFIO driver"
    echo $VENDOR $DEVICE > $VFIO_DIR/new_id
    echo "Bound $BDF to vfio driver"

    if [ $(basename $(readlink $DEVICE_DIR/driver)) != vfio-pci ]; then
        echo "Didn't bind $BDF to VFIO driver"
    fi
done
