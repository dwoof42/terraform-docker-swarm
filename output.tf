output "master_ip" {
  value = ["${aws_instance.master.public_ip}"]
}

output "master_private_ip" {
  value = ["${aws_instance.master.private_ip}"]
}

output "slave_ip" {
  value = ["${aws_instance.slave.*.public_ip}"]
}
