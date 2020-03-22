provider "aws" {
  region = var.aws-region
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
      aws_security_group.ping.id,
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
      "sleep 15 ",
      "sudo apt update -y",
      "sudo apt install nginx -y"
    ]
  }

   tags = {
    Name ="www-${count.index +1}"
    Group = "WWW"
    Environment = "DEV"
    OS = "Ubuntu"
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

resource "aws_security_group" "ping" {
  name        = "sgPing"
  description = "Default security group that allows to ping the instance"
  
  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "sg-ping"
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

resource "null_resource" "cluster" {
  
  triggers = {
    cluster_instance_ids = "${join(",", aws_instance.webserver.*.id)}"
  }
  
  provisioner "local-exec" {

    command = "ansible -i ec2.py all -u ${var.aws-user} -m ping"

  }
}