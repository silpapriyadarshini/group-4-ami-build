terraform {
    backend "s3" {
        bucket = "talent-academy-shoaib-lab-tfstates"
        key = "talent-academy/group-4-ami-build/terraform.tfstates"
        region = "ap-south-1"
        dynamodb_table = "terraform-lock"
    }
}