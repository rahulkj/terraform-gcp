data "google_compute_subnetwork" "pas-subnetwork" {
  name   = "${var.env_name}-pas-subnet"
  project = "${var.project}"
  region = "${var.region}"
}

resource "google_compute_address" "lb" {
  name = "${var.env_name}-${var.name}-address"

  project = "${var.project}"

  address_type = "INTERNAL"
  address = "${var.lb_address}"

  subnetwork = "${var.env_name}-pas-subnet"

  count = "${var.count}"
}

resource "google_compute_forwarding_rule" "lb" {
  name        = "${var.env_name}-${var.name}-lb-${count.index}"

  project = "${var.project}"
  # network = "${var.network}"
  subnetwork = "${data.google_compute_subnetwork.pas-subnetwork.self_link}"

  # ip_address  = "${google_compute_address.lb.address}"
  ip_address  = "${var.lb_address}"
  target      = "${google_compute_target_pool.lb.self_link}"
  port_range  = "${element(var.forwarding_rule_ports, count.index)}"
  ip_protocol = "TCP"

  count = "${var.count > 0 ? length(var.forwarding_rule_ports) : 0}"
}

resource "google_compute_target_pool" "lb" {
  name = "${var.lb_name}"
  project = "${var.project}"
  health_checks = ["${google_compute_http_health_check.lb.*.name}"]

  count = "${var.count}"
}
