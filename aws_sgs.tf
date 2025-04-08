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
    cidr_blocks = ["0.0.0.0/0"] 
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


resource "aws_security_group" "wavelength_instance_sg" {
  name        = "wavelength-instance-sg"
  description = "Security group for MEC (Wavelength) instances"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow MQTT traffic for mosquitto"
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optionally allow Kubernetes API traffic if required (only for control plane if separate)
  ingress {
    description = "Allow Kubernetes API (control plane)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Allow internal VPC communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.tf_vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
  description = "Allow Prometheus access"
  from_port   = 30090
  to_port     = 30090
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  description = "Allow Grafana access"
  from_port   = 30300
  to_port     = 30300
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}


  tags = {
    Name = "wavelength-instance-sg"
  }
}


resource "aws_security_group" "cloud_instance_sg" {
  name        = "cloud-instance-sg"
  description = "Security group for cloud instances and services"
  vpc_id      = aws_vpc.tf_vpc.id

  # Allow SSH (limit CIDR range as needed)
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound for LoadBalancer exposed ports (e.g., censor and compression services)
  ingress {
    description = "Allow HTTP access for censor service"
    from_port   = 5004
    to_port     = 5004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP access for compression service"
    from_port   = 5005
    to_port     = 5005
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow communication from within the VPC
  ingress {
    description = "Allow internal communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.tf_vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
  description = "Allow Prometheus access"
  from_port   = 30090
  to_port     = 30090
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
  description = "Allow Grafana access"
  from_port   = 30300
  to_port     = 30300
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}


  tags = {
    Name = "cloud-instance-sg"
  }
}