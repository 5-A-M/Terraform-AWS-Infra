# Terraform State, lock 파일을 저장할 S3와 DynamoDB 설정
# backend 리소스 저장소를 backend 등록 전 프로비저닝 할 수 있는 방법을 찾아야함

# terraform {
#   backend "s3" {
#     bucket         = "5am-eks-terraform-state"   # state가 저장될 S3 버킷 명
#     key            = "tfstate/terraform.tfstate" # state가 저장될 위치
#     region         = "ap-northeast-2"            # S3 버킷이 생성된 리전(필수 지정해야함)
#     encrypt        = true                        # S3 server-side 암호화 여부
#     dynamodb_table = "5am-eks-terraform-lock"    # lock 파일을 저장할 DynamoDB 테이블 명
#   }
# }
