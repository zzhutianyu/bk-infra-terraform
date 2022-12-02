variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "subnet_container_ids" {
  type = list(string)
}

variable "cluster_version" {
  type    = string
  default = "1.22.5"

}

variable "container_runtime" {
  type = string
  # optional docker containerd
  default = "docker"
}

variable "cluster_max_pod_num" {
  type    = number
  default = 32
}

variable "cluster_max_service_num" {
  type    = number
  default = 32
}

variable "service_cidr" {
  type = string
}

variable "key_ids" {
  type = list(string)
}

variable "workers" {
  type = list(object({
    name          = string
    instance_type = string
    node_group    = string
  }))
}