provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "gateway-ec2" {
  ami                         = "ami-0056d3b3567a0b634"
  subnet_id                   = var.subnet_id
  instance_type               = "m4.xlarge"
  associate_public_ip_address = true
  security_groups             = var.security_groups
  key_name                    = var.key_name
  
 
  ebs_block_device {
    ebs_device_name       = var.ebs_device_name
    volume_size           = var.ebs_volume_size
    delete_on_termination = var.delete_on_termination
  }
  
  }

resource "aws_s3_bucket" "s3"  {
  bucket       =     "nfs-test"
  acl          =     "public-read-write"
  
  versioning {
    enabled = false
  }
  
  }

resource "aws_storagegateway_gateway" "gateway" {
  gateway_ip_address = aws_instance.gateway-ec2.public_ip
  gateway_name       = var.gateway_name
  gateway_timezone   = var.gateway_timezone
  gateway_type       = "FILE_S3"
} 

 output "service_endpoint" {
   value = aws_storagegateway_gateway.endpoint_type
   }

 output "gateway_ip" {
   value = aws_instance.gateway-ec2.public_ip
   }
