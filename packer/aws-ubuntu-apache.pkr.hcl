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
variable "color_green" {
  type    = string
  default = "green"
}
variable "color_blue" {
  type    = string
  default = "blue"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "apache-green" {
  ami_name      = "${var.ami_prefix}-green-${local.timestamp}"
  instance_type = "t3.small"
  region        = "ap-south-1"
  vpc_id        = "vpc-0f20e8ddf56dc2520"
  subnet_id     = "subnet-08cabd7e59e80aa23"
  security_group_id = "sg-0b2ff4d33f1c10f4a"
  associate_public_ip_address = true

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
    Name = "apache-green"
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-Green"
  sources = [
    "source.amazon-ebs.apache-green"
  ]
  provisioner "ansible" {
    playbook_file = "./playbooks/main.yml"
    extra_arguments = ["--extra-vars", "color=${var.color_green}"]
  }

}

source "amazon-ebs" "apache-blue" {
  ami_name      = "${var.ami_prefix}-blue-${local.timestamp}"
  instance_type = "t3.small"
  region        = "ap-south-1"
  vpc_id        = "vpc-0f20e8ddf56dc2520"
  subnet_id     = "subnet-08cabd7e59e80aa23"
  security_group_id = "sg-0b2ff4d33f1c10f4a"
  associate_public_ip_address = true

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
    Name = "apache-blue"
  }

  ssh_username = "ubuntu"
}

build {
  name = "packer-Blue"
  sources = [
    "source.amazon-ebs.apache-blue"
  ]
  provisioner "ansible" {
    playbook_file = "./playbooks/main.yml"
    extra_arguments = ["--extra-vars", "color=${var.color_blue}"]
  }

}