module "ssh-lb" {
  source = "../load_balancer"

  env_name = "${var.env_name}"
  name     = "ssh"

  global  = false
  count   = 1
  project = "${var.project}"
  region  = "${var.region}"
  network = "${var.network}"

  deploy_network = "${google_compute_subnetwork.pas.name}"
  deploy_network_link = "${google_compute_subnetwork.pas.self_link}"
  ip_cidr_range = "${google_compute_subnetwork.pas.ip_cidr_range}"
  ports                 = ["2222"]
  forwarding_rule_ports = ["2222"]
  lb_name               = "${var.env_name}-cf-ssh"
  lb_address            = "${cidrhost(google_compute_subnetwork.pas.ip_cidr_range, -11)}"

  health_check = true
  health_check_port                = "2222"
  health_check_interval            = 5
  health_check_timeout             = 3
  health_check_healthy_threshold   = 6
  health_check_unhealthy_threshold = 3
}

module "gorouter" {
  source = "../load_balancer"

  env_name = "${var.env_name}"
  name     = "gorouter"
  project  = "${var.project}"
  region   = "${var.region}"

  global          = "${var.global_lb}"
  count           = "${var.global_lb > 0 ? 0 : 1}"
  network         = "${var.network}"

  deploy_network = "${google_compute_subnetwork.pas.name}"
  deploy_network_link = "${google_compute_subnetwork.pas.self_link}"
  ip_cidr_range = "${google_compute_subnetwork.pas.ip_cidr_range}"

  zones           = "${var.zones}"
  ssl_certificate = "${var.ssl_certificate}"

  ports = ["443"]

  optional_target_tag   = "${var.isoseg_lb_name}"
  lb_name               = "${var.env_name}-${var.global_lb > 0 ? "httpslb" : "tcplb"}"
  lb_address            = "${cidrhost(google_compute_subnetwork.pas.ip_cidr_range, -12)}"
  forwarding_rule_ports = ["443"]

  health_check                     = true
  health_check_port                = "8080"
  health_check_interval            = 5
  health_check_timeout             = 3
  health_check_healthy_threshold   = 6
  health_check_unhealthy_threshold = 3
}

module "websocket" {
  source = "../load_balancer"
  project  = "${var.project}"
  region   = "${var.region}"
  env_name = "${var.env_name}"
  name     = "websocket"

  global  = false
  network = "${var.network}"

  deploy_network = "${google_compute_subnetwork.pas.name}"
  deploy_network_link = "${google_compute_subnetwork.pas.self_link}"
  ip_cidr_range = "${google_compute_subnetwork.pas.ip_cidr_range}"

  count   = "0"

  ports                 = ["443"]
  lb_name               = "${var.env_name}-cf-ws"
  lb_address            = "${cidrhost(google_compute_subnetwork.pas.ip_cidr_range, -13)}"
  forwarding_rule_ports = ["443"]

  health_check                     = true
  health_check_port                = "8080"
  health_check_interval            = 5
  health_check_timeout             = 3
  health_check_healthy_threshold   = 6
  health_check_unhealthy_threshold = 3
}

# module "tcprouter" {
#   source = "../load_balancer"
#
#   env_name = "${var.env_name}"
#   name     = "tcprouter"
#
#   global  = false
#   network = "${var.network}"
#   count   = 0
#
#   ports                 = ["1024-65535"]
#   lb_name               = "${var.env_name}-cf-tcp"
#   forwarding_rule_ports = ["1024-1123"]
#
#   health_check                     = true
#   health_check_port                = "80"
#   health_check_interval            = 30
#   health_check_timeout             = 5
#   health_check_healthy_threshold   = 10
#   health_check_unhealthy_threshold = 2
# }
