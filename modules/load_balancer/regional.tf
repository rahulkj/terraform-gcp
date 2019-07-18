resource "google_compute_address" "lb" {
  name = "${var.env_name}-${var.name}-address"

  project = "${var.project}"
  subnetwork = "${var.deploy_network}"

  address_type = "INTERNAL"
  address = "${var.lb_address}"

  count = "${var.count}"
}

resource "google_compute_forwarding_rule" "lb" {
  name        = "${var.env_name}-${var.name}-lb-${count.index}"

  project = "${var.project}"
  network = "${var.network}"
  subnetwork = "${var.deploy_network_link}"

  load_balancing_scheme = "INTERNAL"

  ip_address  = "${google_compute_address.lb.address}"
  backend_service = "${google_compute_region_backend_service.lb.self_link}"
  ports  = ["${element(var.forwarding_rule_ports, count.index)}"]
  ip_protocol = "TCP"

  count = "${var.count > 0 ? length(var.forwarding_rule_ports) : 0}"
}

resource "google_compute_region_backend_service" "lb" {
  name = "${var.lb_name}"
  project = "${var.project}"
  health_checks = ["${google_compute_health_check.lb.*.self_link}"]
}
