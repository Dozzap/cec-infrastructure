variable "profile" {
  type        = string
  description = "AWS Credentials Profile to use"
  default     = "default"
}

variable "region" {
  type        = string
  default     = "ca-central-1"
  description = "This is the primary AWS region to be used for the video CDN distribution."
}

variable "key_name" {
  type        = string
  default     = "W-DiSM_1st"
  description = "This is your EC2 key name."
}

variable "wavelength_zones_public" {
  description = "This is the metadata for your Wavelength Zone public subnets for the application."
  default = {
    wlz = {
      availability_zone    = "ca-central-1-wl1-yto-wlz-1",
      availability_zone_id = "cac1-wl1-yto-wlz1",
      worker_nodes         = 3,
      cidr_block           = "10.0.10.0/24"
    }
  }
}

variable "availability_zones" {
  description = "This is the metadata for your parent region subnets."
  default = {
    az1 = {
      availability_zone_id = "cac1-az1"
      cidr_block           = "10.0.1.0/24"
    },
    # az2 = {
    #   availability_zone_id = "cac1-az2"
    #   cidr_block           = "10.0.2.0/24"
    # }
  }
}

variable "volume_size" {
  default     = 20
  description = "This is the volume size (GB) of the EBS volumes for the EC2 instances."
}

variable "instance_type" {
  default = "t3.medium"
  validation {
    condition     = contains(["t3.medium", "t3.xlarge", "r5.2xlarge", "g4dn.2xlarge"], var.instance_type)
    error_message = "Valid values for instance types are t3.medium, t3.xlarge, r5.2xlarge, and g4dn.2xlarge."
  }
  description = "This is the EC2 instance type for the OpenVPN instance."
}

variable "your_bucket_id" {
  type        = string
  default     = "wavelength-poc"
  description = "This is the bucket ID to be used for your application assets"
}

