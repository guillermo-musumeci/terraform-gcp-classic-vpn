#############################
## Classic VPN - Variables ##
#############################

variable "billing_account_id" {
  description = "Billing account id used as default for new projects"
  type        = string
}

variable "prefix" {
  description = "Prefix used for resources that need unique names"
  type        = string
}

variable "classic_vpn_folder_id" {
  type        = string
  description = "Folder to host the VPN Project"
}

variable "classic_vpn_subnet_cidr" {
  type        = string
  description = "VPN Network Subnet 1"
  default     = "10.0.1.0/24"
}

variable "classic_vpn_ext_gateway_ip" {
  type        = string
  description = "Public IP of the external VPN Gateway"
}

variable "classic_vpn_router_asn" {
  description = "ASN for local side of BGP sessions"
  type        = string
  default     = "64514"
}

variable "classic_vpn_peer_asn" {
  description = "ASN for local side of BGP sessions"
  type        = string
  default     = "64515"
}

variable "classic_vpn_shared_secret" {
  description = "Tunnel shared secret"
  type        = string
}

variable "classic_vpn_router_interface_ip_range" {
  description = "Router Interface IP Range"
  type        = string
}

variable "classic_vpn_router_peer_ip_address" {
  description = "Router Peer IP Address"
  type        = string
}

