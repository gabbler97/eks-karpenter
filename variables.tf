variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster to be created"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "ID of the existing subnets"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "region" {
  description = "Region of the AWS account"
  type        = string
}

variable "aws_admin_account_id" {
  description = "The AWS account id where the cluster will be created"
  type        = string
}

variable "node_volume_size" {
  description = "Size of the attached EBS volumes on the nodes"
  type        = string
  default     = "50Gi"
}

# https://github.com/awslabs/amazon-eks-ami/releases
variable "ami_karpenter_managed_amd64" {
  description = "AMI of the karpenter managed amd64 nodes"
  type        = string
  default     = "amazon-eks-node-al2023-arm64-standard-1.31-v20250228"
}

# https://github.com/awslabs/amazon-eks-ami/releases
variable "ami_karpenter_managed_arm64" {
  description = "AMI of the karpenter managed arm64 nodes"
  type        = string
  default     = "amazon-eks-node-al2023-arm64-standard-1.31-v20250228"
}