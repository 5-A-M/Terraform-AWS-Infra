## argoCD
locals {
  argocd_admin_password = var.argocd_config.admin_password
  argocd_enable_dex     = var.argocd_config.enable_dex
  argocd_insecure       = var.argocd_config.insecure
}

resource "helm_release" "argocd" {
  namespace        = "argocd"
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.30.0"
  create_namespace = true

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = local.argocd_admin_password == "" ? "" : bcrypt(local.argocd_admin_password)
  }

  set {
    name  = "configs.parmas.server\\.insecure"
    value = local.argocd_insecure == true ? true : false
  }

  set {
    name  = "dex.enabled"
    value = local.argocd_enable_dex == true ? true : false
  }
}

## metrics_server
resource "helm_release" "metrics_server" {
  namespace  = "kube-system"
  name       = "metrics-server"
  chart      = "metrics-server"
  version    = "3.10.0"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
}

## Karpenter
# module "karpenter" {
#   source  = "terraform-aws-modules/eks/aws//modules/karpenter"
#   version = "19.15.3"

#   cluster_name = module.eks.cluster_name

#   irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
#   irsa_namespace_service_accounts = ["karpenter:karpenter"]

#   create_iam_role = false
#   iam_role_arn    = module.eks.eks_managed_node_groups["initial"].iam_role_arn

#   ## Provisioner가 새로운 워커노드(인스턴스)에 SSH 없이 들어가서 세팅을 하기 위해 SSM(Session Manager)이 필요
#   policies = {
#     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   }

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }

# resource "helm_release" "karpenter" {
#   namespace        = "karpenter"
#   create_namespace = true

#   name                = "karpenter"
#   repository          = "oci://public.ecr.aws/karpenter"
#   repository_username = data.aws_ecrpublic_authorization_token.token.user_name
#   repository_password = data.aws_ecrpublic_authorization_token.token.password
#   chart               = "karpenter"
#   version             = "v0.28.1"

#   set {
#     name  = "settings.aws.clusterName"
#     value = module.eks.cluster_name
#   }

#   set {
#     name  = "settings.aws.clusterEndpoint"
#     value = module.eks.cluster_endpoint
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.karpenter.irsa_arn
#   }

#   set {
#     name  = "settings.aws.defaultInstanceProfile"
#     value = module.karpenter.instance_profile_name
#   }

#   set {
#     name  = "settings.aws.interruptionQueueName"
#     value = module.karpenter.queue_name
#   }
# }

# resource "kubectl_manifest" "karpenter_provisioner" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.sh/v1alpha5
#     kind: Provisioner
#     metadata:
#       name: default
#     spec:
#       requirements:
#         - key: karpenter.sh/capacity-type
#           operator: In
#           values: ["spot"]
#         - key: "node.kubernetes.io/instance-type"
#           operator: In
#           values: ["t3.large", "t3.xlarge"]
#         - key: "topology.kubernetes.io/zone"
#           operator: In
#           values: [ "ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c" ]
#       limits:
#         resources:
#           cpu: 1000
#       providerRef:
#         name: default
#       ttlSecondsAfterEmpty: 30
#   YAML

#   depends_on = [
#     helm_release.karpenter
#   ]
# }

# resource "kubectl_manifest" "karpenter_node_template" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.k8s.aws/v1alpha1
#     kind: AWSNodeTemplate
#     metadata:
#       name: default
#     spec:
#       subnetSelector:
#         karpenter.sh/discovery: ${module.eks.cluster_name}
#       securityGroupSelector:
#         karpenter.sh/discovery: ${module.eks.cluster_name}
#       tags:
#         karpenter.sh/discovery: ${module.eks.cluster_name}
#   YAML

#   depends_on = [
#     helm_release.karpenter
#   ]
# }

## AWS LB controller
# locals {
#   lb_controller_service_account_name = var.lb_controller_service_account_name
# }

# module "iam_assumable_role_alb_controller" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version = "5.26.0"

#   create_role                   = true
#   role_name                     = "${local.cluster_name}-alb-controller"
#   role_description              = "Used by AWS Load Balancer Controller for EKS"
#   provider_url                  = module.eks.cluster_oidc_issuer_url
#   oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:${local.lb_controller_service_account_name}"]
# }


# data "http" "iam_policy" {
#   url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json"
# }

# resource "aws_iam_role_policy" "controller" {
#   name_prefix = "AWSLoadBalancerControllerIAMPolicy"
#   policy      = data.http.iam_policy.response_body
#   role        = module.iam_assumable_role_alb_controller.iam_role_name
# }

# resource "helm_release" "lb_controller" {
#   name       = local.lb_controller_service_account_name
#   chart      = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   namespace  = "kube-system"

#   set {
#     name  = "clusterName"
#     value = module.eks.cluster_name
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = local.lb_controller_service_account_name
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.iam_assumable_role_alb_controller.iam_role_arn
#   }

#   set {
#     name  = "region"
#     value = "ap-northeast-2"
#   }

#   set {
#     name  = "vpcId"
#     value = local.vpc_id
#   }

#   set {
#     name  = "image.repository"
#     value = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"
#   }
# }

