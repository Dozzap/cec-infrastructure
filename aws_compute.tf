data "aws_ebs_default_kms_key" "current" {}
data "aws_kms_key" "current" {
  key_id = data.aws_ebs_default_kms_key.current.key_arn
}

data "aws_ssm_parameter" "amzn-linux-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# ubuntu AMI -------------------
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# ========================================== UBUNTU TEMPLATES [START] ==========================================

# Region ubuntu Template 
resource "aws_launch_template" "region_ubuntu_launch_template" {
  name          = "eco-region-ubuntu-workers"
  image_id      = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = var.instance_type
  key_name      = var.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.current.arn
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.worker_role.arn
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }

  monitoring {
    enabled = true
  }
}
#-=-=-=-=-=-=-=-=- 

# Wavelenght ubuntu Template 
resource "aws_launch_template" "wlz_ubuntu_launch_template" {
  name          = "eco-wlz-ubuntu-workers"
  image_id      = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = var.instance_type
  key_name      = var.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.current.arn
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.worker_role.arn
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }

  monitoring {
    enabled = true
  }
}
# -=-=-=-=-=-=-=-=-=-=-=-=-

# ========================================== UBUNTU TEMPLATES [END] ==========================================

resource "aws_launch_template" "wlz_launch_template" {
  name          = "eco-wlz-workers"
  image_id      = data.aws_ssm_parameter.amzn-linux-ami.value
  instance_type = var.instance_type
  key_name      = var.key_name
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.current.arn
    }
  }
  iam_instance_profile {
    arn = aws_iam_instance_profile.worker_role.arn
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = true
  }
}

# Create one ASG for each WLZ subnet
resource "aws_instance" "wlz_workers" {
  count = 1
  subnet_id = aws_subnet.wavelength_subnets_public["wlz"].id
  security_groups = [aws_security_group.instance_sg.id]
  user_data = "${element(["${filebase64("templates/wlz1.sh")}"], count.index)}"
  #launch_template {
  #  id      = aws_launch_template.wlz_launch_template.id
  #  version = "$Latest"
  #}
  launch_template {
    id      = count.index == 2 ? aws_launch_template.wlz_ubuntu_launch_template.id : aws_launch_template.wlz_launch_template.id
    version = "$Latest"
  }
  tags = {
    Name = "ECO-WLZ-INSTANCE-${count.index}"
  }
}
resource "aws_eip" "tf-wlz-cip" {
  count = 1
  network_border_group = var.wavelength_zones_public["wlz"].availability_zone
}
resource "aws_eip_association" "eip_assoc" {
  count = 1
  instance_id   = aws_instance.wlz_workers[count.index].id
  allocation_id = aws_eip.tf-wlz-cip[count.index].id
}


######################################################################

resource "aws_launch_template" "region_launch_template" {
  name          = "eco-region-workers"
  image_id      = data.aws_ssm_parameter.amzn-linux-ami.value
  instance_type = var.instance_type
  key_name      = var.key_name
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.current.arn
    }
  }
  iam_instance_profile {
    arn = aws_iam_instance_profile.worker_role.arn
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = true
  }
}

# Create one ASG for each region subnet
resource "aws_instance" "region_workers" {
  count = 2

  subnet_id                   = aws_subnet.region_subnets["az1"].id
  user_data = "${count.index == 0 ? filebase64("templates/region.sh") : filebase64("templates/region1.sh")}"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.instance_sg.id]
  
  launch_template {
    id      = aws_launch_template.region_launch_template.id
    version = "$Latest"
  }
  
  tags = {
    Name = "ECO-REGION-INSTANCE-${count.index}"
  }
}
