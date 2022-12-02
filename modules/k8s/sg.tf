
resource "tencentcloud_security_group" "control_plane" {
  name        = "${var.name}-control-name"
  description = "${var.name}-control-name"
}

resource "tencentcloud_security_group_lite_rule" "control_plane" {
  security_group_id = tencentcloud_security_group.control_plane.id
  ingress = concat(
    var.ingress
    ,

    [
        "ACCEPT#127.0.0.1/0#ALL#ALL",
    ]
  )
  egress = concat(
    var.egress,

  [


    "ACCEPT#127.0.0.1/0#ALL#ALL",
  ]
  )
}

resource "tencentcloud_security_group" "node" {
  name        = "${var.name}-node"
  description = "${var.name}-node"
}

resource "tencentcloud_security_group_lite_rule" "node" {
  security_group_id = tencentcloud_security_group.node.id
  ingress = [
    "ACCEPT#${tencentcloud_security_group.node.id}#ALL#ALL",
  ]
  egress = [
    "ACCEPT#${tencentcloud_security_group.node.id}#ALL#ALL",
    "ACCEPT#0.0.0.0/0#ALL#ALL",
  ]
}

resource "tencentcloud_security_group" "workers" {
  for_each             = { for w in var.workers : w.name => w }
  name        = "${var.name}-worker-${each.value.name}"
  description = "${var.name}-worker-${each.value.name}"
}

resource "tencentcloud_security_group_lite_rule" "workers" {
  for_each             = { for w in var.workers : w.name => w }
  security_group_id = tencentcloud_security_group.workers[each.key].id
  ingress = each.value.ingress != null ? each.value.ingress : [
    "ACCEPT#127.0.0.1/0#ALL#ALL",
  ]
  egress = each.value.egress != null ? each.value.egress : [
    "ACCEPT#127.0.0.1/0#ALL#ALL",
  ]
}