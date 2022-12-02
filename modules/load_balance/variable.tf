
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


variable "subnet_ids" {
    type = list(string)
    default = []
}