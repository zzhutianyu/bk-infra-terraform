variable "name" {
  type = string
}

variable "vpc_id" {
  type = string

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

variable "nat_gateway_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
}
