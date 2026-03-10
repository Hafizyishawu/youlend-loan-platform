# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ips" {
  description = "List of NAT Gateway public IPs"
  value       = module.vpc.nat_gateway_ips
}

# EKS Outputs
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = module.eks.oidc_provider_arn
}

# ECR Outputs
output "ecr_repository_urls" {
  description = "Map of ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "Map of ECR repository ARNs"
  value       = module.ecr.repository_arns
}

# Kubernetes Configuration
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name} --profile ${var.aws_profile}"
}

# Summary
output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    vpc = {
      id              = module.vpc.vpc_id
      cidr            = var.vpc_cidr
      azs             = var.availability_zones
      public_subnets  = module.vpc.public_subnet_ids
      private_subnets = module.vpc.private_subnet_ids
    }
    eks = {
      cluster_name     = module.eks.cluster_name
      cluster_version  = var.cluster_version
      cluster_endpoint = module.eks.cluster_endpoint
      node_groups = {
        instance_types = var.node_instance_types
        desired_size   = var.node_desired_size
        min_size       = var.node_min_size
        max_size       = var.node_max_size
      }
    }
    ecr = {
      repositories = module.ecr.repository_urls
    }
  }
}
