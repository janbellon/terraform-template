
locals {
    vm_defaults = {
        image ="ubuntu-24.04"
        node  = "pve"
        netbox_cluster = 1
        cores = 2
        memory = 2048
        disk_size = 16
        ip = "dhcp"
        gateway = "192.168.0.1"
        dns_servers = ["192.168.0.100"]
        dns_domain = "vm.network.lan"
        zone = "network.lan"
        netmask = "24"
        netmask6 = "64"
        ip6enabled = false
        network_bridge = "vmbr1"
        storage_volume = "local-fs"
        cloud_user = "root"
        tags = []
        ssh_keys = [
          "ssh-rsa AAAAA...."
        ]
        startup_order = 0
        cpu_type = "x86-64-v2-AES"
        role = 9
        started = true
        pool_id = "Terraform"
    }

    vm_list = yamldecode(file("${path.module}/virtual_machines.yaml")).virtual_machines
    
    vm_merged = [
        for vm in local.vm_list : merge(
            local.vm_defaults,
            vm,
        )
    ]
    
    vm_map  = { for vm in local.vm_merged : vm.name => vm }
}