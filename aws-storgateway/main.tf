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
  
  }

resource "aws_ebs_volume" "ebs" {
  availability_zone = aws_instance.gateway-ec2.availability_zone
  size              = 150
  
  }
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.gateway-ec2.id
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
 data "aws_storagegateway_local_disk" "test" {
  disk_path   = aws_volume_attachment.ebs_att.device_name
  gateway_arn = aws_storagegateway_gateway.gateway.arn
}

 output "gateway_ip" {
   value = aws_instance.gateway-ec2.public_ip
   }
