# 普通k8s集群
module "k8s" {
  source              = "../modules/k8s"
  name                = "${var.name}-k8s"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.private.private_subnet_ids
  availability_zone   = var.az_id.0
  key_ids             = var.key_ids
  join_config_sm_name = "example-k8s"
  k8s_sh_url          = "https://bkopen-1252002024.file.myqcloud.com/ce7/bcs.sh"
  account_no          = var.qcloud.account_no
  main_account_no     = var.qcloud.main_account_no
  region              = var.qcloud.region
  workers = [
    # general节点使用
    {
      name       = "general"
      node_group = "general"
    },
  ]

  ingress = [
    # 只允许中控机访问控制面
    "ACCEPT#${tencentcloud_security_group.ctrl.id}#ALL#ALL"
  ]
  tags = {}
}