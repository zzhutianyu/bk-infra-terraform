resource "tencentcloud_as_scaling_group" "workers" {
  for_each             = { for w in var.workers : w.name => w }
  scaling_group_name   = "${var.name}-k8s-worker-${each.value.name}"
  configuration_id     = tencentcloud_as_scaling_config.workers[each.key].id
  max_size             = 1
  min_size             = 0
  desired_capacity     = 0
  vpc_id               = var.vpc_id
  subnet_ids           = each.value.subnet_ids != null ? each.value.subnet_ids : var.subnet_ids
  project_id           = 0
  default_cooldown     = 400
  termination_policies = ["NEWEST_INSTANCE"]
  retry_policy         = "INCREMENTAL_INTERVALS"

  dynamic "forward_balancer_ids" {
    for_each = { for forward_balancer_id in each.value.forward_balancer_ids != null ? each.value.forward_balancer_ids : [] : forward_balancer_id.load_balancer_id => forward_balancer_id }
    content {
      listener_id      = forward_balancer_ids.value.listener_id
      load_balancer_id = forward_balancer_ids.value.load_balancer_id
      rule_id          = forward_balancer_ids.value.rule_id

      dynamic "target_attribute" {
        for_each = { for t in forward_balancer_ids.value.target_attribute != null ? forward_balancer_ids.value.target_attribute : [] : t.port => t }

        content {
          port   = target_attribute.value.port
          weight = target_attribute.value.weight
        }
      }
    }
  }
  load_balancer_ids = each.value.load_balancer_ids


}

resource "tencentcloud_as_scaling_config" "workers" {
  for_each           = { for w in var.workers : w.name => w }
  configuration_name = "${var.name}-launch-configuration-k8s-woker-${each.value.name}"
  image_id           = each.value.image_id != null ? each.value.image_id : var.image_id
  instance_types     = [each.value.instance_type != null ? each.value.instance_type : var.instance_type]
  cam_role_name      = "${var.name}-k8s-node"

  system_disk_type = "CLOUD_PREMIUM"
  system_disk_size = "50"

  data_disk {
    delete_with_instance = true
    disk_type            = each.value.data_disk_type != null ? each.value.data_disk_type : var.data_disk_type
    disk_size            = each.value.data_disk_size != null ? each.value.data_disk_size : var.data_disk_size
  }

  internet_charge_type = "TRAFFIC_POSTPAID_BY_HOUR"

  security_group_ids = [
    tencentcloud_security_group.node.id,
    tencentcloud_security_group.workers[each.key].id
  ]

  public_ip_assigned = false
  key_ids            = var.key_ids

  enhanced_security_service = false
  enhanced_monitor_service  = false
  user_data = base64encode(templatefile("${path.module}/cloudinit/new-node.sh", {
    region     = var.region
    sm_name    = var.join_config_sm_name
    version_id = var.join_node_sm_version_id
    group      = each.value.node_group
  }))

  instance_tags = each.value.tags

  depends_on = [
    tencentcloud_cam_role.node
  ]
}