
variable "name" {
  type = string
}

variable "vpc_cidr" {
  type = string
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

variable "eips" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
}
