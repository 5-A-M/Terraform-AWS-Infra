module "eks_vpc" {
  source = "./modules/vpc"

  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  cluster_name    = var.cluster_name
}

module "eks" {
  source = "./modules/eks_cluster"

  vpc_id     = module.eks_vpc.vpc_id
  subnet_ids = module.eks_vpc.subnet_ids

  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  aws_auth_users            = var.aws_auth_users
  aws_auth_accounts         = var.aws_auth_accounts

  argocd_config = var.argocd_config
  # lb_controller_service_account_name = "aws-load-balancer-controller"
}

# module "web" {
#   source = "./modules/web"

#   frontend_bucket_name = "5am-dev-web"
# }

# module "tfstate_store" {
#   source = "./modules/tfstate_store"

#   backend_bucket_name    = "5am-eks-terraform-state"
#   backend_ddb_table_name = "5am-eks-terraform-lock"
# }
