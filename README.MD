# 5am IAC

---

테라폼으로 구축한 5AM 프로젝트 인프라

- EKS 클러스터
- EKS 클러스터 전용 VPC
- 정적 웹 호스팅 용 S3
- tfstate를 저장할 backend 스토리지(S3, DynamoDB)
- EFS 및 efs-csi-controller(helm 차트)

프로젝트 간 리소스들은 지속적으로 추가될 것입니다.

## 버전

- Terraform: 1.4.2
- AWS Provider: 5.5.0
- kubernetes: 1.26

## 변수 모듈화

각 리소스 모듈(modules 폴더)의 동적 변수들은 루트 디렉토리의 `variable.tf`에서 변수를 지정하고, `main.tf`의 모듈에서 통해 주입됩니다. `variable.tf`에서 지정된 변수들을 할당하는 방법은 `terraform.tfvars`파일을 생성하여 해당 파일에 선언해주면 됩니다.

`terraform.tfvars`은 민감한 정보(ex. argocd 비밀번호, 클러스터 RBAC 데이터 등)을 최대한 노출시키지 않기 위해 퍼블릭 깃헙에 올리지 않았습니다. 해당 파일 내용의 예시로는 다음과 같습니다.

## terraform.tfvars 예시

```
vpc_name        = "5am-eks-cluster-vpc"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

cluster_name    = "5am-eks-cluster"
cluster_version = "1.26"

argocd_config = {
  admin_password = "qwer1234"
  enable_dex     = true
  insecure       = false
}

manage_aws_auth_configmap = true
aws_auth_users = [
  {
    userarn  = "arn:aws:iam::123456789:user/admin"
    username = "admin"
    groups   = ["system:masters"]
  },
]

aws_auth_accounts = [
  "123456789"
]

```
