# Introduction
This ansible playbook sets up libvirt and configures VM for nested KVM

## Running
This will setup the hypervisor host and also create VM
```sh
ansible-playbook -i inventory/hosts.yaml playbook/main.yaml
```

Currently this is tested only on Fedora 31 host. By default a fedora-32 and ubuntu-20.04 VM gets provisioned. The default fedora VM user is `fedora` and password is `passw0rd`. Similarly the default ubuntu VM user is `ubuntu` and password is `passw0rd`

## Creating VM
If you already have the hypervisor host setup, then run the following to just create a VM. 
Ensure you modify the [variables](https://github.com/bpradipt/infra/blob/master/kata-nested-vm-host/ansible/inventory/group_vars/hypervisors/00_shared_vars) accordingly
```sh
ansible-playbook -i inventory/hosts.yaml playbook/vm.yaml
```

Alternatively update `examples/vm_vars.yaml` and use it
```sh
cp examples/vm_vars.yaml vm_vars.yaml
ansible-playbook -i inventory/hosts.yaml -e @vm_vars.yaml playbook/vm.yaml
```


## Deleting VM
```sh
ansible-playbook -i inventory/hosts.yaml playbook/delete_vm.yaml
```

Alternative if using custom vars file then run this
```sh
ansible-playbook -i inventory/hosts.yaml -e @vm_vars.yaml playbook/delete_vm.yaml
```
