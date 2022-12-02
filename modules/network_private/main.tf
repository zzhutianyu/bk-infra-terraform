resource "tencentcloud_subnet" "this" {
  count             = length(var.subnet_private)
  availability_zone = var.subnet_private[count.index].az_id
  name              = "${var.name}-subnet-${var.subnet_private[count.index].name}"
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_private[count.index].cidr

  tags = merge({
    "Name" = "${var.name}-subnet-${var.subnet_private[count.index].name}"
  }, var.tags)

  lifecycle {
    prevent_destroy = true
  }
  route_table_id = element(tencentcloud_route_table.this.*.id, count.index)
}

resource "tencentcloud_route_table" "this" {
  count  = length(var.subnet_private)
  vpc_id = var.vpc_id
  name   = "${var.name}-internet-route-table-${var.subnet_private[count.index].name}"
  tags = merge({
    "Name" = "${var.name}-internet-route-table-${var.subnet_private[count.index].name}"
  }, var.tags)

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags
    ]
  }
}

locals {
  nat_gateway_enable = try(length(var.nat_gateway_ids), 0) == 0 ? false : true
}

resource "tencentcloud_route_table_entry" "this" {
  count                  = local.nat_gateway_enable ? length(var.subnet_private) : 0
  route_table_id         = element(tencentcloud_route_table.this.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  next_type              = "NAT"
  next_hub               = element(var.nat_gateway_ids, count.index)
  description            = "${var.name}-route-nat-${var.subnet_private[count.index].name}"
}

locals {
  routes = flatten([
    for subnet in var.subnet_private : [
      for route in subnet.routes != null ? subnet.routes : [] : {
        index : index(var.subnet_private, subnet)
        destination_cidr_block : route.destination_cidr_block
        next_hub : route.next_hub
        next_type : route.next_type
      }
    ]
  ])

}

resource "tencentcloud_route_table_entry" "subnet_routes" {
  count                  = length(local.routes)
  route_table_id         = element(tencentcloud_route_table.this.*.id, local.routes[count.index].index)
  destination_cidr_block = local.routes[count.index].destination_cidr_block
  next_type              = local.routes[count.index].next_type
  next_hub               = local.routes[count.index].next_hub
  description            = "${var.name}-route-${local.routes[count.index].next_type}-${var.subnet_private[local.routes[count.index].index].name}"
}