On Fedora 32 you can install Kata from the default distro repo.

# Instructions

## Install kata
```
dnf install -y kata-runtime
```

## Modify Kata Configuration File
The default configuration file is - `/usr/share/kata-containers/defaults/configuration.toml`

It’s preferred to copy the default config file from the above location to `/etc/kata-containers/configuration.toml` since that’s the first location which will be looked at and will avoid overwriting if you are rebuilding and installing

```
cp /usr/share/kata-containers/defaults/configuration.toml /etc/kata-containers/configuration.toml
```

Ensure the `configuration.toml` have these settings 

```
[hypervisor.qemu]
path = “/usr/bin/qemu-kvm”
kernel = “/var/cache/kata-containers/vmlinuz.container”
initrd = “/var/cache/kata-containers/kata-containers-initrd.img”
machine_type = “pseries”


shared_fs = “virtio-fs”
virtio_fs_cache_size=0
use_vsock = true
```

## Create Qemu runtime script
Create file `/usr/bin/qemu-kvm`
```
cat <<EOF >> /usr/bin/qemu-kvm
#!/bin/bash
exec qemu-system-ppc64 -object memory-backend-file,id=mem,size=2048M,mem-path=/dev/shm,share=on -numa node,memdev=mem "\$@"
EOF

chmod +x /usr/bin/qemu-kvm
```
N.B - This is not needed if building Kata from upstream since the required fixes for virtio-fs for ppc64le are already there
## Load Virtiofs module
```
modprobe virtiofs
echo virtiofs > /etc/modules-load.d/virtiofs.conf
```

## Create Initrd Image

Reboot the node or run `/usr/libexec/kata-containers/osbuilder/fedora-kata-osbuilder.sh `
This will create the following two files
`/var/cache/kata-containers/vmlinuz.container`
`/var/cache/kata-containers/kata-containers-initrd.img`

## Verify Kata
```
podman run -it --runtime=kata-runtime fedora:latest sh
```
