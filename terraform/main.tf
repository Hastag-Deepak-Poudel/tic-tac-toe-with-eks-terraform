module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.32"

  # Access entry configuration (Best practice for EKS v20+)
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  # Optional but recommended: restrict public endpoint to your IP range
  # cluster_endpoint_public_access_cidrs = ["YOUR_IP/32"] 

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets # Optional: see note below

  eks_managed_node_groups = {
    example = {
      # Change from t3.medium to a free-tier eligible type
      instance_types = ["t3.micro"] 
      
      # EKS system pods need room to breathe; keep at least 2 nodes
      min_size     = 3
      max_size     = 3
      desired_size = 3

      subnet_ids = module.vpc.private_subnets
    }
  }
  tags = local.common_tags
}

# Centralized tagging strategy
locals {
  common_tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}