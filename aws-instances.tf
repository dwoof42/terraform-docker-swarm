/* Setup our aws provider */

resource "aws_instance" "swarm_master" {
  ami           = "${var.swarm-imageid}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.swarm.id}"]
  key_name = "swarm"
  subnet_id = "${aws_subnet.swarm.*.id[0]}"

  associate_public_ip_address = true

  tags {
    Name = "${var.master_name}"
  }
  
  connection {
    user = "ec2-user"
    private_key = "${file("${var.private_key}")}"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo docker swarm init",
      "sudo docker swarm join-token --quiet worker > /home/ec2-user/worker-token",
      "sudo docker swarm join-token --quiet manager > /home/ec2-user/manager-token",
      "sudo docker network create -d overlay --attachable stack"
    ]
  }
  provisioner "file" {
    source = "docker-stack.yml"
    destination = "/home/ec2-user/docker-stack.yml"
  }
}

resource "aws_instance" "secondary" {
  count         = 2
  ami           = "${var.swarm-imageid}"
  instance_type = "t3.micro"
  security_groups = ["${aws_security_group.swarm.id}"]
  key_name = "swarm"


  subnet_id = "${aws_subnet.swarm.*.id[0]}"

  associate_public_ip_address = true

  connection {
    user = "ec2-user"
    private_key = "${file("${var.private_key}")}"
  }

  provisioner "file" {
    source = "ssh/key.pem"
    destination  = "/home/ec2-user/key.pem"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i key.pem ec2-user@${aws_instance.swarm_master.private_ip}:/home/ec2-user/manager-token .",
      "sudo docker swarm join --token $(cat manager-token) ${aws_instance.swarm_master.private_ip}:2377"
    ]
  }

  tags = { 
    Name = "${var.tagname}-${count.index}"
  }
}


resource "aws_instance" "slave" {
  count         = 5
  ami           = "${var.swarm-imageid}"
  instance_type = "t3.micro"
  security_groups = ["${aws_security_group.swarm.id}"]
  key_name = "swarm"


  subnet_id = "${aws_subnet.swarm.*.id[0]}"

  associate_public_ip_address = true

  connection {
    user = "ec2-user"
    private_key = "${file("${var.private_key}")}"
  }

  provisioner "file" {
    source = "ssh/key.pem"
    destination  = "/home/ec2-user/key.pem"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i key.pem ec2-user@${aws_instance.swarm_master.private_ip}:/home/ec2-user/worker-token .",
      "sudo docker swarm join --token $(cat worker-token) ${aws_instance.swarm_master.private_ip}:2377"
    ]
  }

  tags = { 
    Name = "${var.tagname}-${count.index}"
  }
}
