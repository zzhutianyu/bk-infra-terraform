output "name" {
  value = var.name
}

output "vpc_id" {
  value = var.vpc_id
}

output "net_gateway_ids" {
  value = var.nat_gateway_ids
}

output "private_subnet_ids" {
  value = tencentcloud_subnet.this.*.id
}

output "private_route_table_ids" {
  value = tencentcloud_route_table.this.*.id
}
