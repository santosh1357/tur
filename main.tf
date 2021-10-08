provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "webserver" {
    ami = "ami-00d3938d52d531b8e"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.webServerSG-1.id]
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello World " > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF
    tags = {
        Name = "webserver-1"
    }
}
#By default AWS does not allow any in/out traffic from ec2
#create a security group resource to make web server work
resource "aws_security_group" "webServerSG-1" {
  name = "webServerSG-1"
  ingress {
      from_port = var.server_port
      to_port = var.server_port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}