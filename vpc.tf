module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  # AZs: ["ap-northeast-1a", "ap-northeast-1c"]
  azs = var.availability_zones

  # private_subnets[0] = 10.0.0.0/20  (ap-northeast-1a) — used by cluster + pool1
  # private_subnets[1] = 10.0.16.0/20 (ap-northeast-1c) — used by pool3 (gpu)
  private_subnets = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, k)]

  # public_subnets[0] = 10.0.64.0/20 (ap-northeast-1a) — used by cluster
  # public_subnets[1] = 10.0.80.0/20 (ap-northeast-1c)
  public_subnets = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, k + 4)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags required for ROSA
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Terraform   = "true"
    Environment = "rosa-hcp"
  }
}
