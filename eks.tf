module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "example"
  kubernetes_version = "1.37"

  # Optional
  endpoint_public_access       = true
  endpoint_private_access      = true # nodes reach the API privately
  endpoint_public_access_cidrs = var.api_allowed_cidrs

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  # Auto Mode: AWS runs the nodes, networking, storage and LB controllers for you
  compute_config = var.eks_auto_mode ? {
    enabled    = true
    node_pools = ["general-purpose"]
  } : null

  # Regular mode: the module sets bootstrap_self_managed_addons = false,
  # so the core addons have to be installed explicitly
  addons = var.eks_auto_mode ? {} : {
    vpc-cni = {
      before_compute = true # CNI must exist before nodes join
    }
    kube-proxy = {
      before_compute = true
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
    coredns = {}
  }

  eks_managed_node_groups = var.eks_auto_mode ? {} : {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.node_instance_types

      min_size     = 1
      max_size     = 3
      desired_size = var.node_desired_size
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = var.public_subnets_only ? module.vpc.public_subnets : module.vpc.private_subnets

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
