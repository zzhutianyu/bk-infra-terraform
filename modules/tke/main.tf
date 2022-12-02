resource "tencentcloud_kubernetes_cluster" "this" {
  vpc_id                          = var.vpc_id
  cluster_max_pod_num             = var.cluster_max_pod_num
  cluster_name                    = "${var.name}-k8s"
  cluster_desc                    = "${var.name}-k8s"
  cluster_max_service_num         = var.cluster_max_service_num
  cluster_version                 = var.cluster_version
  cluster_internet                = true
  cluster_internet_security_group = tencentcloud_security_group.cluster.id
  cluster_deploy_type             = "MANAGED_CLUSTER"
  network_type                    = "VPC-CNI"
  eni_subnet_ids                  = var.subnet_container_ids
  service_cidr                    = var.service_cidr
}

resource "tencentcloud_security_group" "cluster" {
  name        = "${var.name}-cluster-sg"
  description = "${var.name}-cluster-sg"
}