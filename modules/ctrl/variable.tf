variable "name" {
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

variable "data_disk_size" {
  type    = number
  default = 50
}

variable "availability_zone" {
  type = string
}

variable "allocate_public_ip" {
    type = bool
    default = false
}

variable "internet_max_bandwidth_out" {
    type = number
    default = 2
}

variable "key_ids" {
    type = list(string)
}

variable "subnet_id" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "ingress" {
    type = list(string)
    default = []
}

variable "egress" {
    type = list(string)
    default = []
}