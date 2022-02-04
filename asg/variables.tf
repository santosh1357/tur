#refernce of variable - var.<varName>
variable "server_port" {
  description = "Incoming port for the web server"
  type = number
  default = 8080
}

output "public_ip" {
  value = aws_instance.webserver.public_ip
  description = "the public ip address of the web server"
}