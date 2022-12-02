output "workers_sg" {
  value = {
    for w in var.workers : w.name => tencentcloud_security_group.workers[w.name].id
  }
}

output "node_sg_id" {
  value = tencentcloud_security_group.node.id
}

output "control_plane_sg_id" {
  value = tencentcloud_as_scaling_config.control_plane.id
}