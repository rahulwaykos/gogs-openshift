variable "vpc_id" {
  default  = "vpc-3909da44"
}

variable "subnet_id" {
  default  = "subnet-e3a32485"
}

variable "key_name" {
  default  = "storage-gateway"
}

variable "security_groups" {
  default  = "launch-wizard-1"
}

variable "ebs_device_name" {
  default  = "/dev/xvdb"
}

variable "ebs_volume_size" {
  type     = number
  default  = "150"
}

variable "delete_on_termination" {
  default  = "true"
}

variable "gateway_name" {
  default = "nfs-gateway"
}

variable "gateway_timezone" {
  default = "GMT"
}

variable "nfs_client_list" {
  default = ["0.0.0.0/0"]
}

