provider "aws" {
  region = var.aws-region
  shared_credentials_file = var.aws-credential-file
}

resource "aws_key_pair" "demo_ssh_key" {
  key_name   = "demo_ssh_key"
  public_key = file(var.aws-ssh-key-public)
}

resource "aws_instance" "webserver" {
   count = var.aws-count-instance
   ami = var.aws-ami
   instance_type = "t2.micro"
   vpc_security_group_ids = [
      aws_security_group.web.id,
      aws_security_group.ssh.id,
      aws_security_group.egress.id
   ] 
   key_name = aws_key_pair.demo_ssh_key.key_name

  connection {
    type        = "ssh"
    host = self.public_ip
    private_key = file(var.aws-ssh-key-private)
    user        = var.aws-user
  }

  provisioner "remote-exec" {
    inline = [
      "sleep",
      "sudo apt update -y",
      "sudo apt install nginx -y"
    ]
  }

   tags = {
    Name ="webhost-${count.index +1}"
    Environment = "DEV"
    OS = "Ubuntu Server"
  }
}

resource "aws_security_group" "ssh" {
  name        = "sgSSH"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-ssh"
  }
}

resource "aws_security_group" "web" {
  name        = "sgWEB"
  description = "Security group for web that allows web traffic from internet"
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-web"
  }
}

resource "aws_security_group" "egress" {
  name        = "sgEgreess"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-egress"
  }
}

resource "null_resource" "webservers" {

  provisioner "local-exec" {
    command = "echo  'Hello World!'"
  }

}
