
variable "name" {
  type = string
}

variable "k8s_sh_url" {
  type    = string
  default = "https://bkopen-1252002024.file.myqcloud.com/ce7/bcs.sh"
}

variable "region" {
  type = string
}

variable "account_no" {
  type = string
}

variable "main_account_no" {
  type = string
}

variable "join_config_sm_name" {
  type = string
}

variable "join_node_sm_version_id" {
  type    = string
  default = "node"
}

variable "join_control_plane_sm_version_id" {
  type    = string
  default = "master"
}

variable "ingress" {
  type    = list(string)
  default = []
}

variable "node_ingress" {
  type    = list(string)
  default = []
}
variable "node_egress" {
  type    = list(string)
  default = []
}

variable "egress" {
  type    = list(string)
  default = []
}
variable "availability_zone" {
  type = string
}

variable "image_id" {
  type    = string
  default = "img-9axl1k53"
}

variable "instance_type" {
  type    = string
  default = "S5.MEDIUM2"
}

variable "data_disk_type" {
  type    = string
  default = "CLOUD_PREMIUM"
}

variable "allocate_public_ip" {
    type = bool
    default = false
}

variable "internet_max_bandwidth_out" {
    type = number
    default = 2
}

variable "data_disk_size" {
  type    = number
  default = 50
}

variable "vpc_id" {
  type = string
}

variable "key_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "workers" {
  type = list(object({
    name           = string
    node_group     = string
    subnet_ids     = optional(list(string))
    image_id       = optional(string)
    instance_type  = optional(string)
    tags           = optional(map(string))
    data_disk_type = optional(string)
    data_disk_size = optional(number)
    ingress        = optional(list(string))
    egress         = optional(list(string))
    dedicated = optional(bool)
    forward_balancer_ids = optional(list(object({
      listener_id      = string
      load_balancer_id = string
      target_attribute = list(object({
        port   = number
        weight = number
      }))
      rule_id = optional(string)
    })))
    load_balancer_ids = optional(list(string))
  }))
}


variable "security_group_ids" {
    type = list(string)
    default = []
}