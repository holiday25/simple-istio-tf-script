# Istio and HTTPD Deployment with Terraform on Minikube

This repository contains a Terraform configuration to deploy Istio and a sample HTTPD application on a Minikube cluster. The configuration uses Helm for managing Kubernetes applications.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Minikube**: A local Kubernetes cluster
- **kubectl**: Kubernetes command-line tool
- **Terraform**: Infrastructure as code tool
- **Helm**: Package manager for Kubernetes

## Installation Steps

1. **Start Minikube**:

   Make sure Minikube is running. You can start Minikube using Docker as the driver:

   ```bash
   minikube start --driver=docker

Set Up Kubernetes Context
`kubectl config use-context minikube`

make folder and put `main.tf` there 

then run 
`terraform init`

#### Plan the Deployment
`terraform plan`

#### Apply the Terraform Configuration:
`terraform apply`

#### Check All Pods in the Istio System Namespace
`kubectl get pods -n istio-system`

#### Check All Services in the Istio System Namespace
`kubectl get svc -n istio-system`

#### Check All Pods in the Sample Application Namespace
`kubectl get pods -n sample-app`

#### Check the Status of the HTTPD Service
`kubectl get svc -n sample-app`

#### Check Ingress Rules
`kubectl get ingress -n sample-app`




