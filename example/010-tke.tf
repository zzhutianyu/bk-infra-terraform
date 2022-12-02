
# TKE 插件有问题

# module "tke" {
#   source                  = "../modules/tke"
#   name                    = var.name
#   vpc_id                  = module.vpc.vpc_id
#   subnet_ids              = module.private.private_subnet_ids
#   subnet_container_ids    = module.private_container.private_subnet_ids
#   service_cidr            = "10.3.0.0/24"
#   cluster_max_service_num = 256
#   key_ids                 = []
#   workers = [{
#     name          = "general"
#     instance_type = "S1.SMALL1"
#     node_group    = "general"
#   }]
# }