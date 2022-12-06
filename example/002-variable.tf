
variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "qcloud" {
  type = object({
    vpc_cidr        = string
    region          = string
    account_no      = string
    main_account_no = string
  })
}

# 中控机配置
variable "ctrl" {
  type = object({
    image_id       = string
    instance_type  = string
    data_disk_type = string
    data_disk_size = number
  })
}
variable "key_ids" {
  type = list(string)
}

variable "az_id" {
  type = list(string)
}

variable "subnet_public" {
  type = list(object({
    name  = string
    cidr  = string
    az_id = string
    routes = optional(list(object({
      destination_cidr_block = string
      next_hub               = string
      next_type              = string
    })))
  }))
}

variable "subnet_private" {
  type = list(object({
    name  = string
    cidr  = string
    az_id = string
    routes = optional(list(object({
      destination_cidr_block = string
      next_hub               = string
      next_type              = string
    })))
  }))
}

variable "subnet_private_container" {
  type = list(object({
    name  = string
    cidr  = string
    az_id = string
    routes = optional(list(object({
      destination_cidr_block = string
      next_hub               = string
      next_type              = string
    })))
  }))
}