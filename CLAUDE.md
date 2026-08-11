# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Terraform config deploying Red Hat OpenShift Service on AWS (ROSA) with Hosted Control Plane (HCP). Uses `terraform-redhat/rosa-hcp/rhcs` module and `terraform-aws-modules/vpc/aws`. Region: `ap-northeast-1`. Credentials live in `.env` (sourced before any terraform command).

## Commands

```bash
source .env && terraform init      # initialize providers/modules
source .env && terraform plan      # preview changes
source .env && terraform apply     # deploy (~30-40 min for cluster creation)
source .env && terraform destroy   # tear down all resources
terraform fmt                      # format .tf files
terraform validate                 # syntax/config validation
```

## Cross-File Relationships

**Two AZ variables** — `availability_zones` controls VPC subnet creation (vpc.tf), `cluster_availability_zones` controls cluster placement (main.tf). Cluster AZs are immutable after creation; VPC AZs are not.

**Subnet-to-pool wiring** — VPC creates one private subnet per AZ in `availability_zones`. Machine pools in main.tf reference these by index. Adding a pool in a new AZ requires: (1) add AZ to `availability_zones`, (2) reference the new `private_subnets[N]` index in the pool's `subnet_id`. Read main.tf for current pool-to-subnet assignments.

**`compute_machine_type`** — variable exists in variables.tf but is not passed to the module. Dead code. Instance types are set per-pool in `machine_pools` in main.tf.

## Key Constraints

- `cluster_name` max 15 characters. STS/OIDC roles are prefixed with it — renaming recreates all IAM roles.
- `aws_billing_account_id` hardcoded in main.tf — must match AWS account linked to Red Hat org in AWS Marketplace. Empty string `""` causes marketplace API error; use `null` for auto-detect or provide explicit ID.
- Instance types must be available in target region AND specific AZ (e.g. `p5.48xlarge` only in certain AZs of `ap-northeast-1`).
- ROSA must be enabled in AWS Marketplace before first deploy.
- GPU/large instance pools may show 0/N replicas for extended periods while waiting for capacity — this is normal, not an error.

## Sensitive Files

- `.env` — AWS credentials and RHCS token (gitignored)
- `terraform.tfvars` — real config values (gitignored)
- `terraform.tfstate` / `terraform.tfstate.backup` — state files (gitignored)
- `policy.json` / `trust-policy.json` — IAM policies for Loki logging (S3 access + OIDC federation), not managed by Terraform
