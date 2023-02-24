# DevOps_CI-CD_On_EKS
## ITI_FINAL_PROJECT


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
- The Jenkins is run from a custom Image that has Docker CLI inside it and mounted to ***/var/run/docker.sock*** to the Daemon Running on Nodes
- The Docker Daemon Is Installed on Nodes using k8s ***Daemonset*** 
- The Jenkins deployment has a service account with a ***ClusterRole*** That allows the deployment to create deployments
- The Ansible ***Playbook*** Install ***AWSCLI V2*** To be able to connect to the cluster You must have V2 
- Ansible Installs Packages and ***Kubectl*** And pass credentials and Make the EC2 Connect to the Cluster then Deploys Jenkins and creates 2 Namespaces



---------------

## Prerequisites 

- AWS Account or IAM user with SDK permissions 
- Install Terrafrom & Ansible & Docker
- Install Add-ons on the Cluster like ***kube-Proxy*** & ***EBSCSI***
---------------------

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

- After Terraform Creation SSH into VM and install ***kubectl*** or any needed software like ***gcloud*** ( You can use Ansible to Automate this step )

- Connect to the GKE private cluster 
``` bash
gcloud container clusters get-credentials <cluster_name> --zone <zone> --project <project_id>
```
- Copy the provided k8s files and run them by:
```bash
kubectl apply -f <file-name>
```

- Run the following command to get the IP Adress of your Application
``` bash
kubectl get ingress 
```
- Copy the IP address and insert it in your browser to access the Application 

- Now Your Infrastructure & Application Is Up and Running !!


------------------------------------

## Bonus (Jenkins)

- Included Jenkins file to automate the procces 

- Configure Your Jenkins Master and install terraform plugins ( Jenkins running in a container or pod)
 
- Run your authentication commands inside Jenkins Container

- Create a new pipeline and make it run from Jenkinsfile provided in this Repo

- Note : You can add Ansible playbook to automate configuration and installation of packages and k8s deployment (out of project scope)

- Add the Ansible playbook to the pipeline as a stage.

- Note : This pipeline destroys the infrastructure after success of build ( for cost reasons ) to prevent this behaviour delete the ***post*** block from the Jenkinsfile
