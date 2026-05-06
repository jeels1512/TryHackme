# Cloud-based IaC

> **Room:** [https://tryhackme.com/room/cloudbasediac](https://tryhackme.com/room/cloudbasediac)
> **Module:** 5 — Infrastructure as Code
> **Difficulty:** Medium

## Overview

The final room of the path. This one covers IaC for cloud providers — primarily **Terraform** (multi-cloud), **AWS CloudFormation**, **Azure Bicep / ARM templates**, **Google Deployment Manager**, **Pulumi**, and **AWS CDK**. It also covers cloud-specific security: state files, IAM, scanning IaC for misconfigurations (Checkov, tfsec), and policy-as-code (OPA, Sentinel).

The big themes: **state matters**, **IAM is the new perimeter**, and **a misconfigured S3 bucket is one `terraform apply` away from a breach**.

---

## Key Concepts

### Cloud IaC tools — landscape

| Tool | Scope | Language | Notes |
|---|---|---|---|
| **Terraform** | Multi-cloud | HCL | The de facto standard. Provider model. |
| **OpenTofu** | Multi-cloud | HCL | Open-source fork of Terraform |
| **Pulumi** | Multi-cloud | Real languages (TS, Python, Go, C#) | Code, not config |
| **AWS CloudFormation** | AWS only | YAML / JSON | Native AWS, deep integration |
| **AWS CDK** | AWS (mostly) | TS, Python, Java, Go | Compiles to CloudFormation |
| **Azure Bicep** | Azure only | Bicep DSL | Cleaner than ARM JSON |
| **Azure ARM** | Azure only | JSON | Verbose, legacy-ish |
| **GCP Deployment Manager** | GCP only | YAML + Jinja/Python | Less popular than Terraform on GCP |
| **Crossplane** | Multi-cloud via K8s | YAML CRDs | Manage cloud from Kubernetes |

For most teams in 2026, **Terraform / OpenTofu** is the default. Cloud-native tools are good when you're locked into one provider and want their best support.

---

### Terraform deep dive

#### Project structure

```
project/
├── main.tf          # primary resources
├── variables.tf     # input variables
├── outputs.tf       # output values
├── providers.tf     # provider config
├── versions.tf      # required Terraform / provider versions
├── terraform.tfvars # actual variable values (often gitignored if sensitive)
└── modules/
    └── vpc/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

#### A simple AWS example

```hcl
# providers.tf
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "my-tf-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-locks"
  }
}

provider "aws" {
  region = var.region
}

# variables.tf
variable "region"      { default = "us-east-1" }
variable "environment" { default = "prod" }

# main.tf
resource "aws_s3_bucket" "logs" {
  bucket = "myapp-${var.environment}-logs"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.logs.id
}
```

#### The Terraform workflow

```bash
terraform init       # download providers, configure backend
terraform fmt        # format code
terraform validate   # syntax check
terraform plan       # show what would change
terraform apply      # apply changes (after confirmation)
terraform destroy    # tear it all down
terraform state list # see what's tracked
```

#### State files — the most important security topic

The `terraform.tfstate` file is **the source of truth** for what Terraform manages. It contains:

- All resource IDs.
- All resource attributes.
- **All sensitive values in plaintext** — including DB passwords, API keys, secrets that you read in via `random_password` or `aws_db_instance.password`.

**Rules:**
- ❌ Never commit `terraform.tfstate` to Git.
- ❌ Never store it on a developer laptop for shared infra.
- ✅ Use a remote backend (S3, GCS, Azure Blob, Terraform Cloud).
- ✅ Enable backend encryption (S3 SSE, GCS CMEK).
- ✅ Enable backend versioning so you can roll back.
- ✅ Enable state locking (DynamoDB for S3, native lock for others) so two people can't `apply` simultaneously.
- ✅ Restrict who can read the state bucket — IAM least privilege.

```hcl
backend "s3" {
  bucket         = "my-tf-state"
  key            = "prod/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true                  # SSE-S3
  kms_key_id     = "alias/tf-state"      # SSE-KMS for stronger control
  dynamodb_table = "tf-locks"            # state locking
}
```

#### Modules

Modules are reusable bundles of Terraform.

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  name = "prod-vpc"
  cidr = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
```

**Security note:** Modules from the public registry run on your AWS account. Vet them. Pin versions. Mirror to a private registry if you can.

---

### Cloud IaC misconfigurations — the OWASP-equivalent

The big classes of cloud IaC vulnerabilities, from real-world breaches:

| Class | Example |
|---|---|
| **Public storage** | S3 bucket without `public_access_block`, GCS bucket with `allUsers` reader |
| **Open security groups** | `0.0.0.0/0` on port 22 or 3389 |
| **Unencrypted resources** | RDS without `storage_encrypted = true`, EBS volumes without encryption |
| **Excessive IAM** | `"Action": "*"`, `"Resource": "*"` |
| **Missing logging** | No CloudTrail, no VPC flow logs, no S3 access logging |
| **Hardcoded secrets** | DB password in `.tf` files, API keys in `user_data` |
| **No MFA / weak auth** | Root account without MFA, IAM users with console access only |
| **Default VPC use** | Resources in default VPC instead of custom |
| **Public databases** | RDS / DocumentDB with `publicly_accessible = true` |

#### Real example — bad vs good

```hcl
# BAD — public bucket, no encryption, no logging
resource "aws_s3_bucket" "data" {
  bucket = "myapp-data"
  acl    = "public-read"
}

# GOOD
resource "aws_s3_bucket" "data" {
  bucket = "myapp-data"
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "data" {
  bucket        = aws_s3_bucket.data.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "data/"
}
```

---

### IaC scanning tools

You should never deploy IaC without scanning it first. Tools to know:

| Tool | Notes |
|---|---|
| **Checkov** | Bridgecrew/Prisma. Multi-IaC, ~1000+ checks. |
| **tfsec** | Terraform-specific. Now part of Trivy. Fast. |
| **Trivy** | Aquasec. Scans IaC, containers, dependencies — one tool. |
| **Terrascan** | Tenable. OPA-based. |
| **KICS** | Checkmarx. Wide IaC support. |
| **Snyk IaC** | Commercial. Strong UI, ticketing integrations. |

```bash
# Checkov
checkov -d ./terraform/

# Trivy
trivy config ./terraform/

# tfsec
tfsec ./terraform/

# CI integration (GitHub Actions)
- name: Checkov
  uses: bridgecrewio/checkov-action@master
  with:
    directory: ./terraform/
    framework: terraform
    soft_fail: false   # break the build on findings
```

---

### Policy as Code

Scanning catches misconfigurations. **Policy as Code** stops them from being applied.

#### Open Policy Agent (OPA) + Conftest

```rego
# policy.rego
package terraform

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  resource.change.after.acl == "public-read"
  msg := sprintf("S3 bucket '%s' is public", [resource.address])
}
```

```bash
terraform plan -out tfplan
terraform show -json tfplan > plan.json
conftest test plan.json --policy policy.rego
```

#### HashiCorp Sentinel

Terraform Cloud/Enterprise feature. Sentinel policies run between `plan` and `apply`. Can be **advisory**, **soft-mandatory** (requires override), or **hard-mandatory** (blocking).

#### Cloud-native: AWS SCPs, Azure Policy, GCP Org Policy

These run at the cloud account level, not the IaC level. Belt and braces — IaC scan + cloud policy = layered defense.

---

### Secrets in cloud IaC

**Never** put secrets in Terraform files.

```hcl
# BAD
resource "aws_db_instance" "db" {
  password = "Sup3rS3cret!"
}

# GOOD — pull from secrets manager at apply time
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod/db/master"
}

resource "aws_db_instance" "db" {
  password = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["password"]
}
```

Or use:
- **AWS Secrets Manager** / **SSM Parameter Store**
- **Azure Key Vault**
- **GCP Secret Manager**
- **HashiCorp Vault** (cloud-agnostic)

Even with this, the secret ends up **in the state file**. Mitigations:
- Encrypt the state at rest with KMS.
- Restrict access to the state.
- Use Terraform Cloud's encrypted state, or external state managers like **Atlantis**.

---

### IAM — the new perimeter

In the cloud, IAM is the most-attacked layer. IaC can lock it down or blow it open.

```hcl
# BAD — everyone can do everything
resource "aws_iam_policy" "bad" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}

# GOOD — least privilege, scoped resources
resource "aws_iam_policy" "good" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject"]
      Resource = "arn:aws:s3:::myapp-data/uploads/*"
    }]
  })
}
```

**Tools to help:**
- `aws-iam-policy-generator`
- `iamlive` — captures the API calls your app actually makes, generates a policy.
- AWS IAM Access Analyzer — flags overly broad policies.

---

### CI/CD pipeline for cloud IaC

A solid pipeline looks like:

```
┌───────────┐   ┌─────────────┐   ┌──────────┐   ┌───────────┐   ┌──────────┐
│  fmt      │ → │  validate   │ → │  scan    │ → │  plan     │ → │  apply   │
│ (lint)    │   │ (syntax)    │   │ (Checkov,│   │ (review)  │   │ (manual  │
│           │   │             │   │  tfsec)  │   │           │   │  approve)│
└───────────┘   └─────────────┘   └──────────┘   └───────────┘   └──────────┘
```

**Key controls:**
- Plan output posted as a PR comment (Atlantis, Spacelift, Terraform Cloud).
- Apply only after manual approval.
- Apply runs from CI with short-lived OIDC creds — no long-lived AWS keys.
- All applies logged to an immutable audit log.

```yaml
# GitHub Actions OIDC to AWS — no static keys
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/terraform-ci
    aws-region: us-east-1
```

---

## Room answers

> Answers may vary as TryHackMe updates the room. Try the room first.

**Task 1 — Introduction**
- *No answer required.*

**Task 2 — Cloud IaC tools**
- Q: Which open-source tool became the de-facto multi-cloud IaC standard? → **Terraform**
- Q: Which AWS-native IaC service uses YAML or JSON templates? → **CloudFormation**
- Q: Which Azure DSL replaces verbose ARM JSON? → **Bicep**

**Task 3 — Terraform fundamentals**
- Q: Which command initializes a Terraform project? → **terraform init**
- Q: Which file stores the current view of managed resources? → **terraform.tfstate** (the state file)
- Q: Which command shows planned changes without applying them? → **terraform plan**

**Task 4 — IaC security scanning**
- Q: Which tool by Bridgecrew scans Terraform for misconfigurations? → **Checkov**
- Q: Which tool by Aquasec is a one-stop scanner for IaC, containers, and dependencies? → **Trivy**
- Q: Which framework lets you write policies in Rego to enforce on Terraform plans? → **Open Policy Agent** (OPA)

**Task 5 — Hands-on misconfiguration**
- Q: After scanning the provided Terraform with Checkov, what is the ID of the failed check for public S3 buckets? → *(varies — typically `CKV_AWS_53` "Ensure S3 bucket has block public ACLs enabled" or `CKV_AWS_54` for block public policy)*
- Q: After fixing the issues, what is the flag? → *(found in `/root/flag.txt` or similar after a successful apply)*

**Task 6 — Conclusion**
- *No answer required.*

---

## Cheatsheet

```bash
# --- Terraform daily commands ---
terraform init                                  # set up project, download providers
terraform init -upgrade                         # upgrade provider versions
terraform init -reconfigure                     # change backend
terraform fmt -recursive                        # format all .tf files
terraform validate                              # syntax check
terraform plan                                  # see what would change
terraform plan -out=tfplan                      # save plan to file
terraform apply tfplan                          # apply saved plan
terraform apply -auto-approve                   # skip confirmation (CI)
terraform destroy                               # tear it all down
terraform output                                # show outputs
terraform output -json                          # outputs as JSON

# --- State management ---
terraform state list                            # all resources in state
terraform state show aws_s3_bucket.logs         # show one resource
terraform state mv old new                      # rename in state
terraform state rm aws_s3_bucket.logs           # remove from state (doesn't destroy)
terraform import aws_s3_bucket.logs my-bucket   # import existing resource
terraform refresh                               # sync state with reality
terraform force-unlock <LOCK_ID>                # break a stuck lock

# --- Workspaces (lightweight env separation) ---
terraform workspace list
terraform workspace new staging
terraform workspace select prod

# --- IaC scanning ---
checkov -d .                                    # scan Terraform
checkov -d . --framework terraform              # explicit framework
checkov -d . --skip-check CKV_AWS_8             # skip a check
trivy config .                                  # scan config files
trivy config . --severity HIGH,CRITICAL
tfsec .
terrascan scan -i terraform

# --- OPA / Conftest ---
terraform plan -out tfplan
terraform show -json tfplan > plan.json
conftest test plan.json --policy policies/

# --- AWS-specific helpful CLI ---
aws sts get-caller-identity                     # who am I?
aws s3api get-bucket-policy --bucket mybucket
aws iam simulate-principal-policy ...           # simulate IAM
aws accessanalyzer list-findings ...

# --- CloudFormation basics ---
aws cloudformation deploy --template-file t.yml --stack-name myapp
aws cloudformation describe-stacks --stack-name myapp
aws cloudformation delete-stack --stack-name myapp

# --- Bicep / ARM ---
az deployment group create --resource-group rg --template-file main.bicep
az bicep build --file main.bicep                # compile to ARM JSON
```

---

## Key takeaways

- Terraform is the multi-cloud default; cloud-native tools (CFN, Bicep) are best when you're single-cloud and want deep integration.
- The **state file is sensitive** — encrypt it, lock it, restrict access, never commit it.
- Scan IaC in CI (Checkov, Trivy, tfsec) — every PR.
- Use Policy as Code (OPA, Sentinel) to **block** bad changes, not just warn.
- IAM is the cloud's new perimeter — least privilege, scoped resources, no `*:*`.
- Never put secrets in `.tf` files; pull from a secrets manager and accept that the state needs to be locked down.
- CI applies should use short-lived OIDC creds, not long-lived access keys.
- A misconfigured S3 bucket or open security group is one bad PR away — that's why scanning + policy + review is non-negotiable.

---

## 🎉 Path complete!

That's all 18 rooms across 5 modules. From DevSecOps fundamentals → pipeline security → in-pipeline scanning (SAST/DAST/SCA) → containers (Docker, K8s, hardening) → IaC (on-prem and cloud).

Next steps to keep learning:
- The **SOC Level 1** path on TryHackMe complements this with detection skills.
- Hands-on cloud security: **flaws.cloud**, **flaws2.cloud**, **CloudGoat**.
- Kubernetes attack/defense: **kube-goat**, **bust-a-kube**.
- Real CI/CD CTFs: **GitHub Actions Goat**, **OWASP Juice Shop with a real pipeline**.
