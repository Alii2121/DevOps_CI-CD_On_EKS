# DevOps_CI/CD_On_EKS
## ITI FINAL PROJECT


![actor](https://user-images.githubusercontent.com/103090890/221306973-a5616cf8-4b58-4934-a5d0-7b58322589b9.png)


## Tools used 

![Ansible](https://img.shields.io/badge/-ansible-C9284D?style=for-the-badge&logo=ansible&logoColor=white)
![Jenkins](https://img.shields.io/badge/-jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)
![K8s](https://img.shields.io/badge/-kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/-Terraform-623CE4?style=for-the-badge&logo=Terraform&logoColor=white)
![Python](https://img.shields.io/badge/-Python-3776AB?style=for-the-badge&logo=Python&logoColor=yellow)
![Docker](https://img.shields.io/badge/Docker-container%20runtime-2496ED?style=for-the-badge&logo=Docker)


## Project Specifications 

- Infrastructure as a Code with Terrafrom Contains 2 Private and 2 Public Subnets with IGW and NAT 
- Fully Private EKS Cluster And Nodes 
- Accessing Cluster via Bastion Host
- Ansible to Conigure The Bastion Host and Run Jenkins Deployment
- Full CI/CD Pipeline to Deploy Application on EKS Using Jenkins





------------------------------------

## Getting Started

- This Project Deploys A Python Counter app using ***loadbalancer***
- The Jenkins Master is Running as a ***Deployment*** inside EKS Cluster note that the Cluster is fully Private
- The Cluster is Only Accessible through an EC2 Acting as ***Bastion Host*** within the same ***VPC***
- You can use ***Cloud9 IDE*** Or AWS transit gateway to connect to the cluster 
- The K8S ***PV*** is an EBS 
- The Jenkins is run from a my custom Image ***dockerjenkins*** that has Docker CLI inside it and mounted to ***/var/run/docker.sock*** to the Daemon Running on Nodes
- The Docker Daemon Is Installed on Nodes using k8s ***Daemonset*** 
- The Jenkins deployment has a service account with a ***ClusterRole*** That allows the deployment to create deployments
- The Ansible ***Playbook*** Install ***AWSCLI V2*** To be able to connect to the cluster You must have V2 
- Ansible Installs Packages and ***Kubectl*** And pass credentials and Make the EC2 Connect to the Cluster then Deploys Jenkins and creates 2 Namespaces
- The StorageClass k8s file updates the StorageClass to ***gp2*** 


---------------

## Prerequisites 

- AWS Account or IAM user with SDK permissions 
- Install Terrafrom & Ansible & Docker
- Install Add-ons on the Cluster like ***kube-Proxy*** & ***EBSCSI***
---------------------

## What a real-life Deployment Need Extra?

- In my Opinion A real life deployment would need a tool like ***VAULT*** to manage secrets
- Larger EC2 Types depending on workloads
- Much More restrictions on Security Groups and inbound rules
- The Usage of CLOUD9 IDE 
- A Monitoring agent on the EKS like Prometheus
- Integration of pipeline with ***SLACK***
- Jenkins Agent thet is used to run as a slave to run docker commands then terminiate after build for security reasons
- An autoscaling group that Scales out horizontally according to traffic
- Tools like Amazon CloudWatch and Prometheus can be used to monitor cluster and application metrics, while tools like Elasticsearch, Fluentd, and Kibana (EFK) can be used to aggregate and analyze log data.
- Regularly patching worker nodes to protect against security vulnerabilities.


----------------------

## What Can Be Improved Upon?

#### Using GitOps Approach would be a huge improvement:
- Create an IAM policy with the necessary permissions for Argo CD. The policy should allow read/write access to the Kubernetes API server.
- Create an IAM role and attach the policy to the role.
- Update the Kubernetes ConfigMap to include the IAM role.
- Install ArgoCD CLI on the Bastion Host 
``` bash
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sSL -o argocd-darwin-amd64 https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-darwin-amd64
sudo install -m 555 argocd-darwin-amd64 /usr/local/bin/argocd
rm argocd-darwin-amd64
```
- Install ArgoCD on EKS using Helm
``` bash
 kubectl create namespace argocd
 helm repo add argo https://argoproj.github.io/argo-helm
 helm install argocd argo/argo-cd --namespace argocd
```
- Create a new application manifest in your source control repository that describes the desired state of your application. The manifest should be in YAML format and include information such as the application name, source repository, target namespace, and deployment strategy.

- Connect the Argo CD server to your Git repository
 ``` bash
 kubectl create secret generic argocd-git-creds \
    --from-literal=username=<GIT_USERNAME> \
    --from-literal=password=<GIT_PASSWORD> \
    --namespace argocd
```

-------------------





## Installation 

- Clone This Repo

- Run Terraform files
```bash
terraform init
terraform apply
```
- The Terraform Outputs The IP of the Bastion Host to a file called ***IPS.txt***
- Copy The IP into The ***Ansible/Inventory.txt*** file and configure Your Keys Accordingly 
-  Then Install Ansible Kubernetes Module 
```bash
ansible-galaxy collection install community.kubernetes
```
- Then Run the Ansible Playbook
``` bash
asnible-playbook -i inventory.txt playbook.yml
```

- Get the LoadBalancer DNS output from the playbook then wait few minutes for the LB to be Active and put ***:80*** at the end of the URL 


- Access The Jenkins URL then SSH into the EC2 to get Jenkins Password RUN
``` bash 
kubectl get pods -n jenkins 
kubectl logs <pod-name> -n jenkins
```
- Configure Jenkins And Install Plugins Like Kubernetes and GitHub
- Enter Your Credentials for GitHub And DockerHub in ***Manage Credentials***
- Fork This Repo to get <a href="https://github.com/Alii2121/Py-App-CICD" target="_blank">App</a>
- Configure Pipeline to Use Jenkinsfile from The Repo And Configure Your Credntials inside the Jenkinsfile
- You can get the app LB from the EC2 
```bash
kubectl get svc -n app
```

### :rocket: Your Infra And App Is Running Successfully !

----------------------

![Screenshot from 2023-02-24 23-30-11](https://user-images.githubusercontent.com/103090890/221323055-29e28e6e-c1e9-46c3-a479-5fbf00731157.png)

# Thank You !

