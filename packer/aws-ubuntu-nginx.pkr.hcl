packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "aws-ubuntu-nginx"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "nginx-green" {
  ami_name      = "${var.ami_prefix}-green-${local.timestamp}"
  instance_type = "t2.micro"
  // region = "ap-northeast-3"
  // vpc_id = "vpc-0c1dfdfedcfe2459f"
  region        = "ap-south-1"
  vpc_id        = "vpc-0f20e8ddf56dc2520"
  subnet_id     = "subnet-08cabd7e59e80aa23"
  security_group_id = "sg-00cc3c80f10fe7c44"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
    BaseAMI = "{{ .SourceAMIName }}"
  }
  ssh_username = "ubuntu"
  #ssh_port = 22
}

source "amazon-ebs" "nginx-blue" {
  ami_name      = "${var.ami_prefix}-blue-${local.timestamp}"
  instance_type = "t2.micro"
  // region = "ap-northeast-3"
  // vpc_id = "vpc-0c1dfdfedcfe2459f"
  region        = "ap-south-1"
  vpc_id        = "vpc-0f20e8ddf56dc2520"
  subnet_id     = "subnet-08cabd7e59e80aa23"
  security_group_id = "sg-00cc3c80f10fe7c44"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
    BaseAMI = "{{ .SourceAMIName }}"
  }
  ssh_username = "ubuntu"
  #ssh_port = 22
}

build {
  name = "packer-BlueGreen"
  sources = [
    "source.amazon-ebs.nginx-green",
    "source.amazon-ebs.nginx-blue"
  ]
  provisioner "ansible" {
    playbook_file = "./ansible/green/greensite.yml"
  }
  provisioner "ansible" {
    playbook_file = "./ansible/blue/bluesite.yml"
  }

}