# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Terraform config deploying Red Hat OpenShift Service on AWS (ROSA) with Hosted Control Plane (HCP). Uses the `terraform-redhat/rosa-hcp/rhcs` module (v1.7.1) and `terraform-aws-modules/vpc/aws` (~>5.0).

## Commands

```bash
terraform init          # initialize providers/modules
terraform plan          # preview changes
terraform apply         # deploy (takes 30-40 min for cluster creation)
terraform destroy       # tear down all resources
terraform fmt           # format .tf files
terraform validate      # syntax/config validation
```

## Required Environment Variables

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="ap-northeast-1"
export RHCS_TOKEN="..."  # from https://console.redhat.com/openshift/token
```

## Architecture

- **vpc.tf** — VPC with public/private subnets across AZs, single NAT gateway. Subnets auto-calculated via `cidrsubnet()` from `vpc_cidr`.
- **main.tf** — ROSA HCP cluster module. Passes first private+public subnet to cluster. Machine pools defined inline in `machine_pools` block.
- **variables.tf** — Input variables. Note: `availability_zones` (VPC-level) and `cluster_availability_zones` (cluster-level) are separate — cluster AZs are immutable after creation.
- **versions.tf** — Provider config. AWS provider, RHCS provider (token via env var), random provider.
- **outputs.tf** — Exports cluster_id, vpc_id, subnet IDs.

## Key Constraints

- `cluster_name` max 15 characters
- `compute_machine_type` cannot change after cluster creation — use `machine_pools` for new instance types
- `cluster_availability_zones` immutable after creation
- `aws_billing_account_id` in main.tf must match the AWS account linked to Red Hat org in AWS Marketplace — do not use empty string `""` (causes marketplace API error); omit or set to `null` for auto-detect, or provide explicit account ID
- Instance types must be available in target region AND specific AZ (e.g. `p5.4xlarge` only in `ap-northeast-1c`)
- ROSA must be enabled in AWS Marketplace before first deploy

## Sensitive Files

- `terraform.tfvars` — real config values (gitignored)
- `terraform.tfstate` / `terraform.tfstate.backup` — state files (gitignored)
- `policy.json` / `trust-policy.json` — IAM policies for Loki logging (S3 access + OIDC federation), not managed by Terraform
