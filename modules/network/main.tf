
locals {
  auto_eip_enable = length(try(var.eips, [])) == 0
}


resource "tencentcloud_vpc" "this" {
  name       = "${var.name}.vpc"
  cidr_block = var.vpc_cidr

  tags = merge({
    "Name" = "${var.name}.vpc"
  }, var.tags)

  lifecycle {
    prevent_destroy = true
  }
}

resource "tencentcloud_subnet" "public" {
  count             = length(var.subnet_public)
  availability_zone = var.subnet_public[count.index].az_id
  name              = "${var.name}-subnet-${var.subnet_public[count.index].name}"
  vpc_id            = tencentcloud_vpc.this.id
  cidr_block        = var.subnet_public[count.index].cidr

  tags = merge({
    "Name" = "${var.name}.vpc"
  }, var.tags)

  lifecycle {
    prevent_destroy = true
  }
  route_table_id = element(tencentcloud_route_table.this.*.id, count.index)
}

# eip
resource "tencentcloud_eip" "this" {
  count = local.auto_eip_enable ? length(var.subnet_public) : 0
  name  = "${var.name}-nat-eip-${count.index}"
  lifecycle {
    prevent_destroy = true
  }
}

locals {
  nat_gateway_eips = local.auto_eip_enable ? tencentcloud_eip.this.*.public_ip : var.eips
}

resource "tencentcloud_nat_gateway" "this" {
  count            = length(var.subnet_public)
  name             = "${var.name}-ngw-${var.subnet_public[count.index].name}"
  vpc_id           = tencentcloud_vpc.this.id
  assigned_eip_set = [element(local.nat_gateway_eips, count.index)]

  tags = merge({
    "Name" = "${var.name}-ngw-${var.subnet_public[count.index].name}"
  }, var.tags)

  lifecycle {
    prevent_destroy = true
  }
}

resource "tencentcloud_route_table" "this" {
  count  = length(var.subnet_public)
  vpc_id = tencentcloud_vpc.this.id
  name   = "${var.name}-internet-route-table-${var.subnet_public[count.index].name}"
  tags = merge({
    "Name" = "${var.name}-internet-route-table-${var.subnet_public[count.index].name}"
  }, var.tags)

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags
    ]
  }
}

resource "tencentcloud_route_table_entry" "this" {
  count                  = length(var.subnet_public)
  route_table_id         = element(tencentcloud_route_table.this.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  next_type              = "NAT"
  next_hub               = element(tencentcloud_nat_gateway.this.*.id, count.index)
  description            = "${var.name}-route-nat-${var.subnet_public[count.index].name}"
}


locals {
  routes = flatten([
    for subnet in var.subnet_public : [
      for route in subnet.routes != null ? subnet.routes : [] : {
        index : index(var.subnet_public, subnet)
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
  description            = "${var.name}-route-${local.routes[count.index].next_type}-${var.subnet_public[local.routes[count.index].index].name}"
}