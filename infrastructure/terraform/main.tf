# YouLend Infrastructure - Main Configuration

locals {
  cluster_name = "${var.project_name}-eks"
  
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name
  environment        = var.environment
  cluster_name       = local.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_disk_size      = var.node_disk_size

  tags = local.common_tags

  depends_on = [module.vpc]
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  project_name              = var.project_name
  environment               = var.environment
  repositories              = var.ecr_repositories
  image_tag_mutability      = var.ecr_image_tag_mutability
  scan_on_push              = var.ecr_scan_on_push
  lifecycle_policy_count    = var.ecr_lifecycle_policy_count

  tags = local.common_tags
}
