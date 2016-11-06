/*
 * Kubernetes worker nodes
 */

resource "ddcloud_server" "worker" {
	count 					= "${var.worker_count}"

	name 					= "kube-worker-${format(var.count_format, count.index + 1)}"
	description 			= "Kubernetes worker node ${format(var.count_format, count.index + 1)}"
	admin_password			= "${var.ssh_bootstrap_password}"

	# OS disk (/dev/sda) - expand to ${var.worker_disk_size_gb}.
	disk {
		scsi_unit_id		= 0
		size_gb				= "${var.worker_disk_size_gb}"
		speed				= "STANDARD"
	}

	networkdomain 			= "${data.ddcloud_networkdomain.kubernetes.id}"
	primary_adapter_vlan	= "${data.ddcloud_vlan.primary.id}"
	primary_adapter_ipv4 	= "${var.ipv4_base}.${var.worker_address_start + count.index}"

	dns_primary				= "8.8.8.8"
	dns_secondary			= "8.8.4.4"

	os_image_name			= "${var.os_image_name}"

	tag {
		name  = "role"
		value = "worker"
	}
}

resource "ddcloud_nat" "worker" {
	count					= "${var.worker_count}"

	networkdomain           = "${data.ddcloud_networkdomain.kubernetes.id}"
    private_ipv4            = "${element(ddcloud_server.worker.*.primary_adapter_ipv4, count.index)}"
}

resource "null_resource" "worker_ssh_bootstrap" {
	count					= "${var.worker_count}"

	# Install our SSH public key.
	provisioner "remote-exec" {
		inline = [
			"mkdir -p ~/.ssh",
			"chmod 700 ~/.ssh",
			"echo '${var.ssh_public_key}' > ~/.ssh/authorized_keys",
			"chmod 600 ~/.ssh/authorized_keys"
		]

		connection {
			type			= "ssh"
			
			user			= "root"
			password		= "${var.ssh_bootstrap_password}"

			host			= "${element(ddcloud_nat.worker.*.public_ipv4, count.index)}"
		}
	}
}
