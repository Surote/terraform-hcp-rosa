# ROSA HCP Deployment on AWS

This Terraform configuration deploys a Red Hat OpenShift Service on AWS (ROSA) with Hosted Control Plane (HCP) in the `ap-southeast-1` region.

## Prerequisites

Before running Terraform, you need to:

1. **Enable ROSA on AWS Marketplace** (Required - One-time setup)
   - Go to: https://console.aws.amazon.com/rosa/home
   - Or: https://aws.amazon.com/marketplace/pp/prodview-fpcgcl2xjknba
   - Click "Enable ROSA with HCP" and complete the subscription
   - This links your AWS account to Red Hat for billing

2. **Set environment variables:**
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_DEFAULT_REGION="ap-southeast-1"
   export RHCS_TOKEN="your-rosa-token"  # Get from https://console.redhat.com/openshift/token
   ```

## Current Status

The following resources have been created:

| Resource | Status |
|----------|--------|
| VPC | ✅ Created |
| Private Subnets | ✅ Created |
| Public Subnets | ✅ Created |
| NAT Gateway | ✅ Created |
| Internet Gateway | ✅ Created |
| Route Tables | ✅ Created |
| IAM Account Roles | ✅ Created |
| OIDC Configuration | ✅ Created |
| Operator Roles | ✅ Created |
| **ROSA HCP Cluster** | ⏳ Pending AWS Marketplace subscription |

## Usage

After enabling ROSA on AWS Marketplace, run:

```bash
# Initialize Terraform
terraform init

# Apply the configuration
terraform apply
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `ap-southeast-1` | AWS region |
| `cluster_name` | `rosa-hcp` | Cluster name (max 15 chars) |
| `openshift_version` | `4.20.8` | OpenShift version |
| `replicas` | `2` | Number of worker nodes |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |

## Outputs

After successful deployment:
- `cluster_id` - The ROSA HCP cluster ID
- `vpc_id` - The VPC ID
- `private_subnet_ids` - Private subnet IDs
- `public_subnet_ids` - Public subnet IDs

## Cleanup

To destroy all resources:

```bash
terraform destroy
```
