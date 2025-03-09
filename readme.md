# Terraform EKS Cluster

## Overview
This Terraform repository provisions an Amazon EKS cluster along with Karpenter-managed node groups supporting both x86 (AMD64) and Graviton (ARM64) instances.

## Prerequisites

- A Gitalb project
- A registered runner

## Setup
### Step 1: Create a Repository in Gitlab and adding variables.
#### 1. Creating an access token:
Go to your repo: On the left panel where you see all the options <br> <br>
Your Repo > Settings > Access Tokens > Add new token
Give all the access API, read_api, create_runner etc etc. Select a role, such as Mainter, Owner.
#### 2.
Navigate to your GitLab project and go to “Settings” > “CI / CD” > “Variables.”

#### 3.
Add the following environment variables: <br> <br>
```AWS_ACCESS_KEY_ID```: Your AWS access key. <br>
```AWS_SECRET_ACCESS_KEY```: Your AWS secret key. <br>
```AWS_REGION```: The AWS region where your resources will be deployed. <br>
```TOKEN```: Personal Access Token for Gitlab, that you have created above. <br>
```USERNAME```: Username of your Gitlab.

### Step 3: Setup a Terraform State File in Remote (Gitlab)
Use terminal or vscode terminal.

Variables are: <br>
<gitlab_project_id> <br>
<gitlab_url> <br>
<state_name> <br>
<gitlab_access_token> <br>
<username> <br>

```
terraform init \
    -backend-config="address=https://<gitlab_url>/api/v4/projects/<gitlab_project_id>/terraform/state/<state_name>" \
    -backend-config="lock_address=https://<gitlab_url>/api/v4/projects/<gitlab_project_id>/terraform/state/<state_name>/lock" \
    -backend-config="unlock_address=https://<gitlab_url>/api/v4/projects/<gitlab_project_id>/terraform/state/<state_name>/lock" \
    -backend-config="username=<username>" \ # your username
    -backend-config="password=<gitlab_access_token>" \ # your access token
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"
```

## Acces the cluster and add deployments to it
### 1. Configure Kubectl
After Terraform completes: <br>
Create an EC2 instance with your preferences and attach the following instance profile t in in the same account where the cluster is created: <br><br>
eks_admin_<cluster_name>_profile <br>

Login to the instance <br>
Configure `kubectl` to interact with the cluster:
```sh
aws eks update-kubeconfig --region <region> --name <cluster_name>
```

## Deploying a Pod on x86 or Graviton Nodes
### 1. Example Deployment for AMD64 (x86)
To deploy a pod on an x86 instance, apply the following Kubernetes manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: amd64-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: amd64-app
  template:
    metadata:
      labels:
        app: amd64-app
    spec:
      nodeSelector:
        kubernetes.io/arch: amd64
      containers:
        - name: amd64-container
          image: nginx:latest
```

Apply the manifest:
```sh
kubectl apply -f amd64-deployment.yaml
```

### 2. Example Deployment for ARM64 (Graviton)
To deploy a pod on an ARM64 (Graviton) instance:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: arm64-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: arm64-app
  template:
    metadata:
      labels:
        app: arm64-app
    spec:
      nodeSelector:
        kubernetes.io/arch: arm64
      containers:
        - name: arm64-container
          image: nginx:latest
```

Apply the manifest:
```sh
kubectl apply -f arm64-deployment.yaml
```

## Verifying Deployments
Check if the pods are running on the correct architecture:
```sh
kubectl get pods -o wide
```
Look at the `NODE` column and verify that pods are scheduled on the desired node.