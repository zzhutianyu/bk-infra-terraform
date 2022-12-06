resource "tencentcloud_instance" "ctrl" {
  instance_name = "${var.name}-ctrl"

  internet_max_bandwidth_out = var.allocate_public_ip ? var.internet_max_bandwidth_out : null
  allocate_public_ip         = var.allocate_public_ip
  availability_zone          = var.availability_zone
  vpc_id                     = var.vpc_id
  subnet_id                  = var.subnet_id

  image_id                   = var.image_id
  instance_type              = var.instance_type

  system_disk_type           = "CLOUD_PREMIUM"
  system_disk_size           = 50
  key_ids                    = var.key_ids

  cam_role_name = "${var.name}-ctrl"
  orderly_security_groups = concat([
    tencentcloud_security_group.ctrl.id,
  ], var.security_group_ids)

  data_disks {
    data_disk_type       = var.data_disk_type
    data_disk_size       = var.data_disk_size
    delete_with_instance = true
    encrypt              = false
  }

  user_data = base64encode(file("./cloudinit/init-ctrl.sh"))

}


resource "tencentcloud_security_group" "ctrl" {
  name        = "${var.name}-ctrl"
  description = "${var.name}-ctrl"
}

resource "tencentcloud_security_group_lite_rule" "ctrl" {
  security_group_id = tencentcloud_security_group.ctrl.id
  ingress = concat([
      "ACCEPT#127.0.0.1/0#ALL#ALL",
  ], var.ingress)
  egress = concat([
      "ACCEPT#0.0.0.0/0#ALL#ALL",
  ], var.egress)
}


# cvm role
resource "tencentcloud_cam_role" "ctrl" {
  name          = "${var.name}-ctrl"
  document      = <<EOF
{
    "version": "2.0",
    "statement": [
        {
            "action": ["name/sts:AssumeRole", "name/sts:AssumeRoleWithWebIdentity"],
            "effect": "allow",
            "principal": {
                "service": [
                    "cvm.qcloud.com"
                ]
            }
        }
    ]
}
EOF
  description   = "${var.name}-ctrl"
  console_login = false
}

# TODO 
# resource "tencentcloud_cam_policy" "ctrl" {
#   name        = "${var.name}-ctrl"
#   document    = <<EOF
# {
#   "version": "2.0",
#   "statement": []
# }
# EOF
#   description = "${var.name}-ctrl"
# }

# resource "tencentcloud_cam_role_policy_attachment" "ctrl" {
#   role_id   = tencentcloud_cam_role.ctrl.id
#   policy_id = tencentcloud_cam_policy.ctrl.id
# }
