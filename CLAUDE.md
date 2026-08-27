# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Terraform deploying Red Hat OpenShift Service on AWS (ROSA) with Hosted Control Plane (HCP), via the `terraform-redhat/rosa-hcp/rhcs` and `terraform-aws-modules/vpc/aws` modules.

**The repo is public.** Real account IDs, bucket names, and OIDC provider IDs stay in gitignored files; tracked files carry placeholders. See Secrets below before committing.

## Commands

Every terraform command needs credentials from `.env`:

```bash
source .env && terraform plan
source .env && terraform apply     # ~20-40 min on cluster creation
```

`terraform fmt` and `terraform validate` need no credentials.

## Secrets

Real values live only in gitignored files — `.env` (AWS keys, `RHCS_TOKEN`), `terraform.tfvars` (including `aws_billing_account_id`), and `terraform.tfstate*`.

Tracked files carry placeholders: `terraform.tfvars.example` uses AWS's documented example account `123456789012`; `loki/*.json` use `<AWS_ACCOUNT_ID>`, `<OIDC_PROVIDER>`, `<LOKI_BUCKET>`.

`loki/` holds optional hand-applied IAM policies for LokiStack logging — outside Terraform, applied only if you deploy Loki. See `loki/README.md`; resolve its placeholders into `/tmp` copies rather than into the repo.

Before any commit, confirm tracked files hold no real identifiers:

```bash
git ls-files | xargs grep -nE '[0-9]{12}|AKIA|arn:aws:iam'
```

Every match should be a placeholder — `123456789012`, `<AWS_ACCOUNT_ID>`, or this file's own description of them. A real 12-digit account, an `AKIA` key, or a resolved ARN means something needs redacting before commit.

## Cross-File Relationships

**Two AZ variables** — `availability_zones` drives VPC subnet creation (vpc.tf); `cluster_availability_zones` drives cluster placement (main.tf). Cluster AZs are immutable after creation; VPC AZs are not.

**Subnet-to-pool wiring** — the VPC creates one private subnet per AZ in `availability_zones`, and `machine_pools` in main.tf binds each pool to one by index. A pool in a new AZ needs both halves: add the AZ to `availability_zones`, then point the pool's `subnet_id` at the new `private_subnets[N]`. Read main.tf for current assignments.

**`compute_machine_type`** — declared in variables.tf, never passed to the module. Dead. Instance types come from `machine_pools` in main.tf.

## Key Constraints

- `cluster_name` max 15 characters, and it prefixes every STS/OIDC role — renaming recreates all IAM roles.
- `aws_billing_account_id` must match the AWS account linked to the Red Hat org in AWS Marketplace. Use an explicit ID or `null` to auto-detect; the empty string `""` raises a marketplace API error.
- Instance types must exist in the target region *and* the pool's specific AZ — GPU types like `p5.4xlarge` are in only some AZs of `ap-northeast-1`.
- Enable ROSA in AWS Marketplace before the first deploy.

## Reading a Plan Against a Live Cluster

A live cluster makes `terraform plan` show pending changes that no local edit caused. Attribute the diff before applying:

- **Subnet tags** — ROSA adds `kubernetes.io/cluster/<id> = shared` to subnets out-of-band. The VPC module doesn't know them and plans to strip them. Applying that can disrupt cluster networking; leave these alone.
- **`current_version` climbing** — the provider resolves to the latest z-stream, so the plan proposes an upgrade past the pinned `openshift_version`. Applying upgrades the cluster.
- **`replicas = 0 -> N`** — the pool has no capacity yet, not a config error. GPU and other large types sit at 0/N for long stretches in `ap-northeast-1`; `rosa list machinepools --cluster=<name>` shows current vs desired.

Confirm a refactor is drift-free by checking the plan touches none of the attributes you edited.
