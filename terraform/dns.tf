resource "aws_route53_record" "dns-master" {
    count                   = "${var.master_count}"
    type                    = "A"
    ttl                     = 60
    zone_id                 = "${var.aws_hosted_zone_id}"

    name                    = "${element(ddcloud_server.master.*.name, count.index)}.${var.subdomain_name}.${var.domain_name}"
    records                 = ["${element(ddcloud_nat.master.*.public_ipv4, count.index)}"]
}

resource "aws_route53_record" "dns-worker" {
    count                   = "${var.worker_count}"
    type                    = "A"
    ttl                     = 60
    zone_id                 = "${var.aws_hosted_zone_id}"

    name                    = "${element(ddcloud_server.worker.*.name, count.index)}.${var.subdomain_name}.${var.domain_name}"
    records                 = ["${element(ddcloud_nat.worker.*.public_ipv4, count.index)}"]
}
