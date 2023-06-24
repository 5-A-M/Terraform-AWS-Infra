locals {
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  # VPC 모듈에서 생성된 워커 노드들이 위치한 VPC 영역
  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids

  cluster_endpoint_public_access  = true # 외부에서 EKS 엔드포인트에 접근 가능 허용
  cluster_endpoint_private_access = true # 컨트롤 플레인과 워커 노드들이 인터넷으로 나가지 않고 ENI를 통해 VPC 간 통신 허용
  # cluster_endpoint_public_access_cidrs = ["121.140.69.95/32", "121.140.69.176/32"] # 엔드포인트 접근 제어

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64" # EKS 워커 노드에 최적화 된 Amazon Linux 2 AMI 사용
  }

  eks_managed_node_groups = {
    initial = {
      name = "node-group-1"

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }

  # EKS RBAC는 IAM과 연동되어 있기 때문에, 생성자 외 다른 유저 접근 시 추가 권한 부여 필요
  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::<유저 고유 ID>:user/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::<유저 고유 ID>:user/kde"
      username = "kde"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "<유저 고유 ID>"
  ]
}
