# Cloud-Edge-Continuum Infrastructure

This repository contains Terraform code to create two EC2 instances:
* One in the Canada Central (ca-central-1) region
* One in the AWS Wavelength Availability Zone in Toronto

## Prerequisites

Before you begin, ensure you have the following installed on your local machine:

* AWS CLI: [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* Terraform: [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Setup Instructions

### 1. Configure AWS Credentials

Ensure your AWS CLI is configured with the necessary credentials:

```bash
aws configure
```

### 2. Create an SSH Key Pair

You'll need an SSH key pair to access your EC2 instances.

1. Log in to the AWS Management Console
2. Navigate to EC2 > Network & Security > Key Pairs
3. Click on Create key pair
4. Enter the key pair name as `test_key`
5. Select PEM as the file format
6. Click Create key pair
7. Download the `test_key.pem` file and place it in the root directory of this project
8. Set the appropriate permissions:

```bash
chmod 400 test_key.pem
```

### 3. Initialize Terraform

In your terminal, navigate to the root directory of this project and run:

```bash
terraform init
```

### 4. Review the Terraform Plan

Preview the actions Terraform will take:

```bash
terraform plan
```

### 5. Apply the Terraform Configuration

Deploy the infrastructure:

```bash
terraform apply
```

When prompted, type `yes` to confirm.

After deployment, Terraform will output the IP addresses of the EC2 instances.

#### Example Output:
```bash
Apply complete! Resources: 30 added, 0 changed, 0 destroyed.

Outputs:

region_fqdn_1 = "15.223.176.210"
wlz_fqdn_1    = "207.61.171.33"
```

## Accessing the EC2 Instances

Use the following command to SSH into your EC2 instances:

```bash
ssh -i test_key.pem ec2-user@
```

Replace `<public_ip_address>` with the IP addresses provided in the Terraform output.

## Teardown Instructions

When you are finished with the EC2 instances, destroy the infrastructure to avoid incurring unnecessary costs:

```bash
terraform destroy
```

Confirm by typing `yes` when prompted.

#### Example Output:
```bash
Destroy complete! Resources: 30 destroyed.
```