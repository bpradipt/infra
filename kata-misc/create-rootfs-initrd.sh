#!/bin/bash
set -o pipefail

#Create Fedora rootfs based initrd

#Ensure osbuilder is already downloaded
go get github.com/kata-containers/osbuilder

#Change these values according to your setup
####
export HOME=/home/fedora
export kernel_mod_dir=${HOME}/kernel_modules/5.4.32
export KERNEL_VERSION=5.4.32
export HOOKS=${HOME}/hooks
####

export ROOTFS_DIR=${GOPATH}/src/github.com/kata-containers/osbuilder/rootfs-builder/rootfs
export extra_pkgs="bash pciutils git wget kmod curl"
export os_version=32

# sudo rm -rf ${ROOTFS_DIR}
cd $GOPATH/src/github.com/kata-containers/osbuilder/rootfs-builder
script -fec 'sudo -E GOPATH=$GOPATH USE_PODMAN=true AGENT_INIT=yes SECCOMP=no KERNEL_MODULES_DIR=${kernel_mod_dir}  EXTRA_PKGS="${extra_pkgs}" OS_VERSION=${os_version} ./rootfs.sh fedora'
sudo install -o root -g root -m 0550 -T ../../agent/kata-agent ${ROOTFS_DIR}/sbin/init

#Run depmod
depmod -b ${ROOTFS_DIR}  $KERNEL_VERSION

#Copy hook
sudo -E mkdir -p ${ROOTFS_DIR}/usr/lib/share/oci/hooks
sudo -E cp -r ${HOOKS}/* ${ROOTFS_DIR}/usr/lib/share/oci/hooks

#Create initrd
echo "Creating initrd"
mkdir -p ${HOME}/kata-initrd
cd $GOPATH/src/github.com/kata-containers/osbuilder/initrd-builder
script -fec 'sudo -E AGENT_INIT=yes USE_PODMAN=true ./initrd_builder.sh ${ROOTFS_DIR}'
cp kata-containers-initrd.img ${HOME}/kata-initrd
commit=$(git log --format=%h -1 HEAD)
date=$(date +%Y-%m-%d-%T.%N%z)
image="kata-containers-initrd-${date}-${commit}"
sudo install -o root -g root -m 0640 -D kata-containers-initrd.img "/usr/share/kata-containers/${image}"
(cd /usr/share/kata-containers && sudo ln -sf "$image" kata-containers-initrd.img)
