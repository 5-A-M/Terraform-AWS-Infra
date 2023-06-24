module "eks_vpc" {
  source = "./modules/vpc"

  vpc_name        = "5am-eks-cluster-vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

module "eks" {
  source = "./modules/eks_cluster"

  cluster_name    = "5am-eks-cluster"
  cluster_version = "1.26"
  vpc_id          = module.eks_vpc.vpc_id
  subnet_ids      = module.eks_vpc.subnet_ids
}

module "web" {
  source = "./modules/web"

  frontend_bucket_name = "5am-dev-web"
  index_document       = "index.html"
  error_document       = "index.html"
}
