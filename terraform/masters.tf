/*
 * Kubernetes master nodes
 */

resource "ddcloud_server" "master" {
	count 					= "${var.master_count}"

	name 					= "kube-master-${format(var.count_format, count.index + 1)}"
	description 			= "Kubernetes master node ${format(var.count_format, count.index + 1)}"
	admin_password			= "${var.ssh_bootstrap_password}"

	auto_start				= true

	# OS disk (/dev/sda) - expand to ${var.master_disk_size_gb}.
	disk {
		scsi_unit_id		= 0
		size_gb				= "${var.master_disk_size_gb}"
		speed				= "STANDARD"
	}

	networkdomain 			= "${data.ddcloud_networkdomain.kubernetes.id}"
	primary_adapter_vlan	= "${data.ddcloud_vlan.primary.id}"
	primary_adapter_ipv4 	= "${var.ipv4_base}.${var.master_address_start + count.index}"

	dns_primary				= "8.8.8.8"
	dns_secondary			= "8.8.4.4"

	os_image_name			= "${var.os_image_name}"

	tag {
		name 	= "role"
		value	= "master"
	}

	tag {
		name 	= "consul_dc"
		value	= "${data.ddcloud_networkdomain.kubernetes.datacenter}"
	}
}

resource "ddcloud_nat" "master" {
	count					= "${var.master_count}"

	networkdomain           = "${data.ddcloud_networkdomain.kubernetes.id}"
    private_ipv4            = "${element(ddcloud_server.master.*.primary_adapter_ipv4, count.index)}"
}

resource "null_resource" "master_ssh_bootstrap" {
	count					= "${var.master_count}"

	# Install our SSH public key.
	provisioner "remote-exec" {
		inline = [
			"mkdir -p ~/.ssh",
			"chmod 700 ~/.ssh",
			"echo '${file(var.ssh_public_key_file)}' > ~/.ssh/authorized_keys",
			"chmod 600 ~/.ssh/authorized_keys"
		]

		connection {
			type			= "ssh"
			
			user			= "root"
			password		= "${var.ssh_bootstrap_password}"

			host			= "${element(ddcloud_nat.master.*.public_ipv4, count.index)}"
		}
	}
}

output "master_host_names" {
	value = ["${ddcloud_server.master.*.name}.${subdomain_name}.${domain_name}"]
}
output "master_public_ips" {
	value = ["${ddcloud_nat.master.*.public_ipv4}"]
}
