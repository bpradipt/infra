#!/bin/bash
# Extract initrd and kernel from container image and copy to /usr/share/kata-containers

CONTAINER_IMAGE=docker.io/bpradipt/kata-initrd
CONTAINER_RUNTIME=podman

echo "Copy initrd-vfio.img to /usr/share/kata-containers"
${CONTAINER_RUNTIME} run -v /usr/share/kata-containers:/data ${CONTAINER_IMAGE} cp /kata-containers-initrd.img /data/initrd-vfio.img

echo "Copy vmlinuz-vfio to /usr/share/kata-containers"
${CONTAINER_RUNTIME} run -v /usr/share/kata-containers:/data ${CONTAINER_IMAGE} cp /vmlinuz.container /data/vmlinuz-vfio
