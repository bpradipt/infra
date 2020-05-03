# Introduction
This ansible playbook sets up libvirt and configures VM for nested KVM

## Running
```sh
ansible-playbook -i inventory/hosts.yaml playbook/main.yaml
```

Currently this is tested only on Fedora 31 host. By default a fedora-31 and ubuntu-20.04 VM gets provisioned. The default fedora VM user is `fedora` and password is `passw0rd`. Similarly the default ubuntu VM user is `ubuntu` and password is `passw0rd`

## Deleting VM
```sh
ansible-playbook -i inventory/hosts.yaml playbook/delete_vm.yaml
```
