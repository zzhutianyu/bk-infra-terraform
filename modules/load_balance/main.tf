

resource "tencentcloud_clb_instance" "this" {
  network_type = var.network_type
  clb_name     = "${var.name}-lb"
  vpc_id       = var.vpc_id
  subnet_id    = "subnet-12rastkr"
  address_ip_version = var.address_ip_version
  security_groups = [tencentcloud_security_group.this.id]
  log_set_id = var.clb_log != null ? tencentcloud_clb_log_set.this[0].id : null
  log_topic_id = var.clb_log != null ? tencentcloud_clb_log_topic.this[0].id : null

  tags = var.tags
}

resource "tencentcloud_clb_listener" "this" {
  clb_id                     = "lb-0lh5au7v"
  listener_name              = "test_listener"
  port                       = 80
  protocol                   = "TCP"
  health_check_switch        = true
  health_check_time_out      = 2
  health_check_interval_time = 5
  health_check_health_num    = 3
  health_check_unhealth_num  = 3
  session_expire_time        = 30
  scheduler                  = "WRR"
  health_check_port          = 200
  health_check_type          = "HTTP"
  health_check_http_code     = 2
  health_check_http_version  = "HTTP/1.0"
  health_check_http_method   = "GET"
}


resource "tencentcloud_clb_log_set" "this" {
  count = var.clb_log != null ? 1: 0
  period = var.clb_log.period
}

resource "tencentcloud_clb_log_topic" "this" {
  count = var.clb_log != null ? 1 : 0
  log_set_id = "${tencentcloud_clb_log_set.this[count.index].id}"
  topic_name = "clb-topic"
}

resource "tencentcloud_security_group" "this" {
  name        = "${var.name}-lb-"
  description = "${var.name}-lb-"
}

resource "tencentcloud_security_group_lite_rule" "this" {
  security_group_id = tencentcloud_security_group.this.id
  ingress = concat([
      "ACCEPT#127.0.0.1/0#ALL#ALL",
  ], var.ingress)
  egress = concat([
      "ACCEPT#0.0.0.0/0#ALL#ALL",
  ], var.egress)
}
