## ---------------------------------------------------------------------------------------------------------------------
## AMAZON VPC CONFIGURATION
## ---------------------------------------------------------------------------------------------------------------------

# Create the VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eco-poc-vpc"
  }
}

# Create VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.flow_log_example_role.arn
  log_destination = aws_cloudwatch_log_group.cw_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.tf_vpc.id
}
resource "aws_cloudwatch_log_group" "cw_log_group" {
  name              = "eco_cw_log_group"
  kms_key_id        = aws_kms_key.cloudwatch.arn
  retention_in_days = 400
}
resource "aws_kms_key" "cloudwatch" {
  description             = "KMS key for Amazon CloudWatch"
  deletion_window_in_days = 7
  enable_key_rotation     = "true"
  policy                  = data.aws_iam_policy_document.cloudwatch.json
}

# Create subnets in parent region
resource "aws_subnet" "region_subnets" {
  for_each             = var.availability_zones
  vpc_id               = aws_vpc.tf_vpc.id
  cidr_block           = each.value.cidr_block
  availability_zone_id = each.value.availability_zone_id
  tags = {
    Name = "demo-region-subnet-${each.key}"
  }
}


# Create subnet for each Wavelength Zone
resource "aws_subnet" "wavelength_subnets_public" {
  for_each             = var.wavelength_zones_public
  vpc_id               = aws_vpc.tf_vpc.id
  cidr_block           = each.value.cidr_block
  availability_zone_id = each.value.availability_zone_id
  tags = {
    Name = "demo-public-subnet-${each.key}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "tf_internet_gw" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf-internet-gw"
  }
}

# Create Carrier Gateway
resource "aws_ec2_carrier_gateway" "tf_carrier_gateway" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf-carrier-gw"
  }
}