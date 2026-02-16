# ROSA HCP Cluster with all required resources
module "rosa_hcp" {
  source  = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.7.1"

  cluster_name           = var.cluster_name
  openshift_version      = var.openshift_version
  machine_cidr           = var.vpc_cidr
  aws_subnet_ids         = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  aws_availability_zones = var.availability_zones
  replicas               = var.replicas

  # Note: compute_machine_type cannot be changed after cluster creation
  # Use machine_pools below to add worker nodes with specific instance types

  # Additional machine pools
  # https://docs.aws.amazon.com/ec2/latest/instancetypes/ec2-instance-regions.html#instance-types-ap-southeast-1
  machine_pools = {
    pool1 = {
      name              = "compute-pool"
      replicas          = 2
      openshift_version = var.openshift_version
      subnet_id         = module.vpc.private_subnets[0]
      auto_repair       = true
      aws_node_pool = {
        instance_type = "m5.2xlarge"
        tags          = {}
      }
    }
    #g6e.8xlarge
      pool2 = {
      name              = "gpu-pool-g6e"
      replicas          = 1
      openshift_version = var.openshift_version
      subnet_id         = module.vpc.private_subnets[0]
      auto_repair       = true
      aws_node_pool = {
        instance_type = "g6e.8xlarge"
        tags          = {}
      }
    }
  }

  # Use contract billing for Red Hat employees
  aws_billing_account_id = ""

  # STS configuration - create all required roles
  create_account_roles  = true
  account_role_prefix   = var.cluster_name
  create_oidc           = true
  create_operator_roles = true
  operator_role_prefix  = var.cluster_name

  # Wait for cluster to be ready
  wait_for_create_complete            = true
  wait_for_std_compute_nodes_complete = true
}
