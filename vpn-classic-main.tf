############################
## Classic VPN GCP - Main ##
############################

# Create a Static IP for Classic VPN
resource "google_compute_address" "vpn-static-ip" {
  name    = "${var.prefix}-vpn-gateway-classic-ip"
  project = google_project.vpn-classic.project_id
}

# Create a Classic VPN
resource "google_compute_vpn_gateway" "vpn-gateway-classic" {
  depends_on = [google_compute_network.vpn-network-classic]

  name    = "${var.prefix}-vpn-gateway-classic"
  project = google_project.vpn-classic.project_id
  network = google_compute_network.vpn-network-classic.id
}

# VPN Forwarding Rule ESP
resource "google_compute_forwarding_rule" "vpn-fr-esp-classic" {
  name        = "${var.prefix}-vpn-gateway-fr-esp"
  project     = google_project.vpn-classic.project_id
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn-static-ip.address
  target      = google_compute_vpn_gateway.vpn-gateway-classic.id
}

# VPN Forwarding Rule UDP 500
resource "google_compute_forwarding_rule" "vpn-fr-udp500-classic" {
  name        = "${var.prefix}-vpn-gateway-fr-udp500"
  project     = google_project.vpn-classic.project_id
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn-static-ip.address
  target      = google_compute_vpn_gateway.vpn-gateway-classic.id
}

# VPN Forwarding Rule UDP 4500
resource "google_compute_forwarding_rule" "vpn-fr-udp4500-classic" {
  name        = "${var.prefix}-vpn-gateway-fr-udp4500"
  project     = google_project.vpn-classic.project_id
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn-static-ip.address
  target      = google_compute_vpn_gateway.vpn-gateway-classic.id
}

# VPN Router
resource "google_compute_router" "vpn-router-classic" {
  name    = "${var.prefix}-vpn-router-classic"
  project = google_project.vpn-classic.project_id
  network = google_compute_network.vpn-network-classic.name

  bgp {
    asn = var.classic_vpn_router_asn
  }
}

# VPN Tunnel
resource "google_compute_vpn_tunnel" "vpn-tunnel-classic" {
  depends_on = [
    google_compute_forwarding_rule.vpn-fr-esp-classic,
    google_compute_forwarding_rule.vpn-fr-udp500-classic,
    google_compute_forwarding_rule.vpn-fr-udp4500-classic,
    google_compute_vpn_gateway.vpn-gateway-classic
  ]

  provider           = google-beta
  name               = "${var.prefix}-vpn-tunnel-classic"
  project            = google_project.vpn-classic.project_id
  region             = var.gcp_region
  peer_ip            = var.classic_vpn_ext_gateway_ip
  shared_secret      = var.classic_vpn_shared_secret
  target_vpn_gateway = google_compute_vpn_gateway.vpn-gateway-classic.id
  router             = google_compute_router.vpn-router-classic.name
 }

# Create Router Interfaces
resource "google_compute_router_interface" "vpn-interface-classic" {
  depends_on = [google_compute_vpn_tunnel.vpn-tunnel-classic]

  name       = "${var.prefix}-vpn-router-interface-classic"
  project    = google_project.vpn-classic.project_id  
  router     = google_compute_router.vpn-router-classic.name
  region     = var.gcp_region
  ip_range   = var.classic_vpn_router_interface_ip_range
  vpn_tunnel = google_compute_vpn_tunnel.vpn-tunnel-classic.name
}

# Create Peers
resource "google_compute_router_peer" "vpn-peer-classic" {
  depends_on = [google_compute_router_interface.vpn-interface-classic]

  name                      = "${var.prefix}-vpn-router-peer-classic"
  project                   = google_project.vpn-classic.project_id 
  router                    = google_compute_router.vpn-router-classic.name
  region                    = var.gcp_region
  peer_ip_address           = var.classic_vpn_router_peer_ip_address
  peer_asn                  = var.classic_vpn_peer_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.vpn-interface-classic.name
}