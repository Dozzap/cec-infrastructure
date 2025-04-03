# Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.tf_vpc.id
}

# Create security group for ECO servers
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "AWS Security Group for ECO servers"
  vpc_id      = aws_vpc.tf_vpc.id
  ingress {
     from_port   = 8000
     to_port     = 8003
     protocol    = "tcp"
     description = "Allow HTTPS access to ECO servers"
     cidr_blocks = ["0.0.0.0/0"]
  }
  # Ingress rule for port 4222
  ingress {
    from_port   = 4222
    to_port     = 4222
    protocol    = "tcp"
    description = "NATS clients"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for port 8222
  ingress {
    from_port   = 8222
    to_port     = 8222
    protocol    = "tcp"
    description = "NATS HTTP management port for information reporting"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for port 6222
  ingress {
    from_port   = 6222
    to_port     = 6222
    protocol    = "tcp"
    description = "NATS routing port for clustering"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for port 7447
  ingress {
    from_port   = 7447
    to_port     = 7447
    protocol    = "tcp"
    description = "Zenho Router"
    cidr_blocks = ["0.0.0.0/0"]
  }

   # Ingress rule for port 7447
  ingress {
    from_port   = 7446
    to_port     = 7446
    protocol    = "tcp"
    description = "Zenho Scoute messages"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for port 8000
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    description = "1 Zenoh management interface "
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Ingress rule for port 8000
  ingress {
    from_port   = 8050
    to_port     = 8050
    protocol    = "tcp"
    description = "2 Zenoh management interface"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Ingress rule for port 1883
  ingress {
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    description = "MQTT communication port"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Ingress rule for port 9001
  ingress {
    from_port   = 9001
    to_port     = 9001
    protocol    = "tcp"
    description = "MQTT Websockets"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Ingress rule for SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH access"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP or bastion host IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic"
  }
  

  tags = {
    Name = "instance_sg"
  }
}


# wavelength-master-sg.tf
resource "aws_security_group" "wlz_master" {
  name        = "wlz_master_sg"
  description = "Security Group for Wavelength Master"
  vpc_id      = aws_vpc.tf_vpc.id
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    # Remove the reference to wlz_worker if it's not necessary
    cidr_blocks = ["0.0.0.0/0"]  # Replace with the appropriate CIDR or IP range
  }

  ingress {
    from_port   = 5000
    to_port     = 5005
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with the appropriate CIDR or IP range
  }

  tags = {
    Name = "wlz_master"
  }
}