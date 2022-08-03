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


source "amazon-ebs" "blue-green" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-northeast-3"
  vpc_id        = "vpc-0c1dfdfedcfe2459f"

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
}

build {
  name = "packer-BlueGreen"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "ansible" {
    playbook_file = "./ansible/green/greensite.yml"
  }
  provisioner "ansible" {
    playbook_file = "./ansible/blue/bluesite.yml"
  }

}