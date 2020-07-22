# Introduction
This playbook helps to setup a Kubernetes cluster on Fedora 32

## Pre-req
- Ansible installed
- Ensure cgroupv2 is disabled. Fedora should be booted with `systemd.unified_cgroup_hierarchy=0`

```
$ sudo dnf install -y grubby && \
  sudo grubby \
  --update-kernel=ALL \
  --args="systemd.unified_cgroup_hierarchy=0"
$ sudo reboot
```

If cgroupsv1 is enabled, it should look this:

```
$ ls /sys/fs/cgroup/
blkio  cpu  cpuacct  cpu,cpuacct  cpuset  devices  freezer  hugetlb  memory  net_cls  net_cls,net_prio  net_prio  perf_event  pids  systemd  unified
```

## Running

If passwordless SSH is not configured then add `--ask-pass --ask-become-pass` to the ansible-playbook comand line

To setup a master node:

```
ansible-playbook -i inventory main.yaml

```

To setup a worker node:

```
ansible-playbook -i inventory main.yaml --skip-tags "kubeadm_init"
```
