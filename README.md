# Introduction
This ansible playbook sets up libvirt and configures VM for nested KVM

## Running
```sh
ansible-playbook -i inventory/hosts.yaml playbook/main.yaml
```

Currently this is tested only on Fedora 31
