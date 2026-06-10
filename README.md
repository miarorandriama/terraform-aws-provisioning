# 🚀 AWS Infrastructure as Code with Terraform & LocalStack

## 📌 Project Overview

This project demonstrates the design and deployment of a **modular** and **scalable** AWS cloud infrastructure using **Terraform** and **LocalStack**. It provides a complete, isolated local development environment that mirrors production configurations, enabling validation of networking, IAM, and security configurations before real AWS deployments.

## 🏗️ Architecture

The infrastructure is fully modularized and includes:

- **VPC** — Isolated virtual network with subnet segmentation
- **Subnets** — Public subnet (internet access) and private subnet (isolated)
- **Internet Gateway** — Routing configuration for web access
- **EC2 Instance** — Web server provisioned in private subnet with IAM role
- **IAM Role + Instance Profile** — EC2 permissions scoped to S3 access
- **Security Groups** — Firewall rules allowing SSH (22), HTTP (80), HTTPS (443)
- **S3 Buckets** — Application data storage + Terraform remote state bucket

## 📁 Project Structure

```
AWS_TF/
├── Keys/                          # AWS credentials
└── Terraform/
    ├── main.tf                   # Root module — wires all modules together
    ├── variables.tf              # Variable definitions
    ├── terraform.tfvars          # Variable values
    ├── providers.tf              # Provider configuration
    ├── outputs.tf                # Output values
    ├── validate_infra.sh         # Legacy validation script
    └── modules/
        ├── vpc/                  # VPC module
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── ec2/                  # EC2 module (with IAM role & instance profile)
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── s3/                   # S3 module
            ├── main.tf
            ├── outputs.tf
            └── variables.tf

scripts/
├── 001_test_vpc.sh               # VPC, subnet & internet gateway audit
├── 002_test_s3.sh                # S3 compliance audit (versioning, encryption, tags)
├── 003_test_ec2.sh               # EC2 compliance audit (IAM, security groups, tags)
└── 004_test_integration_ec2_s3.sh # Integration test: EC2 ↔ S3 file transfer
```

## 🛠️ DevOps Best Practices

- **Infrastructure as Code (IaC)** — Complete infrastructure in version-controlled Terraform files
- **Modularity** — Logical separation of resources (VPC, EC2, S3) for maximum reusability
- **Dynamic Tagging** — Centralized tag management using `merge()` for cost tracking and FinOps
- **Strict Variable Management** — Clean separation between variable definitions and values
- **IAM Least Privilege** — EC2 role scoped to S3 access only
- **Dependency Management** — Explicit `depends_on` chain ensuring IAM policy attachment completes before instance profile is used
- **Automated Compliance Testing** — Shell scripts auditing infrastructure state after every deployment
- **Local Cloud Simulation** — LocalStack eliminates development costs while mirroring AWS services

## 📋 Prerequisites

- Docker & Docker Desktop
- Terraform >= 1.10.5
- AWS CLI v2
- `jq` (required by test scripts)
- Basic knowledge of AWS and Terraform

## 🚀 Installation & Deployment

### Step 1 — Launch LocalStack

> ⚠️ **Critical:** Since 2026, `localstack/localstack:latest` is actually the **Pro version** and requires a paid license (exits with code 55). Always use a pinned free version:

```powershell
docker run -d --name localstack \
  -p 4566:4566 \
  -p 4510-4559:4510-4559 \
  -e IAM_SOFT_MODE=1 \
  localstack/localstack:3.8.0
```

### Step 2 — Configure AWS Credentials

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

### Step 3 — Initialize Terraform

```bash
cd Terraform
terraform init
```

### Step 4 — Review the Plan

```bash
terraform plan
```

### Step 5 — Deploy

```bash
terraform apply -auto-approve
```

## 🧪 Testing & Validation

After a successful `terraform apply`, run the audit scripts in order:

```bash
# 1. Network audit — VPC, subnets, internet gateway
bash scripts/001_test_vpc.sh

# 2. S3 compliance audit — versioning, encryption, public access block, tags
bash scripts/002_test_s3.sh

# 3. EC2 compliance audit — IAM profile, security groups, tags
bash scripts/003_test_ec2.sh

# 4. Integration test — EC2 ↔ S3 file transfer simulation
bash scripts/004_test_integration_ec2_s3.sh
```

Each script outputs color-coded results: `[OK]` / `[CONFORME]` in green, errors in red.

## 🔍 Manual Verification

```bash
# List VPCs
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs --output table

# List EC2 instances
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,Tags:Tags}" \
  --output table

# List IAM instance profiles
aws --endpoint-url=http://localhost:4566 iam list-instance-profiles --output table

# List S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls
```

## 🧹 Cleanup

```bash
terraform destroy -auto-approve
docker stop localstack && docker rm localstack
```

## 💡 Troubleshooting & Lessons Learned

| Issue | Root Cause | Solution |
|---|---|---|
| EC2 cannot find instance profile | `aws_iam_instance_profile` was created before `aws_iam_role_policy_attachment` completed | Added `depends_on = [aws_iam_role_policy_attachment.the_s3_access]` on the instance profile |
| `depends_on` and `time_sleep` don't fix the error | LocalStack Pro enforces strict IAM validation — profile exists but role has no policy yet | Fix the dependency chain AND use free LocalStack image |
| LocalStack exits with code 55 | `localstack:latest` is actually the Pro image since 2026 — requires a paid license token | Use `localstack/localstack:3.8.0` with `-e IAM_SOFT_MODE=1` |
| AWS CLI segfault errors | Profile-based auth not supported in LocalStack | Use `--endpoint-url=http://localhost:4566` on every AWS CLI command |
| Variable scope in modules | Variables not passed between modules | Use module outputs as inputs in root `main.tf` |
| State file conflicts | Local state in team environments | Use remote state (S3 backend) in production |

## 📚 Key Files Reference

| File | Purpose |
|---|---|
| `main.tf` | Root module — connects all sub-modules |
| `variables.tf` | Input variable definitions |
| `outputs.tf` | Infrastructure output values |
| `modules/ec2/main.tf` | EC2 instance + IAM role + instance profile + security group |
| `modules/vpc/main.tf` | VPC, subnets, internet gateway, route tables |
| `modules/s3/main.tf` | S3 bucket with versioning and encryption |
| `scripts/001_test_vpc.sh` | VPC/subnet/IGW audit |
| `scripts/002_test_s3.sh` | S3 compliance checks |
| `scripts/003_test_ec2.sh` | EC2/IAM/SG audit |
| `scripts/004_test_integration_ec2_s3.sh` | End-to-end EC2↔S3 integration test |

## 🤝 Contributing

Contributions are welcome. Please ensure:

1. All Terraform files are formatted with `terraform fmt`
2. Run `terraform validate` before committing
3. Run all 4 test scripts and verify green output before opening a PR
4. Update documentation for any new resources or variables

## 📝 License

This project is provided as-is for educational and development purposes.

---

**Last Updated:** June 2026
