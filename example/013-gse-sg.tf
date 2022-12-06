
# 安装gse-agent的机器都需要绑定改安全组，用于放通agent与agent之间以及agent与gse之间的网络联通
resource "tencentcloud_security_group" "bk_gse_agent" {
  name        = "${var.name}-bk-gseagent"
  description = "${var.name}-bk-gseagent"
}

resource "tencentcloud_security_group_lite_rule" "bk_gse_agent" {
  security_group_id = tencentcloud_security_group.bk_gse_agent.id
  ingress = [
    "ACCEPT#${tencentcloud_security_group.bk_gse_agent.id}#60020-60030#TCP",
    "ACCEPT#${tencentcloud_security_group.bk_gse_agent.id}#60020-60030#UDP",
    #   "ACCEPT#0.0.0.0/0#443#TCP",
    "ACCEPT#${module.bk.workers_sg.general}#22#TCP",
  ]
  egress = [
    "ACCEPT#0.0.0.0/0#ALL#ALL",
  ]
}