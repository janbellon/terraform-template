resource "netbox_virtual_machine" "nb_vm" {
    for_each = local.vm_map

    name = "${each.value.hostname}.${each.value.zone}"
    cluster_id = each.value.netbox_cluster
    role_id = each.value.role
    # `role`, `platform`, `comments` etc. may be provider-specific fields
    # Add tags
    tags = each.value.tags


    disk_size_mb = each.value.disk_size * 1024
    memory_mb    = each.value.memory
    vcpus        = each.value.cores
}

resource "netbox_interface" "vm_int" {
    for_each = local.vm_map

    name               = "eth0"
    virtual_machine_id = netbox_virtual_machine.nb_vm[each.key].id
}

resource "netbox_ip_address" "vm_ip" {
    for_each = local.vm_map

    ip_address = format("%s/%s", each.value.ip, each.value.netmask)
    status = "active"
    virtual_machine_interface_id = netbox_interface.vm_int[each.key].id
    role = "vip"
    dns_name = "${each.value.hostname}.${each.value.zone}"
    # Optionally set `status`, `description`, or assign to an interface after creating VM record.
}

resource "netbox_ip_address" "vm_ip6" {
    for_each = {
        for k, v in local.vm_map :
        k => v if v.ip6enabled
    }

    ip_address = format("%s/%s", each.value.ip6, each.value.netmask6)
    status = "active"
    virtual_machine_interface_id = netbox_interface.vm_int[each.key].id
    role = "vip"
    dns_name = "${each.value.hostname}.${each.value.zone}"
    # Optionally set `status`, `description`, or assign to an interface after creating VM record.
}

resource "netbox_primary_ip" "vm_primary_ip" {
  for_each = local.vm_map
  ip_address_id      = netbox_ip_address.vm_ip[each.key].id
  virtual_machine_id = netbox_virtual_machine.nb_vm[each.key].id
}