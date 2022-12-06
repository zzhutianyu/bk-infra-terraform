
variable "name" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "network_type" {
    type = string
    # optional OPEN INTERNAL
    default = "OPEN"
}

variable "clb_log" {
    type = optional(object({
        period = number
    }))
}

variable "address_ip_version" {
    type = string
    default = "ipv4"
}

variable "subnet_ids" {
    type = list(string)
    default = []
}

variable "ingress" {
    type = list(string)
    default = []
}

variable "egress" {
    type = list(string)
    default = []
}

variable "tags" {
    type = map(string)
    default = {}
}