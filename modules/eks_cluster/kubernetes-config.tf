# Terraform EKS 모듈이 configmap/aws-auth에 접근하지 못하는 문제 발생
# Kubernetes Provider를 통해 configmap/aws-auth에 접근하도록 설정
# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009#issuecomment-1272089141

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks.eks_managed_node_groups
  ]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks.eks_managed_node_groups
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  token                  = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
}
