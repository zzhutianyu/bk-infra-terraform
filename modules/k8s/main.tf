resource "tencentcloud_instance" "k8s_main_master" {
  instance_name = "${var.name}-k8s-main-master"

  internet_max_bandwidth_out = var.allocate_public_ip ? var.internet_max_bandwidth_out : null
  allocate_public_ip         = var.allocate_public_ip
  availability_zone          = var.availability_zone
  vpc_id                     = var.vpc_id
  subnet_id                  = var.subnet_ids.0
  image_id                   = var.image_id
  instance_type              = var.instance_type
  system_disk_type           = "CLOUD_PREMIUM"
  system_disk_size           = 50
  key_ids                    = var.key_ids

  cam_role_name = "${var.name}-k8s-main-master"
  orderly_security_groups = [
    tencentcloud_security_group.control_plane.id,
    tencentcloud_security_group.node.id
  ]

  data_disks {
    data_disk_type       = var.data_disk_type
    data_disk_size       = var.data_disk_size
    delete_with_instance = true
    encrypt              = false
  }

  user_data = base64encode(templatefile("${path.module}/cloudinit/init-master.sh",
    {
      k8s_sh_url                      = var.k8s_sh_url
      region                          = var.region
      sm_name                         = var.join_config_sm_name
      sm_version_id_for_control_plane = var.join_control_plane_sm_version_id
      sm_version_id_for_node          = var.join_node_sm_version_id
    }
  ))

  depends_on = [
    tencentcloud_cam_role.main_master,
    tencentcloud_ssm_secret.sm
  ]

}


resource "tencentcloud_as_scaling_group" "control_plane" {
  scaling_group_name   = "${var.name}-k8s-control-plane"
  configuration_id     = tencentcloud_as_scaling_config.control_plane.id
  max_size             = 1
  min_size             = 0
  desired_capacity     = 0
  vpc_id               = var.vpc_id
  subnet_ids           = var.subnet_ids
  project_id           = 0
  default_cooldown     = 400
  termination_policies = ["NEWEST_INSTANCE"]
  retry_policy         = "INCREMENTAL_INTERVALS"

}

resource "tencentcloud_as_scaling_config" "control_plane" {
  configuration_name = "${var.name}-launch-configuration-k8s-control-plane"
  image_id           = var.image_id
  instance_types     = [var.instance_type]

  system_disk_type = "CLOUD_PREMIUM"
  system_disk_size = "50"

  cam_role_name = "${var.name}-k8s-control-plane"
  security_group_ids = [
    tencentcloud_security_group.control_plane.id,
    tencentcloud_security_group.node.id
  ]

  data_disk {
    disk_type            = var.data_disk_type
    disk_size            = var.data_disk_size
    delete_with_instance = true
  }

  internet_charge_type = "TRAFFIC_POSTPAID_BY_HOUR"
  
  internet_max_bandwidth_out = var.allocate_public_ip ? var.internet_max_bandwidth_out : null
  public_ip_assigned         = var.allocate_public_ip
  key_ids              = var.key_ids

  enhanced_security_service = false
  enhanced_monitor_service  = false
  user_data = base64encode(templatefile("${path.module}/cloudinit/new-control-plane.sh", {
    region     = var.region
    sm_name    = var.join_config_sm_name
    version_id = var.join_control_plane_sm_version_id
  }))

  instance_tags = var.tags
  depends_on = [
    tencentcloud_cam_role.control_plane
  ]
}

resource "tencentcloud_ssm_secret" "sm" {
  secret_name             = var.join_config_sm_name
  description             = var.join_config_sm_name
  recovery_window_in_days = 0
  is_enabled              = true
}