# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {}

resource "aws_vpc" "gurl" {
  cidr_block = "${var.vpc-cidr-block}.0.0/16"

  tags = "${
    map(
     "Name", "${var.cluster-name}",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "gurl" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.vpc-cidr-block}.${count.index}.0/24"
  vpc_id            = "${aws_vpc.gurl.id}"

  tags = "${
    map(
     "Name", "${var.cluster-name}",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "gurl" {
  vpc_id = "${aws_vpc.gurl.id}"

  tags {
    Name = "${var.cluster-name}"
  }
}

resource "aws_route_table" "gurl" {
  vpc_id = "${aws_vpc.gurl.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gurl.id}"
  }
}

resource "aws_route_table_association" "gurl" {
  count = 2

  subnet_id      = "${aws_subnet.gurl.*.id[count.index]}"
  route_table_id = "${aws_route_table.gurl.id}"
}
