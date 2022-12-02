
module "vpc" {
  source        = "../modules/network"
  name          = var.name
  vpc_cidr      = var.qcloud.vpc_cidr
  subnet_public = var.subnet_public
  tags          = var.tags
}


module "private" {
  source          = "../modules/network_private"
  name            = "${var.name}-private"
  vpc_id          = module.vpc.vpc_id
  subnet_private  = var.subnet_private
  nat_gateway_ids = module.vpc.nat_gateway_ids
  tags            = var.tags
}

# for tke CNI
# module "private_container" {
#   source          = "../modules/network_private"
#   name            = "${var.name}-private-container"
#   vpc_id          = module.vpc.vpc_id
#   subnet_private  = var.subnet_private_container
#   nat_gateway_ids = module.vpc.nat_gateway_ids
#   tags            = var.tags
# }