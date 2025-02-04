# Kubernetes WordPress Deployment

This project sets up a single-node Kubernetes cluster on Azure using Terraform and Kubespray. It then deploys a WordPress application with MySQL and PhpMyAdmin using Helm.

## Prerequisites
- Azure account with sufficient permissions
- SSH key pair (`~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`)

## Steps
1. Clone this repository.
2. Run `bash scripts/bootstrap.sh` to deploy the infrastructure and application.
3. Access:
   - WordPress: `http://<public-ip>/wordpress`
   - PhpMyAdmin: `http://<public-ip>/dbadmin`
4. Update `/etc/hosts` for local testing:
   ```bash
   <public-ip> candidate-name.maxtld.dev