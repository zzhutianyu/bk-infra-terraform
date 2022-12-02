resource "tencentcloud_kubernetes_node_pool" "workers" {
  for_each          = { for w in var.workers : w.name => w }
  name              = "${var.name}-worker-${each.value.name}"
  cluster_id        = tencentcloud_kubernetes_cluster.this.id
  max_size          = 1
  min_size          = 0
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  retry_policy      = "INCREMENTAL_INTERVALS"
  desired_capacity  = 0
  enable_auto_scale = false

  multi_zone_subnet_policy = "EQUALITY"


  auto_scaling_config {
    instance_type      = each.value.instance_type
    system_disk_type   = "CLOUD_PREMIUM"
    system_disk_size   = "50"
    security_group_ids = [tencentcloud_security_group.workers[each.key].id]
    key_ids            = var.key_ids

    data_disk {
      disk_type = "CLOUD_PREMIUM"
      disk_size = 50
    }

    internet_charge_type      = "TRAFFIC_POSTPAID_BY_HOUR"
    enhanced_security_service = false
    enhanced_monitor_service  = false

  }

  labels = {
    "node_group" = "${each.value.node_group}"
  }

  node_config {
    extra_args = [
      "root-dir=/var/lib/kubelet"
    ]
  }
  lifecycle {
    ignore_changes = [
      desired_capacity,
      max_size,
      min_size
    ]
  }
}

resource "tencentcloud_security_group" "workers" {
  for_each    = { for w in var.workers : w.name => w }
  name        = "${var.name}-worker-sg-${each.value.name}"
  description = "${var.name}-worker-sg-${each.value.name}"
}