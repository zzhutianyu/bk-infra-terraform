resource "tencentcloud_instance" "ctrl" {
  instance_name = "${var.name}-ctrl"

  internet_max_bandwidth_out = 2
  allocate_public_ip         = true

  availability_zone          = var.az_id.0
  vpc_id                     = module.vpc.vpc_id
  subnet_id                  = module.vpc.public_subnet_ids.0

  image_id                   = var.ctrl.image_id
  instance_type              = var.ctrl.instance_type

  system_disk_type           = "CLOUD_PREMIUM"
  system_disk_size           = 50
  key_ids                    = var.key_ids

  cam_role_name = "${var.name}-ctrl"
  orderly_security_groups = [
    tencentcloud_security_group.ctrl.id,
  ]

  data_disks {
    data_disk_type       = var.ctrl.data_disk_type
    data_disk_size       = var.ctrl.data_disk_size
    delete_with_instance = true
    encrypt              = false
  }

  user_data = base64encode(templatefile("./cloudinit/init-ctrl.sh",
    {
        # todo
    }
  ))

}


resource "tencentcloud_security_group" "ctrl" {
  name        = "${var.name}-ctrl"
  description = "${var.name}-ctrl"
}

resource "tencentcloud_security_group_lite_rule" "ctrl" {
  security_group_id = tencentcloud_security_group.ctrl.id
  ingress = [
      "ACCEPT#127.0.0.1/0#ALL#ALL",
  ]
  egress = [
      "ACCEPT#0.0.0.0/0#ALL#ALL",
  ]
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

resource "tencentcloud_cam_policy" "ctrl" {
  name        = "${var.name}-ctrl"
  document    = <<EOF
{
  "version": "2.0",
  "statement": []
}
EOF
  description = "${var.name}-ctrl"
}

resource "tencentcloud_cam_role_policy_attachment" "ctrl" {
  role_id   = tencentcloud_cam_role.ctrl.id
  policy_id = tencentcloud_cam_policy.ctrl.id
}
