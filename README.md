# Hands-On Project: Deploying Applications with Rancher

This project demonstrates deploying, managing, and scaling a Kubernetes application using **Rancher**, a Kubernetes management platform. The application is a simple NGINX web server named `t2s-services`, hosting a form for T2S students to enroll in DevOps and Cloud courses.

---

## Prerequisites

1. **Rancher Installed**: Rancher server running and accessible.
2. **Kubernetes Cluster**: Rancher must manage a Kubernetes cluster.
   - Use Minikube, an existing Kubernetes cluster, or create one via Rancher.
3. **Docker Installed**: Required to run the Rancher server (if using Docker).
4. **kubectl Installed**: Kubernetes CLI for direct cluster management.

---

## Step 1: Install and Set Up Rancher

### 1. Install Rancher
#### 1. Run the Rancher server in a Docker container:
```bash
docker run -d --restart=unless-stopped \
-p 80:80 -p 443:443 \
--name rancher \
rancher/rancher:latest
```

#### 2.	Open Rancher in a browser:
- Navigate to https://<your-machine-ip>.

#### 3.	Complete the Rancher setup:
- Set up an admin account and configure authentication.

## Step 2: Connect or Create a Kubernetes Cluster

### 1. Option 1: Create a Kubernetes Cluster
#### 1. Create your EKS Cluster
- Create a backend storage for your Terraform state file.
- Once in the backend-setup directory, change variables accordingly.  
```bash
cd eks-cluster/backend-setup
```
- Run the following commands: 
```bash
terraform init
terraform plan
terraform apply
```

#### Move to the desired environment where to deploy the EKS cluster
```bash
cd ../environments/dev
```
- Change variables as desired. 
- Run the following commands: 
```bash
terraform init
terraform plan
terraform apply
```

#### Steps to Deploy t2s-enrollment Application on AWS EKS

**Step 1: Build & Push Docker Image to AWS ECR**
- Create an ECR Repository
```bash
aws ecr create-repository --repository-name t2s-enrollment --region us-east-1
```

- Retrieve AWS Account ID
```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
```

- Authenticate Docker to AWS ECR
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
```

- Build Docker Image
```bash
docker build -t t2s-enrollment .
```

- Tag the Docker Image
```bash
docker tag t2s-enrollment:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/t2s-enrollment:latest
```

- Push the Image to ECR
```bash
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/t2s-enrollment:latest
```

**Step 2: Deploy the Application on Kubernetes**
- Create a Secret for AWS ECR Authentication
```bash
kubectl create secret docker-registry ecr-secret \
  --docker-server=$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace default
```

- Apply the Deployment & Service
```bash
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml
```

- Verify Deployment
```bash
kubectl get pods
kubectl get services
```

- Get the External Load Balancer URL & Access the Application
```bash
kubectl get svc t2s-enrollment-service
```

- Open in browser:
```txt
http://<EXTERNAL-IP>
```

#### 2.	In Rancher, go to **Clusters** > **Create** > **Custom Cluster**.

- **Follow the instructions to create a Kubernetes cluster.**

---
### 2. Option 2: Import an Existing Cluster
1.	Go to **Clusters > Import Existing Cluster**.

2.	Follow the instructions to install the Rancher agent on the cluster.

## Step 3: Deploy the t2s-services Application

### 1. Create a Deployment
1.	Navigate to **Apps & Marketplace** > **Launch App**.

2.	Select the namespace and create a new Helm chart.

3.	Use the following configuration for the NGINX application:
- Find in the deployment directory. 

**values.yaml** File
```yaml
replicaCount: 2

image:
  repository: nginx
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 80

resources: {}

nodeSelector: {}

tolerations: []

affinity: {}
```

## Step 4: Access the Application

### 1. Get the NodePort
1.	Navigate to Workloads > Services.

2.	Identify the NodePort assigned to your service.

### 2. Access the Application
- Open your browser and navigate to **http://<cluster-ip>:<node-port>**.

## Step 5: Scale the Application

### 1. Scale Using Rancher UI
1.	Go to **Workloads** > **Select your deployment**.

2.	**Edit** the number of replicas and **save**.

2. Scale Using kubectl
```bash
kubectl scale deployment t2s-services --replicas=5
```

## Step 6: Clean Up Resources

### 1. Delete the Application
- Navigate to **Apps & Marketplace** > **t2s-services** > **Delete**.

### 2. Remove the Cluster
- Go to **Clusters** > **Select Cluster** > **Delete**.

### 3. Stop Rancher (if using Docker)
```bash
docker stop rancher
docker rm rancher
```

---
## Summary of Commands

#### Rancher Setup
```bash
docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --name rancher rancher/rancher:latest
```

#### Kubernetes Commands
```bash
kubectl scale deployment t2s-services --replicas=5
```

This project provides a complete workflow for deploying and managing Kubernetes applications using Rancher. It covers installation, deployment, scaling, and cleanup. Let me know if you need further guidance!

