#Single WSever is single pofailure, ASG can monitor and replace failed nodes as well as scale on load
#Create ASG by first creating a resource (aws_launch_config..similar to aws_instance)
#the second resorce we create is tje ASG itself (aws_autoscaling_group) which refers to res-1(aws_launch_con..)

provider "aws" {
    region = "ap-south-1"
}

resource "aws_launch_configuration" "webserver_asg" {
    image_id = "ami-00d3938d52d531b8e"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.webServerSG-1.id]
#subnets mandatory param for launch config, each subnet lives in isolated AZ
#giving multiple subnets is way to achieve datacenter redundancy
#rather than hardcoding we use DATA Sources to define subnets to make code more portable
#data sources are ways to query provider APIs for info like subnet data, vpc data, ip data, ami ids etc 
#data "provider_type" "name" {
    #[CONFIG...] - filter we apply on values return from provider api
#} data.provider_type.name.attributre [reference the returned data]
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello World " > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF
    #Launch configs are immutable, so any change in them will force change in ASG
    #change terraform default lifecycle policy (destroy then create) using lifecycle hooks
    lifecycle {
        create_before_destroy = true
    }
}


resource "aws_autoscaling_group" "asg_webserver" {
    launch_configuration = aws_launch_configuration.webserver_asg.name
# you can pull the subnet IDs out of the aws_subnet_ids
# data source and tell your ASG to use those subnets via the (somewhat
# oddly named) vpc_zone_identifier argument:
    vpc_zone_identifier = data.aws_subnet_ids.defVpcSubnets.ids
    min_size = 2
    max_size = 10
    tag = {
        key = "Name"
        value = "asg-webserver"
        propagate_at_launch = true

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