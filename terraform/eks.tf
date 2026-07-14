module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      # t3.micro is free-tier eligible; SPOT cuts cost further
      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"

      labels = {
        Environment = var.environment
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}
