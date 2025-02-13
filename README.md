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
1.	In Rancher, go to **Clusters** > **Create** > **Custom Cluster**.

2.	Follow the instructions to create a Kubernetes cluster.

### 2. Option 2: Import an Existing Cluster
1.	Go to **Clusters > Import Existing Cluster**.

2.	Follow the instructions to install the Rancher agent on the cluster.

## Step 3: Deploy the t2s-services Application

### 1. Create a Deployment
1.	Navigate to **Apps & Marketplace** > **Launch App**.

2.	Select the namespace and create a new Helm chart.

3.	Use the following configuration for the NGINX application:

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

