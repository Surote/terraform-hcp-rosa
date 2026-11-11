# ROSA HCP on AWS with Terraform

Deploy Red Hat OpenShift Service on AWS (ROSA) with Hosted Control Plane (HCP) using Terraform.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Region                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                        VPC                                │  │
│  │  ┌─────────────────────┐  ┌─────────────────────────────┐ │  │
│  │  │   Public Subnet     │  │      Private Subnet         │ │  │
│  │  │  ┌───────────────┐  │  │  ┌───────────────────────┐  │ │  │
│  │  │  │ NAT Gateway   │  │  │  │   ROSA HCP Cluster    │  │ │  │
│  │  │  └───────────────┘  │  │  │  ┌─────────────────┐  │  │ │  │
│  │  │  ┌───────────────┐  │  │  │  │  compute-pool   │  │  │ │  │
│  │  │  │ Internet GW   │  │  │  │  │  (c5.4xlarge)   │  │  │ │  │
│  │  │  └───────────────┘  │  │  │  │  2 replicas     │  │  │ │  │
│  │  └─────────────────────┘  │  │  └─────────────────┘  │  │ │  │
│  │                           │  │  ┌─────────────────┐  │  │ │  │
│  │                           │  │  │  gpu-pool-h100  │  │  │ │  │
│  │                           │  │  │  (p5.4xlarge)   │  │  │ │  │
│  │                           │  │  │  1 replica      │  │  │ │  │
│  │                           │  │  └─────────────────┘  │  │ │  │
│  │                           │  └───────────────────────┘  │ │  │
│  │                           └─────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Red Hat Account** with ROSA entitlement
3. **Enable ROSA on AWS Marketplace** (one-time setup)
   - Visit: https://console.aws.amazon.com/rosa/home
   - Click "Enable ROSA with HCP" and complete the subscription

## Quick Start

### 1. Clone the repository

```bash
git clone git@github.com:Surote/terraform-hcp-rosa.git
cd terraform-hcp-rosa
```

### 2. Set credentials

Put your AWS credentials in a `.env` file. The file is gitignored.

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-northeast-1"
```

The `rhcs` provider also needs a Red Hat token. Choose one of these methods:

- **Offline token.** Get a token from https://console.redhat.com/openshift/token and add `export RHCS_TOKEN="..."` to `.env`.
- **rosa CLI login (SSO).** Run `rosa login --use-auth-code`. Pass the token at run time, as step 4 shows. Do not store it in `.env`.

Terraform does not read `.env` by itself. Run `source .env` in the same command as each `terraform` command.

### 3. Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Deploy

With an offline token in `.env`:

```bash
terraform init
source .env && terraform plan
source .env && terraform apply
```

With a rosa CLI login:

```bash
terraform init
source .env && RHCS_CLIENT_ID=ocm-cli RHCS_TOKEN="$(rosa token --refresh)" terraform plan
source .env && RHCS_CLIENT_ID=ocm-cli RHCS_TOKEN="$(rosa token --refresh)" terraform apply
```

Set `RHCS_CLIENT_ID=ocm-cli` because the rosa CLI issues tokens to the client `ocm-cli`, and the provider expects `cloud-services` by default. If you omit it, the provider fails with `Token client and authorized client don't match`. The inline `RHCS_TOKEN` overrides any `RHCS_TOKEN` in `.env`.

Terraform loads `terraform.tfvars` automatically, so `--var-file terraform.tfvars` is not necessary.

If you use workspaces, run `terraform workspace show` before `plan` or `apply` to check that you target the correct cluster's state.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `ap-northeast-1` | AWS region for deployment |
| `cluster_name` | `rosa-hcp` | Cluster name (max 15 characters) |
| `openshift_version` | `4.22.20` | OpenShift version |
| `replicas` | `2` | Number of default worker nodes |
| `compute_machine_type` | `m5.2xlarge` | EC2 instance type (only for new clusters) |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `availability_zones` | `["ap-northeast-1a", "ap-northeast-1c"]` | Availability zones |

## Machine Pools

This configuration includes two additional machine pools:

| Pool | Instance Type | Replicas | Use Case |
|------|---------------|----------|----------|
| `compute-pool` | `c5.4xlarge` | 2 | General compute workloads (ap-northeast-1a) |
| `gpu-pool-h100` | `p5.4xlarge` | 1 | NVIDIA H100 GPU/ML workloads (ap-northeast-1c) |

To modify machine pools, edit the `machine_pools` block in `main.tf`.

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_id` | ROSA HCP cluster ID |
| `vpc_id` | VPC ID |
| `private_subnet_ids` | Private subnet IDs |
| `public_subnet_ids` | Public subnet IDs |

## Resources Created

- VPC with public and private subnets
- NAT Gateway and Internet Gateway
- IAM roles (Installer, Support, Worker)
- OIDC provider and configuration
- Operator roles for cluster components
- ROSA HCP cluster with machine pools

## Cleanup

Use the same credentials as for `plan` and `apply`:

```bash
source .env && terraform destroy
```

## Module Versions

| Module | Version |
|--------|---------|
| [terraform-redhat/rosa-hcp/rhcs](https://registry.terraform.io/modules/terraform-redhat/rosa-hcp/rhcs) | 1.7.6 |
| [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws) | 6.7.3 |

## License

MIT
