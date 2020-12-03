provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "gateway-ec2" {
  ami                         = "ami-0056d3b3567a0b634"
  subnet_id                   = var.subnet_id
  instance_type               = "m4.xlarge"
  associate_public_ip_address = true
  #security_groups             = var.security_groups
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
 data "aws_storagegateway_local_disk" "local-disk" {
  disk_node   = aws_volume_attachment.ebs_att.device_name
  gateway_arn = aws_storagegateway_gateway.gateway.arn
}

resource "aws_storagegateway_cache" "cache-disk" {
  disk_id     = data.aws_storagegateway_local_disk.local-disk.id
  gateway_arn = aws_storagegateway_gateway.gateway.arn
}

resource "aws_storagegateway_nfs_file_share" "nfs" {
  client_list  = var.nfs_client_list
  gateway_arn  = aws_storagegateway_gateway.gateway.arn
  location_arn = aws_s3_bucket.bucket.arn
  role_arn     = aws_iam_role.gateway.arn
}

data "aws_iam_policy_document" "storagegateway" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["storagegateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3-bucket-access" {
  statement {
    actions = [
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectVersion",
                "s3:ListMultipartUploadParts",
                "s3:PutObject",
                "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.bucket.arn
    ]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectVersion",
                "s3:ListMultipartUploadParts",
                "s3:PutObject",
                "s3:PutObjectAcl"

    ]

    resources = [
      "${aws_s3_bucket.s3.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3-bucket-access" {
  policy = data.aws_iam_policy_document.s3-bucket-access.json
}

resource "aws_iam_role" "gateway" {
  name               = "${var.gateway_name}-role"
  assume_role_policy = data.aws_iam_policy_document.storagegateway.json
}

resource "aws_iam_role_policy_attachment" "gateway-attach" {
  role       = aws_iam_role.gateway.name
  policy_arn = aws_iam_policy.s3-bucket-access.arn
}


 output "gateway_ip" {
   value = aws_instance.gateway-ec2.public_ip
   }
