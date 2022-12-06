module "ctrl" {
  source             = "../modules/ctrl"
  name               = var.name
  key_ids            = var.key_ids
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.public_subnet_ids.0
  availability_zone  = var.az_id.0
  allocate_public_ip = true
  security_group_ids = [s]
}