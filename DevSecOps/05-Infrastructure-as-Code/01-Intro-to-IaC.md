# Intro to IaC

> **Room:** [https://tryhackme.com/room/introtoiac](https://tryhackme.com/room/introtoiac)
> **Module:** 5 — Infrastructure as Code
> **Difficulty:** Easy

## Overview

The first room of the IaC module. Covers what Infrastructure as Code is, why it matters, declarative vs imperative styles, idempotency, push vs pull configuration, and the major IaC tools (Terraform, Ansible, Puppet, Chef, CloudFormation).

---

## Key Concepts

### What is IaC?

**Infrastructure as Code** = managing infrastructure (servers, networks, cloud resources) through machine-readable files, the same way you manage application code.

Instead of clicking through AWS console or SSHing in to install packages, you describe the desired state in a file, version-control it, and let a tool make it happen.

### Why IaC?

- **Reproducibility** — same code = same infra every time
- **Version control** — every change is tracked, reviewable, revertable
- **Speed** — spin up environments in minutes, not days
- **Documentation** — the code IS the documentation
- **Disaster recovery** — rebuild from code if needed
- **Consistency** — dev = staging = prod (no more "snowflake" servers)
- **Collaboration** — infra is reviewable in PRs

### Declarative vs Imperative

#### Declarative
You describe **what you want**. The tool figures out how to get there.

```hcl
# Terraform — declarative
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  tags = {
    Name = "WebServer"
  }
}
```

#### Imperative
You describe **how to do it** step by step.

```bash
# Bash — imperative
aws ec2 run-instances --image-id ami-0c55b159cbfafe1f0 --instance-type t3.micro
aws ec2 create-tags --resources i-12345 --tags Key=Name,Value=WebServer
```

Most modern IaC tools (Terraform, CloudFormation, Pulumi, Kubernetes manifests) are declarative. Some (Ansible) are mostly declarative but with imperative escape hatches.

### Idempotency

A core IaC concept: running the same code 10 times gives the same result as running it once. The tool checks current state vs desired state and only changes what needs changing.

If your "deployment" creates a new instance every time it runs, that's a bug. It should create once, then do nothing on subsequent runs.

### Push vs Pull configuration

#### Push model
A central machine **pushes** config to target machines.
- Examples: **Ansible**, **Salt** (push mode)
- Pros: simple, no agent needed
- Cons: central machine needs network access to all targets, scaling can be tricky

#### Pull model
Target machines **pull** their config from a central server.
- Examples: **Puppet**, **Chef**, **Salt** (pull mode)
- Pros: scales better, agents handle their own retries
- Cons: requires installing an agent on every machine

### IaC tool categories

#### 1. Provisioning tools
Create/manage cloud resources (VMs, networks, DBs, etc.).
- **Terraform** (HashiCorp, the de facto standard)
- **OpenTofu** (open-source fork of Terraform)
- **Pulumi** (uses real programming languages — Python, TS, Go)
- **AWS CloudFormation** (AWS-only)
- **Azure ARM / Bicep** (Azure-only)
- **Google Deployment Manager** (GCP-only)

#### 2. Configuration management
Configure already-provisioned servers (install packages, manage services, etc.).
- **Ansible** — agentless, push, YAML
- **Puppet** — agent-based, pull, custom DSL
- **Chef** — agent-based, pull, Ruby DSL
- **SaltStack** — agent or agentless, push or pull, YAML

You often **combine** them: Terraform provisions the VM, Ansible configures it.

#### 3. Container orchestration as code
- **Kubernetes manifests** (YAML)
- **Helm charts** (templated K8s manifests)
- **Kustomize**

#### 4. Policy as code
- **OPA / Rego** — define what configs are allowed
- **Sentinel** (HashiCorp)
- **Checkov, tfsec, Terrascan** — pre-flight scanners for IaC files

### IaC + CI/CD

The standard flow:
1. Developer modifies an IaC file
2. Opens a PR
3. CI runs `terraform plan` (or equivalent) and posts the diff to the PR
4. CI runs IaC security scanners (Checkov, tfsec)
5. Reviewer approves
6. On merge, CI runs `terraform apply`

This way every infra change is reviewed and audited.

### Common IaC security issues (preview)

(Goes deeper in next two rooms)

- Hardcoded secrets in IaC files
- Overly permissive IAM policies
- Public S3 buckets
- Open security groups (`0.0.0.0/0` to port 22)
- Unencrypted storage
- No logging enabled
- State files containing secrets, stored insecurely

### Example: same goal, different tools

#### Terraform (declarative)
```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "my-logs-bucket"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

#### Ansible (declarative-ish)
```yaml
- name: Create S3 bucket
  amazon.aws.s3_bucket:
    name: my-logs-bucket
    versioning: yes
    encryption: AES256
```

#### CloudFormation
```yaml
Resources:
  LogsBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-logs-bucket
      VersioningConfiguration:
        Status: Enabled
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
```

---

## Commands Cheatsheet

### Terraform

```bash
# Init the working dir (downloads providers)
terraform init

# See what would change
terraform plan
terraform plan -out=plan.tfplan

# Apply changes
terraform apply
terraform apply plan.tfplan

# Destroy everything
terraform destroy

# Format code
terraform fmt

# Validate syntax
terraform validate

# State management
terraform state list
terraform state show <resource>
terraform state rm <resource>

# Get outputs
terraform output
terraform output instance_ip
```

### Ansible

```bash
# Run a playbook
ansible-playbook playbook.yml

# With inventory file
ansible-playbook -i inventory.ini playbook.yml

# Dry-run (check mode)
ansible-playbook playbook.yml --check

# Limit to a host group
ansible-playbook playbook.yml --limit web

# Ad-hoc commands
ansible all -i inventory.ini -m ping
ansible web -i inventory.ini -m shell -a "uptime"

# Encrypted secrets
ansible-vault encrypt secrets.yml
ansible-vault edit secrets.yml
ansible-playbook playbook.yml --ask-vault-pass
```

### IaC scanners

```bash
# Checkov (open source, supports many tools)
pip install checkov
checkov -d ./terraform
checkov -d ./terraform --framework terraform
checkov -f main.tf

# tfsec (Terraform-focused)
brew install tfsec
tfsec ./terraform

# Terrascan
docker run --rm -v $(pwd):/iac tenable/terrascan scan -d /iac

# trivy can scan IaC too
trivy config ./terraform
```

---

## Room Answers

**Task 1 — Introduction**
- Read through.

**Task 2 — What is IaC?**
- Q: What does IaC stand for?
- A: `Infrastructure as Code`

**Task 3 — Declarative vs Imperative**
- Q: Which style describes the desired end-state?
- A: `Declarative`
- Q: Which style describes the steps to take?
- A: `Imperative`
- Q: Which is Terraform?
- A: `Declarative`

**Task 4 — Idempotency**
- Q: A property where running the same code multiple times produces the same result is called?
- A: `idempotency` (or `idempotent`)

**Task 5 — Push vs Pull**
- Q: Which model has the central server send config out to nodes?
- A: `Push`
- Q: Ansible uses which model by default?
- A: `Push`
- Q: Puppet uses which model?
- A: `Pull`

**Task 6 — Tools**
- Q: Which IaC tool is from HashiCorp and is the most popular for cloud provisioning?
- A: `Terraform`
- Q: Which tool is agentless and uses YAML playbooks?
- A: `Ansible`
- Q: AWS-native IaC service?
- A: `CloudFormation`
- Q: Azure-native IaC service?
- A: `ARM` (or `Bicep`)

**Task 7 — Conclusion**
- Click to complete.

---

## Key Takeaways

1. **IaC = infrastructure managed via code**, version-controlled, reviewable, automatable.
2. **Declarative** (Terraform, CloudFormation) = describe end state. **Imperative** = describe steps.
3. **Idempotency**: running the same code multiple times → same result.
4. **Push** (Ansible) vs **Pull** (Puppet, Chef) configuration management.
5. Tool families: **provisioning** (Terraform), **configuration** (Ansible), **orchestration** (K8s), **policy** (OPA).
