variable "region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "ap-northeast-1"
}

variable "cluster_name" {
  description = "The name of the ROSA cluster (max 15 characters)"
  type        = string
  default     = "rosa-hcp"
}

variable "openshift_version" {
  description = "OpenShift version for the cluster"
  type        = string
  default     = "4.20.8"
}

variable "replicas" {
  description = "Number of default worker nodes"
  type        = number
  default     = 2
}

variable "compute_machine_type" {
  description = "EC2 instance type for default worker nodes"
  type        = string
  default     = "m5.2xlarge"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones for the VPC (immutable on existing cluster)"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "cluster_availability_zones" {
  description = "Availability zones for the ROSA cluster (cannot be changed after creation)"
  type        = list(string)
  default     = ["ap-northeast-1a"]
}
