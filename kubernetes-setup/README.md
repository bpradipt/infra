# Introduction
This playbook helps to setup a Kubernetes cluster on Fedora 32

## Pre-req
- Ensure cgroupv2 is disabled. Fedora should be booted with `systemd.unified_cgroup_hierarchy=0`
- Ansible installed

## Running
If passwordless SSH is configured then run the following command:
```
ansible-playbook -i inventory main.yaml
```

If passwordless SSH is not configured then
```
ansible-playbook -i inventory main.yaml --ask-pass

```

