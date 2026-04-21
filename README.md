# 🚀 AWS Infrastructure as Code with Terraform & LocalStack

## 📌 Project Overview

This project demonstrates the design and deployment of a **modular** and **scalable** AWS cloud infrastructure using **Terraform** and **LocalStack**. It provides a complete, isolated local development environment that mirrors production configurations, enabling validation of networking and security configurations before real AWS deployments.

## 🏗️ Architecture

The infrastructure is fully modularized and includes:

### Components
- **VPC:** Isolated virtual network with subnet segmentation
- **Subnets:** Public subnet (internet access) and private subnet (isolated)
- **Internet Gateway:** Routing configuration for web access
- **EC2 Instances:** Web servers provisioned in private subnet
- **Security Groups:** Firewall rules allowing SSH (22), HTTP (80), and HTTPS (443)

## 📁 Project Structure

```
AWS_TF/
├── Keys/                          # AWS credentials
└── Terraform/
    ├── main.tf                   # Root module configuration
    ├── variables.tf              # Variable definitions
    ├── terraform.tfvars          # Variable values
    ├── providers.tf              # Provider configuration
    ├── outputs.tf                # Output values
    ├── terraform.tfstate         # State file (local)
    └── modules/
        ├── vpc/                  # VPC module (reusable)
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── ec2/                  # EC2 module (reusable)
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
```

## 🛠️ DevOps Best Practices Implemented

- **Infrastructure as Code (IaC):** Complete infrastructure defined in version-controlled Terraform files
- **Modularity:** Logical separation of resources (VPC, EC2) for maximum reusability
- **Dynamic Tagging:** Centralized tag management using `merge()` function for cost tracking and FinOps
- **Strict Variable Management:** Clean separation between variable definitions and values
- **Local Cloud Simulation:** LocalStack eliminates development costs while mirroring AWS services
- **Security:** Security groups with precise ingress rules (SSH, HTTP, HTTPS) and full egress access

## 📋 Prerequisites

- Docker & Docker Desktop (for LocalStack)
- Terraform >= 1.10.5
- AWS CLI v2
- Basic knowledge of AWS and Terraform

## 🚀 Installation & Deployment

### Step 1: Launch LocalStack

```bash
docker run -d -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
```

### Step 2: Configure AWS Credentials

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

### Step 3: Initialize Terraform

```bash
cd Terraform
terraform init
```

### Step 4: Review the Infrastructure Plan

```bash
terraform plan
```

### Step 5: Deploy the Infrastructure

```bash
terraform apply -auto-approve
```

## 🔍 Verification & Validation

After deployment, verify resources are created in LocalStack:

```bash
# List all VPCs
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs --output table

# List EC2 instances with tags
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --query "Reservations[*].Instances[*].{ID:InstanceId, Type:InstanceType, Tags:Tags}" \
  --output table

# Describe security groups
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups --output table
```

## 🧹 Cleanup

To destroy all resources and stop LocalStack:

```bash
terraform destroy -auto-approve
docker stop $(docker ps -q --filter "ancestor=localstack/localstack")
```

## 💡 Troubleshooting & Lessons Learned

| Issue | Solution |
|-------|----------|
| AWS CLI segfault errors | Use `--endpoint-url` parameter for direct endpoint calls instead of profile-based authentication |
| Variable scope in modules | Implement proper variable passing between modules using module outputs and inputs |
| LocalStack connectivity issues | Ensure Docker container is running and ports 4566 and 4510-4559 are accessible |
| State file conflicts | Use remote state (S3) in production to avoid local state file conflicts |

## 📚 Key Files Reference

- **[terraform.tfvars](terraform.tfvars)** - Environment-specific variable values
- **[variables.tf](variables.tf)** - Input variable definitions
- **[outputs.tf](outputs.tf)** - Infrastructure output values
- **[modules/vpc/](modules/vpc/)** - Reusable VPC module
- **[modules/ec2/](modules/ec2/)** - Reusable EC2 module

## 🤝 Contributing

Contributions are welcome. Please ensure:
1. All Terraform files are formatted with `terraform fmt`
2. Run `terraform validate` before committing
3. Update documentation for any new resources or variables

## 📝 License

This project is provided as-is for educational and development purposes.

---

**Last Updated:** April 2026
