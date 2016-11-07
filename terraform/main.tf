provider "ddcloud" {
	region 		= "AU"
}

# You will need: A network domain, a VLAN, and a firewall rule that grants you inbound SSH access to the target servers.
# You will also need an AWS Route53 DNS zone (otherwise, delete or rename dns.tf).

variable "networkdomain_name"		{ default = "Kubernetes Demo" }
variable "datacenter_name"			{ default = "AU10" }
variable "vlan_name"				{ default = "Primary" }

variable "domain_name"          	{ default = "tintoy.io" }
variable "subdomain_name"       	{ default = "au10.kube" }
variable "aws_hosted_zone_id"   	{ } # Supplied in credentials.tf

variable "os_image_name"			{ default = "Ubuntu 14.04 2 CPU" }
variable "ipv4_base"				{ default = "10.0.7" }

variable "master_count"				{ default = 3	}
variable "master_disk_size_gb"  	{ default = 20 }
variable "master_memory_gb"		 	{ default = 8 }
variable "master_cpu_count"		 	{ default = 2 }
variable "master_address_start" 	{ default = 20 }

variable "worker_count"		 		{ default = 4 }
variable "worker_disk_size_gb"  	{ default = 30 }
variable "worker_memory_gb"	 		{ default = 8 }
variable "worker_cpu_count"	 		{ default = 4 }
variable "worker_address_start" 	{ default = 30 }

variable "edge_count"		 		{ default = 2 }
variable "edge_disk_size_gb"  		{ default = 20 }
variable "edge_memory_gb"	 		{ default = 8 }
variable "edge_cpu_count"	 		{ default = 2 }
variable "edge_address_start" 		{ default = 50 }

variable "ssh_bootstrap_password"	{ } # Supplied in credentials.tf
variable "ssh_public_key_file"		{ } # Supplied in credentials.tf

# Constants
variable "count_format"		 		{ default = "%02d" }

# Look up network and VLAN.
data "ddcloud_networkdomain" "kubernetes" {
	name 		= "${var.networkdomain_name}"
	datacenter	= "${var.datacenter_name}"
}

data "ddcloud_vlan" "primary" {
	name			= "${var.vlan_name}"
	networkdomain 	= "${data.ddcloud_networkdomain.kubernetes.id}"
}

output "networkdomain" {
	value = "${data.ddcloud_networkdomain.kubernetes.id}"
}
output "vlan" {
	value = "${data.ddcloud_vlan.primary.id}"
}
