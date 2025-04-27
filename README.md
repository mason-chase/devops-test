# DevOps CI/CD Test with FluxCD with .NET Back-end and Front-end

## Objectives
- **Evaluate GitOps Proficiency:** Demonstrate how you leverage FluxCD to automate deployments directly from a Git repository.
- **Kubernetes & Helm Expertise:** Deploy a .NET full-stack application (Blazor Workshop) on a single-node Kubernetes cluster.
- **CI/CD Pipeline:** Implement an end-to-end CI/CD process: CI: GitLab and CD: FluxCD.

## Must Do

1. **Understand GitOps Principles**  
   - Review the [GitOps Principles](https://en.wikipedia.org/wiki/DevOps#GitOps) and watch this [Explainer Video](https://www.youtube.com/watch?v=f5EpcWp0THw).  
   - Document your understanding and describe how these principles are applied in your solution.

2. **Kubernetes Cluster Setup**  
   - Use **Kubespray** to provision a Kubernetes cluster on a single node (acting as both control plane and worker) on an Ubuntu 22 VPS.
   - Optionally, deploy GitLab (or another Docker container host) on the same VPS if needed.

3. **FluxCD Integration for CI/CD**  
   - Install and configure **FluxCD** on your Kubernetes cluster.
   - Connect FluxCD to a Git repository where all your deployment configurations—including Helm charts—reside.
   - Ensure that any change pushed to this repository is automatically synchronized and deployed on the cluster.

4. **Helm Chart Deployment**  
   - Develop a **Helm Chart** that bootstraps the **Blazor Workshop** application from [https://github.com/dotnet-presentations/blazor-workshop](https://github.com/dotnet-presentations/blazor-workshop).  
     - The application should deploy both its back-end and single-page front-end components.
   - Configure **Ingress** resources so that the Blazor Workshop application is accessible at:  
     `https://candidate-name.maxtld.dev/frontend`
   - Configure **Ingress** resources so that the Backend Workshop application is accessible at:  
     `https://candidate-name.maxtld.dev/endpoints` with 
   - **Sentry Integration:**  
     - Register a free trial account on [Sentry](https://sentry.io/signup/?plan=am1_f&period=annual) and integrate the application.
     - Integrate source mapping from the Blazor Workshop application to Sentry to facilitate improved error diagnosis.

## Delivery Criteria

1. **Infrastructure as Code with Terraform**  
   - Create a Terraform script that automates the provisioning of the Kubernetes cluster.

2. **Additional CI/CD Enhancements**  
   - While FluxCD is the core tool, feel free to add supplementary CI/CD pipeline configurations or scripts as needed.

## Delivery Requirements

1. **Single Command Deployment**  
   - Provide a single execution script/file that bootstraps your entire environment—including cluster setup, FluxCD installation, and application deployment. This script must work on a clean Ubuntu 22 VPS.
   
2. **Idempotency**  
   - Ensure that if the VPS is erased and the script is re-run, the cluster and applications are re-provisioned to the intended state without any manual intervention.

3. **Repository and Access**  
   - Clone or copy this repository into a new private GitHub repository (Do not fork)
   - Add your complete solution and share it with the GitHub user `mason-chase`.
   - Create Pull Request and assign to the user `mason-chase`

4. **Verification**  
   - After deployment, verify that:
     - Navigating to `https://candidate-name.maxtld.dev/frontend` displays the Blazor Workshop application and it functions correctly.
     - Sentry is operational with proper error tracking and source mapping enabled.

5. **Documentation**  
   - Provide clear documentation of your solution, detailing:
     - The setup and configuration of FluxCD and the GitOps workflow.
     - How Sentry is deployed and integrated with source mapping.
     - Any additional enhancements or configurations implemented.

## Nice to do 

- **Sentry Integration:** Incorporate error tracking with Sentry, including source mapping for enhanced debugging. `https://candidate-name.maxtld.dev/sentry`
