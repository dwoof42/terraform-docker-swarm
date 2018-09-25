
variable "access_key" {}
variable "secret_key" {}


variable "tagname" {
  default = "swarm"
}

variable "swarm-imageid" {
  default = "ami-e251209a"
}

variable "eks-imageid" {
  default = "ami-73a6e20b"
}

variable "eks-imagesize" {
  default = "t2.micro"
}

variable "private_key" {
  default = "/home/dfoster/.ssh/swarm.pem"
}

