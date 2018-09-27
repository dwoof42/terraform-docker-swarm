/* Setup our aws provider */

resource "aws_instance" "swarm_master" {
  ami           = "${var.swarm-imageid}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.swarm.id}"]
  key_name = "swarm"
  subnet_id = "${aws_subnet.swarm.*.id[0]}"

  associate_public_ip_address = true

  tags {
    Name = "${var.tagname}"
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
      "sudo docker swarm join-token --quiet worker > /home/ec2-user/worker-token"
    ]
  }
  provisioner "file" {
    source = "docker-stack.yml"
    destination = "/home/ec2-user/docker-stack.xml"
  }
}

resource "aws_instance" "slave" {
  count         = 4
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
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
    ]
  }

  /*
  connection {
    user = "ubuntu"
    private_key = "ssh/key"
  }
  provisioner "file" {
    source = "key.pem"
    destination = "/home/ubuntu/key.pem"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install apt-transport-https ca-certificates",
      "sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D",
      "sudo sh -c 'echo \"deb https://apt.dockerproject.org/repo ubuntu-trusty main\" > /etc/apt/sources.list.d/docker.list'",
      "sudo apt-get update",
      "sudo apt-get install -y docker-engine=1.12.0-0~trusty",
      "sudo chmod 400 /home/ubuntu/test.pem",
      "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i test.pem ubuntu@${aws_instance.master.private_ip}:/home/ubuntu/token .",
      "sudo docker swarm join --token $(cat /home/ubuntu/token) ${aws_instance.master.private_ip}:2377"
    ]
  }
  */
  tags = { 
    Name = "${var.tagname}-${count.index}"
  }
}
