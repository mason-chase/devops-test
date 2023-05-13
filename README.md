# DevOps Test

## Must do:

1. [GitOps Principles](https://en.wikipedia.org/wiki/DevOps#GitOps)
2. Document your solution

## Requirements and Step


1. Createa Terraform script that bootstrap a 3 nodes OpenShift clusters on Vagrant
2. Setup a OpenEDX application in a kuberenete cluster that is deployed on the OpenShift cluster
3. Create a gitlab CI/CD pipeline that commits to openEdx source code is automatically deployed to the cluster using FluxCD

### 1. Terraform and OpenShift:

- Write a Terraform script that sets up a 3-node OpenShift cluster on Vagrant. The script should configure the necessary virtual machines, networking, and OpenShift components.
- Demonstrate the deployment of the OpenShift cluster using the Terraform script.
- Explain the key components of an OpenShift cluster and their roles.

### 2. OpenEDX Application in Kubernetes:

- Set up a Kubernetes cluster on the OpenShift cluster created in the previous step.
- Deploy an OpenEDX application on the Kubernetes cluster. This should include setting up the necessary pods, services, and any required persistent storage.
- Test the application to ensure it is running correctly on the Kubernetes cluster.

### 3. GitLab CI/CD Pipeline with FluxCD:

- Create a GitLab repository for an OpenEDX application's source code.
- Set up a GitLab CI/CD pipeline that triggers on commits to the OpenEDX source code repository.
- Configure the pipeline to automatically deploy the updated code to the OpenShift cluster using FluxCD, a GitOps tool.
- Demonstrate the pipeline in action by making a change to the OpenEDX source code and observing the automatic deployment to the OpenShift cluster.

## Delivery
- Clone/copy this repository into a new Github repository and add your result, then share the result with user: `mason-chase` on GitHub in private mode.
