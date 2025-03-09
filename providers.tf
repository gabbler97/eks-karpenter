terraform {
  backend "http" {} # To store terraform state file in a gitlab project
  required_providers {
    # The AWS provider is used to manage AWS resources, including EKS and related infrastructure.
    aws = {
      source  = "hashicorp/aws"
      version = "5.89.0"
    }

    # Helm provider is used to manage Helm charts in Kubernetes clusters.
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

    # The Kubectl provider is used to interact with Kubernetes clusters using the `kubectl` command-line tool.
    # This allows Terraform to perform operations on Kubernetes resources directly.
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }

  }

  # Specifies the required Terraform version.
  required_version = "1.11.0"
}

provider "helm" {
  kubernetes {
    host                   = module.eks_al2023.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_al2023.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_al2023.cluster_name]
    }
  }
}


data "aws_eks_cluster_auth" "created" {
  name = module.eks_al2023.cluster_name
}

provider "kubectl" {
  host                   = module.eks_al2023.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_al2023.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.created.token
  load_config_file       = false
}

provider "aws" {
  region  = var.region
  alias   = "aws"
}