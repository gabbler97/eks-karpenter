
resource "kubectl_manifest" "karpenter_ec2_node_class_amd64" {
  depends_on = [helm_release.karpenter]
  yaml_body  = <<YAML
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: amd64
spec:
  amiSelectorTerms:
# https://github.com/awslabs/amazon-eks-ami/releases
    - id: ${var.ami_karpenter_managed_amd64}
  role: ${module.eks_al2023.cluster_name}
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${module.eks_al2023.cluster_name}
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${module.eks_al2023.cluster_name}
  tags:
    karpenter.sh/discovery: ${module.eks_al2023.cluster_name}
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeType: gp3
        encrypted: true
        volumeSize: "${var.node_volume_size}"

YAML
}

resource "kubectl_manifest" "karpenter_ec2_node_pool_amd64" {
  depends_on = [helm_release.karpenter]
  yaml_body  = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: amd64
spec:
  template:
    metadata:
      labels:
        arch: amd64
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "m"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["5"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["4", "8", "16", "32"]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: amd64
YAML
}


resource "kubectl_manifest" "karpenter_ec2_node_class_arm64" {
  depends_on = [helm_release.karpenter]
  yaml_body  = <<YAML
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: arm64
spec:
  amiSelectorTerms:
    - id: ${var.ami_karpenter_managed_arm64}
  role: ${module.eks_al2023.cluster_name}
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${module.eks_al2023.cluster_name}
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${module.eks_al2023.cluster_name}
  tags:
    karpenter.sh/discovery: ${module.eks_al2023.cluster_name}
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeType: gp3
        encrypted: true
        volumeSize: "${var.node_volume_size}"

YAML
}

resource "kubectl_manifest" "karpenter_ec2_node_pool_arm64" {
  depends_on = [helm_release.karpenter]
  yaml_body  = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: arm64
spec:
  template:
    metadata:
      labels:
        arch: arm64
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["arm64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "a"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["5"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["4", "8", "16", "32"]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: arm64
YAML
}