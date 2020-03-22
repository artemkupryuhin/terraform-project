output "public_ip" {
  value       = "${aws_instance.webserver.*.public_ip}"
  description = "The public IP address of the instance."
}

output "dns_name" {
  value       = "${aws_instance.webserver.*.public_dns}"
  description = "The DNS name of the instance."
}