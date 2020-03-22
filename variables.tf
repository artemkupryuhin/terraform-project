variable "aws-region" {
     default = "us-west-1"
     description = "Amazon region"
}

variable "aws-ami" {
    default = "ami-03ba3948f6c37a4b0"
    description = "The id of the machine image (AMI) to use for the server."
}

variable "aws-count-instance" {
    default = 2
}

variable "aws-ssh-key-private" {
    default = "~/id_rsa"
    description = "Path to the file with private ssh key"
}

variable "aws-ssh-key-public" {
    default = "~/id_rsa.pub"
    description = "Path to the file with public ssh key"
}

variable "aws-user" {
    default = "ubuntu"
}

variable "aws-hostname" {
    default = "web"
}

