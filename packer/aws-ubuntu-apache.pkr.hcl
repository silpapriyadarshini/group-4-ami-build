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
  default = "aws-ubuntu-apache"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "apache-green" {
  ami_name      = "${var.ami_prefix}-green-${local.timestamp}"
  instance_type = "t2.micro"
  // region = "ap-northeast-3"
  // vpc_id = "vpc-0c1dfdfedcfe2459f"
  region        = "ap-south-1"
  vpc_id        = "vpc-0f20e8ddf56dc2520"
  subnet_id     = "subnet-08cabd7e59e80aa23"
  security_group_id = "sg-0b2ff4d33f1c10f4a"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  
  ssh_username = "ubuntu"
}

build {
  name = "packer-Green"
  sources = [
    "source.amazon-ebs.apache-green"
  ]
  provisioner "ansible" {
    playbook_file = "./ansible/green/greensite.yml"
  }

}

source "amazon-ebs" "apache-blue" {
  ami_name      = "${var.ami_prefix}-blue-${local.timestamp}"
  instance_type = "t2.micro"
  // region = "ap-northeast-3"
  // vpc_id = "vpc-0c1dfdfedcfe2459f"
  region        = "ap-south-1"
  vpc_id        = "vpc-0f20e8ddf56dc2520"
  subnet_id     = "subnet-08cabd7e59e80aa23"
  security_group_id = "sg-0b2ff4d33f1c10f4a"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

build {
  name = "packer-Blue"
  sources = [
    "source.amazon-ebs.apache-blue"
  ]
  provisioner "ansible" {
    playbook_file = "./ansible/blue/bluesite.yml"
  }

}