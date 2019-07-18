resource "google_compute_address" "ops-manager-ip" {
  name = "${var.env_name}-ops-manager-ip"
  address = "${cidrhost(var.infra_cidr_range, -14)}"

  project = "${var.project}"
  address_type = "INTERNAL"
  subnetwork = "${var.subnet}"
}

resource "google_compute_address" "optional-ops-manager-ip" {
  name  = "${var.env_name}-optional-ops-manager-ip"
  count = "${min(length(split("", var.optional_opsman_image_url)),1)}"
}
