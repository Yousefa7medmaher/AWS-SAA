# AWS Solutions Architect Associate (SAA) — Hands-on Labs (Documentation)

This repository contains a set of hands-on AWS labs implemented with Terraform. Each top-level folder is a focused lab demonstrating an AWS architecture pattern (networking, compute, serverless, monitoring, etc.). This README documents each folder, the design artifacts included, key Terraform entry files, and short usage notes. No future tasks or TODOs are listed — this file is documentation-only.

---

## Top-level folders (summary table)

| Folder | Purpose / Design | Key files | Design image(s) |
|---|---:|---|---|
| AWS Highly Available Network Lab | Highly available VPC network design: VPC, public & private subnets, IGW, NAT gateways, route tables across 2 AZs | terraform/main.tf, terraform/variables.tf, terraform/outputs.tf, README.md | `AWS Highly Available Network Lab/deisgn.png` |
| AWS_ECS_Fargate | ECS Fargate web app behind an Application Load Balancer; CloudWatch logging | main.tf, variables.tf, outputs.tf, terraform.tfvars, README.md, web-app/ | `AWS_ECS_Fargate/design.png`, `health-metrics.png`, `logs.png` |
| CloudWatch | Monitoring examples: metrics, dashboards, alarms and related Terraform | README.md, terraform/ (Terraform configs and dashboard definitions) | `CloudWatch/design.png` |
| EC2-Autoscaling | EC2 Auto Scaling architecture lab including launch configuration/ASG and load balancing | README.md, terraform/ (Terraform configs) | `EC2-Autoscaling/design.png` |
| s3-cloudFront | Secure static website hosting with S3 and CloudFront configuration | README.md, terraform/ (S3, CloudFront config), images | `s3-cloudFront/Web App Reference Architecture.png`, `Done.png`, `Status.png` |
| lambda-project | Serverless thumbnail generator (Lambda functions, Lambda Layers, S3 triggers) | main.tf, variables.tf, outputs.tf, terraform.tfvars, README.md, lambda/ | `lambda-project/design.png` |
| S3-CRR | S3 Cross-Region Replication patterns and Terraform examples | (check folder for Terraform files and README) | (look inside folder for images if present) |
| VPC-Endpoints | Interface and Gateway VPC endpoints patterns and Terraform examples | README.md, terraform/ (endpoint configs) | `VPC-Endpoints/Interface-endpoint.png`, `Gateway-endpoint.png` |
| VPC-FlowLog | VPC Flow Logs pattern: delivering flow logs to CloudWatch/ S3, capture & analysis | README.md, terraform/ (flow log setup) | `VPC-FlowLog/design.png` |
| transit-gateway | Transit Gateway multi-VPC connectivity example with Terraform | README.md, terraform/ (TGW, attachments) | `transit-gateway/design.png` |
| vpc-peering | VPC Peering topology examples, routing, and cross-VPC access configuration | README.md, terraform/ (peering connections, route updates) | `vpc-peering/design.png` |
| Manara-Project-1 | User project directory (contains a project — inspect files for details) | (open folder to view files) | (designs/images if present inside) |
| README.md (this file) | Top-level documentation and per-folder reference | — | — |

---

## Per-folder documentation (detailed)

Below are brief notes and the important files to inspect in each folder. For Terraform-based labs, the usual entry points are `main.tf`, `variables.tf`, `outputs.tf` and optional `terraform.tfvars`.

- AWS Highly Available Network Lab
  - Purpose: Build a highly available VPC across 2 AZs with public & private subnets, Internet Gateway, NAT Gateways, route tables and tagging conventions.
  - Relevant files:
    - terraform/main.tf — provider, VPC, subnets, IGW, NAT Gateways, route tables, route associations.
    - terraform/variables.tf — aws_region, vpc_cidr.
    - terraform/outputs.tf — vpc_id, subnet IDs, igw id, nat gateway ids.
  - Design image: `AWS Highly Available Network Lab/deisgn.png`
  - Notes: Provider constraint in main.tf uses hashicorp/aws ~> 6.0. Outputs expose core networking IDs.

- AWS_ECS_Fargate
  - Purpose: Deploy containerized web application to ECS Fargate with an ALB and CloudWatch logging.
  - Relevant files:
    - main.tf — VPC, subnets, IGW, security group, IAM roles, CloudWatch log group, ECS cluster, ALB, task definition, service.
    - variables.tf, terraform.tfvars — input values (container image, CPU/memory, counts).
    - outputs.tf — useful outputs such as ALB DNS.
  - Images: `AWS_ECS_Fargate/design.png`, `health-metrics.png`, `logs.png`
  - Notes: main.tf uses hashicorp/aws ~> 5.0 and requires Terraform >= 1.5.0 per file header. The container image referenced is `yousef2005/web-app:v1` (Docker Hub). CloudWatch logs are configured; retention is parameterized.

- CloudWatch
  - Purpose: Centralized monitoring, dashboards, alerts, and metrics collection examples.
  - Relevant files: README.md plus Terraform configurations under `terraform/` (dashboards, alarms, metric filters).
  - Design image: `CloudWatch/design.png`
  - Notes: Inspect dashboard definitions and retained metrics to set appropriate retention and alarm thresholds.

- EC2-Autoscaling
  - Purpose: Auto Scaling demonstration using launch configuration/launch templates, ASG, and an optional load balancer.
  - Relevant files: README.md and Terraform under `terraform/`.
  - Design image: `EC2-Autoscaling/design.png`
  - Notes: Check for AMI references, instance types, and autoscaling policies (scale on CPU, target tracking, or scheduled).

- s3-cloudFront
  - Purpose: Host a static website in S3 fronted by CloudFront (secure origin access, caching, and distribution settings).
  - Relevant files: README.md and `terraform/` directory.
  - Images: `s3-cloudFront/Web App Reference Architecture.png`, `Done.png`, `Status.png`
  - Notes: Validate S3 bucket policies and CloudFront origin access configurations before deploying.

- lambda-project
  - Purpose: Serverless image thumbnail generator using S3 event triggers and Lambda Layers.
  - Relevant files:
    - main.tf — Lambda function, IAM role/policy, S3 trigger, Layer usage.
    - variables.tf, outputs.tf, terraform.tfvars
    - lambda/ — the function source (inspect for runtime and dependencies)
  - Image: `lambda-project/design.png`
  - Notes: Confirm runtime (e.g., python/node) and check Lambda layer packaging and permissions.

- S3-CRR
  - Purpose: Examples of S3 Cross-Region Replication (CRR) configuration for disaster recovery / compliance.
  - Relevant files: Check `S3-CRR/` for Terraform manifests and README.
  - Notes: Inspect source and destination bucket settings, replication role, and KMS keys if used.

- VPC-Endpoints
  - Purpose: Demonstrate Gateway and Interface endpoints for private connectivity to AWS services from within VPCs.
  - Relevant files: README.md and Terraform under `terraform/`.
  - Images: `VPC-Endpoints/Interface-endpoint.png`, `VPC-Endpoints/Gateway-endpoint.png`
  - Notes: Review endpoint policies and route table associations.

- VPC-FlowLog
  - Purpose: Capture and analyze VPC traffic flows (Flow Logs to CloudWatch or S3).
  - Relevant files: README.md and `terraform/`.
  - Image: `VPC-FlowLog/design.png`
  - Notes: Confirm the destination (CW Logs group or S3), IAM role permissions, and retention.

- transit-gateway
  - Purpose: Transit Gateway multi-VPC architecture for centralized connectivity across accounts/VPCs.
  - Relevant files: README.md and `terraform/`.
  - Image: `transit-gateway/design.png`
  - Notes: Inspect TGW attachments, route propagation and propagation/association configurations.

- vpc-peering
  - Purpose: VPC Peering topology examples, routing, and cross-VPC access configuration.
  - Relevant files: README.md and `terraform/`.
  - Image: `vpc-peering/design.png`
  - Notes: Peering configuration is region-sensitive; check CIDR non-overlap requirements.

- Manara-Project-1
  - Purpose: User project folder — contents vary. Inspect the folder for its README and Terraform assets.
  - Notes: Open the folder to determine specifics.

---

## Standard usage pattern (per lab)
Most labs follow this common workflow. Replace paths and variables per lab README.

1. Inspect the lab folder and read its README and `variables.tf` to learn required inputs and provider constraints.
2. Initialize Terraform:
```bash
cd <lab-folder>
terraform init
```
3. Plan and apply:
```bash
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```
4. Inspect outputs (example):
```bash
terraform output
```
5. Destroy resources when finished:
```bash
terraform destroy
```

Notes:
- Always review each lab’s `main.tf` header for required provider versions and Terraform required_version.
- Some labs include `terraform.tfvars` with sample values. Do not commit secrets into tfvars.

---

## Provider and Terraform notes (global)
- Provider versions vary across labs:
  - AWS Highly Available Network Lab uses hashicorp/aws ~> 6.0.
  - AWS_ECS_Fargate main.tf lists hashicorp/aws ~> 5.0 and requires Terraform >= 1.5.0.
- Before running any lab, confirm `terraform --version` and, if needed, use tfenv or a constrained Terraform binary to match the lab.
- Tagging: many labs add tags (Project, Environment, Name) to resources — useful for billing and resource discovery.

---

## Cost, security, and cleanup guidance
- Cost-sensitive resources created by these labs: ALB, Fargate tasks, NAT Gateways, EC2 instances, RDS (if added), and data transfer.
- Clean up with `terraform destroy` or remove resources via AWS Console.
- Security:
  - Review IAM roles and policies created by each lab and apply least-privilege adjustments as needed.
  - Verify Security Group and NACL rules before applying in a shared environment.
  - For production-like deployments, replace public Docker Hub images with private ECR images and use HTTPS (ACM + ALB listener on 443).

---

## Where to find designs and diagrams
Design artifacts and diagrams are included inside each lab folder (PNG files referenced in the table above). Open the folder to view the architecture diagrams that accompany the Terraform code and README descriptions.

---

## Author
Yousef Ahmed Maher — Cloud & DevOps Engineer  
GitHub: https://github.com/Yousefa7medmaher

---
