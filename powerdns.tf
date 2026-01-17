resource "powerdns_record" "vm_domain_a" {
    for_each = local.vm_map
    zone    = "${each.value.zone}."
    name    = "${each.value.hostname}.${each.value.zone}."
    type    = "A"
    ttl     = 300
    records = ["${each.value.ip}"]
}

resource "powerdns_zone" "network-lan" {
  name        = "network.lan."
  kind        = "Native"
  nameservers = ["192.168.0.100."]
}