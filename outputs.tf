output "region_fqdn_1" {
  value = "${aws_instance.region_workers[0].public_ip}"
}
output "wlz_fqdn_1" {
  value = "${aws_eip.tf-wlz-cip[0].carrier_ip}"
}
