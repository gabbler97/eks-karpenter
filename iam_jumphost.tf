# Instance profile for aws eks cluster admin ec2 jumphost
resource "aws_iam_instance_profile" "this" {
  name = "eks_admin_${var.cluster_name}_profile"
  role = aws_iam_role.this.name
  path = "/"
}
# Role for instance profile
resource "aws_iam_role" "this" {
  name               = "eks_admin_${var.cluster_name}_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  path               = "/"
  description        = "Role for eks cluster"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
# Policy for role
data "aws_iam_policy_document" "default" {

  # If the user coming from ssm manager and not through ssh
  statement {
    effect    = "Allow"
    resources = ["arn:aws:iam::${var.aws_admin_account_id}:role/jumphost-session-manager"]
    actions   = ["iam:GetRole", "iam:PassRole"]
  }

  # This statement allows describing and listing EKS clusters. Needed for kubeconfig generation.
  statement {
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]
    resources = [
      "arn:aws:eks:*:${var.aws_admin_account_id}:cluster/*"
    ]
  }
}

# Add created role to aws auth configmap
module "eks-auth" {
  depends_on = [module.eks_al2023]
  source     = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version    = "20.33.1"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${var.aws_admin_account_id}:role/eks_admin_${var.cluster_name}_role"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_accounts = [
    "${var.aws_admin_account_id}"
  ]
}