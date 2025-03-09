module "eks_al2023" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.33.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (Karpenter) into the cluster
  enable_cluster_creator_admin_permissions = true
  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni = {
      ## In case of Pv4 address exhaustion
      ## https://github.com/aws/amazon-vpc-cni-k8s/blob/master/README.md
      #configuration_values = jsonencode({
      #  env = {
      #    ENABLE_PREFIX_DELEGATION           = "true"
      #    AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
      #    ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
      #  }
      #})
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    managed = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["m6i.large"]

      min_size = 2
      max_size = 2
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 2
      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
    }
  }
  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  }

}
## In case of Pv4 address exhaustion
## https://github.com/aws/amazon-vpc-cni-k8s/blob/master/charts/aws-vpc-cni/templates/eniconfig.yaml
#resource "kubectl_manifest" "eniconfig" {
#  yaml_body = <<-EOF
#  apiVersion: crd.k8s.amazonaws.com/v1alpha1
#  kind: ENIConfig
#  metadata:
#    name: AZ_NAME
#  spec:
#    securityGroups:
#      - SECURITY_GROUP_ID
#    subnet: SUBNET_ID
#  EOF
#}