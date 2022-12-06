module "bk" {
  source              = "../modules/k8s"
  name                = "${var.name}-bk"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.private.private_subnet_ids
  availability_zone   = var.az_id.0
  key_ids             = var.key_ids
  join_config_sm_name = "${var.name}-bk-k8s"
  k8s_sh_url          = "https://bkopen-1252002024.file.myqcloud.com/ce7/bcs.sh"
  account_no          = var.qcloud.account_no
  main_account_no     = var.qcloud.main_account_no
  region              = var.qcloud.region
  security_group_ids  = [tencentcloud_security_group.bk_gse_agent.id]
  instance_type       = "S5.LARGE8"
  workers = [
    {
      name           = "general"
      node_group     = "general"
      instance_type  = "S5.2XLARGE16"
      data_disk_size = 100
    },
    {
      #   nodeSelector:
      # .   group: ingress
      # . tolerations:
      # .   - key: "group"
      #       operator: "Exists"
      #       effect: "NoSchedule"
      name          = "ingress"
      node_group    = "ingress"
      subnet_ids    = module.vpc.public_subnet_ids
      dedicated     = true
      instance_type = "S5.MEDIUM2"
      forward_balancer_ids = [{
        listener_id      = tencentcloud_clb_listener.bk_ingress_http.listener_id,
        load_balancer_id = tencentcloud_clb_instance.bk_ingress.id,
        rule_id          = tencentcloud_clb_listener_rule.bk_ingress_http.rule_id
        target_attribute = [{
          port   = 80
          weight = 100
        }]
      }]
      ingress = [
        "ACCEPT#0.0.0.0/0#80#TCP",
        "ACCEPT#0.0.0.0/0#443#TCP",
      ]
    },
    {
      #   nodeSelector:
      # .   group: gse
      # . tolerations:
      # .   - key: "group"
      #       operator: "Exists"
      #       effect: "NoSchedule"
      name          = "gse"
      node_group    = "gse"
      subnet_ids    = module.vpc.public_subnet_ids,
      instance_type = "S5.MEDIUM2"
      dedicated     = true
      #   forward_balancer_ids = concat([
      #     for k, v in local.gse_port_map :
      #     {
      #       listener_id      = tencentcloud_clb_listener.bk_gse_ext[k].listener_id,
      #       load_balancer_id = tencentcloud_clb_instance.bk_gse_ext.id,
      #       target_attribute = [{
      #         port   = v.port
      #         weight = 100
      #       }]
      #     }
      #     ], [])
      ingress = [
        for k, v in local.gse_port_map :
        "ACCEPT#${tencentcloud_security_group.bk_gse_agent.id}#${v.port}#${v.protocol}"
      ]
    },
    {
      # 单独配置zk节点，以绑定内部clb
      name          = "zk"
      node_group    = "zk"
      subnet_ids    = module.private.private_subnet_ids,
      instance_type = "S5.MEDIUM2"
      dedicated     = true
      forward_balancer_ids = [
        for k, v in local.zk_port_map :
        {
          listener_id      = tencentcloud_clb_listener.bk_zk[k].listener_id,
          load_balancer_id = tencentcloud_clb_instance.bk_zk.id,
          target_attribute = [{
            port   = v.node_port
            weight = 100
          }]
        }
      ]
      ingress = []
    }
  ]

  ingress = [
    "ACCEPT#${module.ctrl.sg_id}#ALL#ALL"
  ]
  node_ingress = [
    "ACCEPT#${module.ctrl.sg_id}#ALL#ALL"
  ]
  tags = {}
}

resource "tencentcloud_clb_instance" "bk_ingress" {
  network_type    = "OPEN"
  clb_name        = "${var.name}-bk-ingress"
  vpc_id          = module.vpc.vpc_id
  security_groups = [tencentcloud_security_group.bk_ingress_lb.id]
  tags            = var.tags
}

resource "tencentcloud_clb_listener" "bk_ingress_http" {
  clb_id        = tencentcloud_clb_instance.bk_ingress.id
  listener_name = "${var.name}-bk-ingress-listener"
  port          = 80
  protocol      = "HTTP"
}

resource "tencentcloud_clb_listener_rule" "bk_ingress_http" {
  listener_id              = tencentcloud_clb_listener.bk_ingress_http.listener_id
  clb_id                   = tencentcloud_clb_instance.bk_ingress.id
  domain                   = "*.bk.bktencent.com"
  url                      = "/"
  health_check_http_domain = "bk.bktencent.com"
}

# resource "tencentcloud_clb_listener" "bk_ingress_https" {
#   clb_id        = tencentcloud_clb_instance.bk_ingress.id
#   listener_name = "${var.name}-bk-ingress-listener"
#   port          = 443
#   protocol      = "HTTPS"
# }

resource "tencentcloud_security_group" "bk_ingress_lb" {
  name        = "${var.name}-bk-ingress-lb"
  description = "${var.name}-bk-ingress-lb"
}

resource "tencentcloud_security_group_lite_rule" "bk_ingress_lb" {
  security_group_id = tencentcloud_security_group.bk_ingress_lb.id
  ingress = [
    "ACCEPT#0.0.0.0/0#80#TCP",
    "ACCEPT#0.0.0.0/0#443#TCP",
  ]
  egress = [
    "ACCEPT#0.0.0.0/0#ALL#ALL",
  ]
}

locals {
  gse_port_map = {
    "tcp_48533" = {
      port     = 48533
      protocol = "TCP"
    }
    "tcp_58625" = {
      port     = 58625
      protocol = "TCP"
    }
    "tcp_59173" = {
      port     = 59173
      protocol = "TCP"
    }

    "tcp_10020" = {
      port     = 10020
      protocol = "TCP"
    }
    "udp_10020" = {
      port     = 10020
      protocol = "UDP"
    }
    "udp_10030" = {
      port     = 10030
      protocol = "UDP"
    }
    "tcp_58930" = {
      port     = 58930
      protocol = "TCP"
    }
  }
}


resource "tencentcloud_clb_instance" "bk_gse_ext" {
  network_type    = "OPEN"
  clb_name        = "${var.name}-bk-gse-ext"
  vpc_id          = module.vpc.vpc_id
  security_groups = [tencentcloud_security_group.bk_gse_ext_lb.id]
  tags            = var.tags
}

resource "tencentcloud_clb_listener" "bk_gse_ext" {
  for_each      = local.gse_port_map
  clb_id        = tencentcloud_clb_instance.bk_gse_ext.id
  listener_name = "${var.name}-bk-gse-ext-listener-${each.value.port}-${each.value.protocol}"
  port          = each.value.port
  protocol      = each.value.protocol
}

# resource "tencentcloud_clb_listener" "bk_ingress_https" {
#   clb_id        = tencentcloud_clb_instance.bk_ingress.id
#   listener_name = "${var.name}-bk-ingress-listener"
#   port          = 443
#   protocol      = "HTTPS"
# }

resource "tencentcloud_security_group" "bk_gse_ext_lb" {
  name        = "${var.name}-bk-gse-ext-lb"
  description = "${var.name}-bk-gse-ext-lb"
}

resource "tencentcloud_security_group_lite_rule" "bk_gse_ext_lb" {
  security_group_id = tencentcloud_security_group.bk_gse_ext_lb.id
  ingress = [
    for k, v in local.gse_port_map :
    "ACCEPT#0.0.0.0/0#${v.port}#${v.protocol}"
  ]
  egress = [
    "ACCEPT#0.0.0.0/0#ALL#ALL",
  ]
}

locals {
  zk_port_map = {
    "tcp_2181" = {
      port      = 2181
      protocol  = "TCP"
      node_port = 32181
    }
    "tcp_2888" = {
      port      = 2888
      protocol  = "TCP"
      node_port = 32046
    }
    "tcp_3888" = {
      port      = 3888
      protocol  = "TCP"
      node_port = 31979
    }
  }
}

resource "tencentcloud_clb_instance" "bk_zk" {
  network_type    = "INTERNAL"
  clb_name        = "${var.name}-bk-zk"
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.private.private_subnet_ids.0
  security_groups = [tencentcloud_security_group.bk_zk.id]
  tags            = var.tags
}

resource "tencentcloud_clb_listener" "bk_zk" {
  for_each      = local.zk_port_map
  clb_id        = tencentcloud_clb_instance.bk_zk.id
  listener_name = "${var.name}-bk-zk-listener-${each.value.port}-${each.value.protocol}"
  port          = each.value.port
  protocol      = each.value.protocol
}

resource "tencentcloud_security_group" "bk_zk" {
  name        = "${var.name}-bk-zk"
  description = "${var.name}-bk-zk"
}

resource "tencentcloud_security_group_lite_rule" "bk_zk" {
  security_group_id = tencentcloud_security_group.bk_zk.id
  ingress = [
    for k, v in local.zk_port_map :
    "ACCEPT#${tencentcloud_security_group.bk_gse_agent.id}#${v.port}#${v.protocol}"
  ]
  egress = [
    "ACCEPT#0.0.0.0/0#ALL#ALL",
  ]
}