output "master_ip" {
  value = ["${aws_instance.swarm_master.public_ip}"]
}

output "master_private_ip" {
  value = ["${aws_instance.swarm_master.private_ip}"]
}

output "slave_ip" {
  value = ["${aws_instance.slave.*.public_ip}"]
}
