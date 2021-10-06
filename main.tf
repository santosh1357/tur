provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "vm-1" {
    ami = "ami-0967a8b99f328dfee"
    instance_type = "t2.micro"

    tags = {
        Name = "vm-1"
    }
}