## Creates VPC
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name       = "${var.env_name}"
    managed_by = "terraform"
    project_name = "${var.project_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

## Creates a variable
output "vpc_id" {
  value = "${aws_vpc.main.id}"
}
## Creates DNS zones
resource "aws_route53_zone" "private" {
  name   = "${var.env_name}-${aws_vpc.main.id}.com"
  vpc_id = "${aws_vpc.main.id}"

  lifecycle {
    create_before_destroy = true
  }
}

## Adds private subnets for internal-access only instances across AZs
resource "aws_subnet" "private" {
  count             = "${var.private_subnet_count}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${lookup(var.subnets_private_cidr, count.index)}"
  availability_zone = "${element(split(",", replace(lookup(var.azs, var.region), " ", "")), count.index)}"

  tags {
    Name       = "private_az${count.index}.${var.env_name}"
    managed_by = "terraform"
    project_name = "${var.project_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

## The Security Group for cluster instance
resource "aws_security_group" "bastion" {
  vpc_id      = "${aws_vpc.main.id}"
  name        = "bastion.${var.env_name}"
  description = "Allow access to Bastion server from limited IPs"

  ingress {
    from_port   = 65535
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${split(",", replace(var.cidr_whitelist," ",""))}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name       = "bastion.${var.env_name}"
    managed_by = "terraform"
    project_name = "${var.project_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Create RDS Security Groups
resource "aws_security_group" "mysql" {
    vpc_id = "${aws_vpc.main.id}"
    name = "mysql.${var.env_name}"
    description = "Allow MySQL access"
    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = ["${aws_security_group.bastion.id}", "${aws_security_group.openvpn.id}", "${aws_security_group.server.id}"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "mysql.${var.env_name}"
    }
}