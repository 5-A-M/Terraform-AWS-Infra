# infra

---

테라폼으로 구축한 5AM 프로젝트의 인프라로 구축사항은 아래와 같습니다.

- EKS 클러스터 & VPC
- S3 정적 웹 호스팅
- tfstate를 저장할 backend 스토리지

프로젝트 간 리소스들은 지속적으로 추가될 것입니다.

## 버전

- Terraform: 1.4.2
- AWS Provider: 5.5.0
- terraform-aws-modules/eks: 19.15.3
- terraform-aws-modules/vpc: 5.0.0

## Clone하여 테스트할 경우 수정해야할 변수

```
├── main.tf # 각 리소스 명
├── modules
│   ├── eks_cluster
│   │   ├── main.tf # EKS RBAC 접근 권한 제어
```
