
resource "tencentcloud_cam_role" "main_master" {
  name          = "${var.name}-k8s-main-master"
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
  description   = "${var.name}-k8s-main-master"
  console_login = false
}

resource "tencentcloud_cam_policy" "main_master" {
  name        = "${var.name}-k8s-main-master-policy"
  document    = <<EOF
{
  "version": "2.0",
  "statement": [
    {
    "effect": "allow",
    "action": [
        "ssm:PutSecretValue",
        "ssm:UpdateSecret"
    ],
    "resource": [
        "qcs::ssm:${var.region}:${var.main_account_no}:secret/creatorUin/${var.account_no}/${var.join_config_sm_name}"
    ]
    }
  ]
}
EOF
  description = "${var.name}-k8s-main-master-policy"
}


resource "tencentcloud_cam_role" "control_plane" {
  name          = "${var.name}-k8s-control-plane"
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
  description   = "${var.name}-k8s-control-plane"
  console_login = false
}

resource "tencentcloud_cam_policy" "control_plane" {
  name        = "${var.name}-k8s-control-plane-policy"
  document    = <<EOF
{
  "version": "2.0",
  "statement": [
    {
    "effect": "allow",
    "action": [
        "ssm:GetSecretValue"
    ],
    "resource": [
        "qcs::ssm:${var.region}:${var.main_account_no}:secret/creatorUin/${var.account_no}/${var.join_config_sm_name}"
    ]
    }
  ]
}
EOF
  description = "${var.name}-k8s-main-control-plane"
}

resource "tencentcloud_cam_role_policy_attachment" "control_plane" {
  role_id   = tencentcloud_cam_role.control_plane.id
  policy_id = tencentcloud_cam_policy.control_plane.id
}


resource "tencentcloud_cam_role_policy_attachment" "main_master" {
  role_id   = tencentcloud_cam_role.main_master.id
  policy_id = tencentcloud_cam_policy.main_master.id
}

resource "tencentcloud_cam_role" "node" {
  name          = "${var.name}-k8s-node"
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
  description   = "${var.name}-k8s-node"
  console_login = false
}

resource "tencentcloud_cam_policy" "node" {
  name        = "${var.name}-k8s-node-policy"
  document    = <<EOF
{
  "version": "2.0",
  "statement": [
    {
    "effect": "allow",
    "action": [
        "ssm:GetSecretValue"
    ],
    "resource": [
        "qcs::ssm:${var.region}:${var.main_account_no}:secret/creatorUin/${var.account_no}/${var.join_config_sm_name}"
    ]
    }
  ]
}
EOF
  description = "${var.name}-k8s-node-policy"
}

resource "tencentcloud_cam_role_policy_attachment" "node" {
  role_id   = tencentcloud_cam_role.node.id
  policy_id = tencentcloud_cam_policy.node.id
}