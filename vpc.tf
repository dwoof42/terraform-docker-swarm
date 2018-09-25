
#  This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {}

resource "aws_vpc" "swarm" {

  cidr_block = "10.0.0.0/16"

  tags {
    Name = "${var.tagname}"
  }

}

resource "aws_subnet" "swarm" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.swarm.id}"
}

/*
resource "aws_subnet" "swarm" {

  availability_zone = "us-west-2b"
  cidr_block        = "10.0.0.0/24"
  vpc_id            = "${aws_vpc.swarm.id}"
}
*/

resource "aws_internet_gateway" "swarm" {
  vpc_id = "${aws_vpc.swarm.id}"
}

resource "aws_route_table" "swarm" {
  vpc_id = "${aws_vpc.swarm.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.swarm.id}"
  }
}

resource "aws_route_table_association" "demo" {
  count = 2

  subnet_id      = "${aws_subnet.swarm.*.id[count.index]}"
  route_table_id = "${aws_route_table.swarm.id}"
}


