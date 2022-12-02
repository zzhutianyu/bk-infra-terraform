output "name" {
  value = var.name
}

output "vpc_id" {
  value = tencentcloud_vpc.this.id
}

output "public_subnet_ids" {
  value = tencentcloud_subnet.public.*.id
}

output "nat_gateway_ids" {
  value = tencentcloud_nat_gateway.this.*.id
}

output "public_route_table_ids" {
  value = tencentcloud_route_table.this.*.id
}