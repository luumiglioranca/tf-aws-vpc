variable "create" {
  type    = bool
  default = true
}

variable "vpc_name" {
  type = string
}

variable "region" {
  type    = any
  default = []

}
variable "cidr_block" {
  type    = any

  default = []
}

variable "enable_dns_hostnames" {
  type    = any
  default = []
}

variable "enable_dns_support" {
  type    = any
  default = []
}

variable "instance_tenancy" {
  type    = any
  default = []
}

variable "assign_generated_ipv6_cidr_block" {
  type    = any
  default = []
}

variable "subnet_private" {
  type    = any
  default = []
}

variable "subnet_public" {
  type    = any
  default = []
}

variable "tag_public" {
  type    = map(string)
  default = {}
}

variable "tag_private" {
  type    = map(string)
  default = {}
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "dhcp_options" {
  type    = any
  default = []
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "flow_logs" {
  type    = any
  default = {}
}

variable "subnet_database" {
  type    = any
  default = []
}

variable "subnet_cache" {
  type    = any
  default = []
}

variable "vpc_peering_connection" {
  type    = any
  default = []
}

variable "vpn_customer_gateway" {
  type    = any
  default = []
}

variable "vpc_endpoint" {
  type    = any
  default = []
}