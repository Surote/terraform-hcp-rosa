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
│  │  │  │ Internet GW   │  │  │  │  │  (m5.2xlarge)   │  │  │ │  │
│  │  │  └───────────────┘  │  │  │  │  2 replicas     │  │  │ │  │
│  │  └─────────────────────┘  │  │  └─────────────────┘  │  │ │  │
│  │                           │  │  ┌─────────────────┐  │  │ │  │
│  │                           │  │  │   gpu-pool      │  │  │ │  │
│  │                           │  │  │  (g5g.2xlarge)  │  │  │ │  │
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

### 2. Set environment variables

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-southeast-1"
export RHCS_TOKEN="your-rosa-token"  # Get from https://console.redhat.com/openshift/token
```

### 3. Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `ap-southeast-1` | AWS region for deployment |
| `cluster_name` | `rosa-hcp` | Cluster name (max 15 characters) |
| `openshift_version` | `4.20.8` | OpenShift version |
| `replicas` | `2` | Number of default worker nodes |
| `compute_machine_type` | `m5.2xlarge` | EC2 instance type (only for new clusters) |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `availability_zones` | `["ap-southeast-1a"]` | Availability zones |

## Machine Pools

This configuration includes two additional machine pools:

| Pool | Instance Type | Replicas | Use Case |
|------|---------------|----------|----------|
| `compute-pool` | `m5.2xlarge` | 2 | General compute workloads |
| `gpu-pool` | `g5g.2xlarge` | 1 | GPU/ML workloads |

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

```bash
terraform destroy
```

## Module Versions

| Module | Version |
|--------|---------|
| [terraform-redhat/rosa-hcp/rhcs](https://registry.terraform.io/modules/terraform-redhat/rosa-hcp/rhcs) | 1.7.1 |
| [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws) | ~> 5.0 |

## License

MIT
