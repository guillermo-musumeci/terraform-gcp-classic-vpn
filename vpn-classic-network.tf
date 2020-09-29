################################
## Classic VPN Network - Main ##
################################

# random ID for project
resource "random_integer" "random-classic" {
  max = 2000
  min = 1000
}

# Create the NPR VPN Project
resource "google_project" "vpn-classic" {
  name                = "${var.prefix}-vpn-classic"
  project_id          = "${var.prefix}-vpn-classic-${random_integer.random-classic.id}"
  folder_id           = var.classic_vpn_folder_id 
  auto_create_network = false
  billing_account     = var.billing_account_id
}

# Create the Network for VPN Project
resource "google_compute_network" "vpn-network-classic" {
  name    = "${var.prefix}-vpn-network-classic"
  project = google_project.vpn-classic.project_id
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = "false"
}

# Create a Subnet 
resource "google_compute_subnetwork" "vpn-network-subnet-classic" {
  depends_on = [google_compute_network.vpn-network-classic]
 
  name          = "${var.prefix}-vpn-subnet-classic"
  project       = google_project.vpn-classic.project_id
  ip_cidr_range = var.classic_vpn_subnet_cidr
  region        = var.gcp_region
  network       = google_compute_network.vpn-network-classic.name
}

