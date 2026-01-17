resource "proxmox_virtual_environment_vm" "vm" {
    for_each = local.vm_map

    name        = "tf-${each.value.hostname}.${each.value.zone}"
    vm_id       = each.value.vmid
    node_name   = each.value.node
    started     = each.value.started

    tags        = each.value.tags

    cpu {
        cores = each.value.cores
        type = each.value.cpu_type
    }

    memory {
        dedicated = each.value.memory
        floating = each.value.memory
    }

    disk {
        datastore_id = each.value.storage_volume
        file_id = "ISO:iso/${each.value.image}.img"
        size = each.value.disk_size
        interface = "scsi0"
    }

    initialization {
        datastore_id = each.value.storage_volume
        interface = "ide2"

        dns {
            domain = each.value.dns_domain
            servers = each.value.dns_servers
        }

        ip_config {
            ipv4 {
                address = "${each.value.ip}/${each.value.netmask}"
                gateway = each.value.gateway
            }
            dynamic "ipv6" {
                for_each = each.value.ip6enabled ? [1] : []
                content {
                    address = "${each.value.ip6}/${each.value.netmask6}"
                    gateway = each.value.gateway6
                }
            }
        }

        user_account {
            keys = each.value.ssh_keys
            username = each.value.cloud_user
        }
    }

    network_device {
        bridge = each.value.network_bridge
        model = "virtio"
    }

    operating_system {
        type = "l26"
    }

    keyboard_layout = "fr"

    startup {
        order = each.value.startup_order
    }
}

resource "proxmox_virtual_environment_pool_membership" "vm_membership" {
    for_each = local.vm_map
    pool_id  = each.value.pool_id
    vm_id    = proxmox_virtual_environment_vm.vm[each.key].id
}