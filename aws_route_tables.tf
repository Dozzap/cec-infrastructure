## ---------------------------------------------------------------------------------------------------------------------
## ROUTE TABLES
## ---------------------------------------------------------------------------------------------------------------------

# Create Region Route Table for Parent Region
resource "aws_route_table" "region_route_table" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "Region Route Table"
  }
}

# Setup Region Route (for IGW)
resource "aws_route" "region_route" {
  route_table_id         = aws_route_table.region_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_internet_gw.id
}

# Associate Route Table with Region Subnets
resource "aws_route_table_association" "region_route_associations" {
  for_each       = var.availability_zones
  subnet_id      = aws_subnet.region_subnets[each.key].id
  route_table_id = aws_route_table.region_route_table.id
}

# Create Wavelength Route Table for Wavelength subnets
resource "aws_route_table" "WLZ_route_table_public" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "Wavelength Zone Route Table (Public)"
  }
}

# Setup Wavelength Route (for Public)
resource "aws_route" "WLZ_route_public" {
  route_table_id         = aws_route_table.WLZ_route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  carrier_gateway_id     = aws_ec2_carrier_gateway.tf_carrier_gateway.id
}

# Associate Wavelength Route Table with Wavelength Zone subnets
resource "aws_route_table_association" "WLZ_route_associations_public" {
  for_each       = var.wavelength_zones_public
  subnet_id      = aws_subnet.wavelength_subnets_public[each.key].id
  route_table_id = aws_route_table.WLZ_route_table_public.id
}


# Setup VPC Endpoints (S3 and EC2)
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id          = aws_vpc.tf_vpc.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.WLZ_route_table_public.id]
}