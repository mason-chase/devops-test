#!/bin/bash

# Define variables
CANDIDATE_NAME="sajjad"  # Set your candidate name here
DOMAIN="${CANDIDATE_NAME}.maxtld.dev"  # Domain for the application
HELM_CHART_REPO="https://charts.bitnami.com/bitnami"
# Define colors
NC='\033[0m' # No Color
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'

# Ensure Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform not found! Install it from https://developer.hashicorp.com/terraform/downloads${NC}"
    exit 1
fi

# Ensure Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found! Install it from https://aka.ms/installazurecliwindows${NC}"
    exit 1
fi
az login
# # Login to Azure (if not already logged in)
# if ! az account show &> /dev/null; then
#     echo -e "${CYAN}🔐 Logging into Azure...${NC}"
#     echo -e "${YELLOW}👉 A browser window will open for Azure login. If it doesn't, use the device code provided below.${NC}"
#     az login --use-device-code
#     if ! az account show &> /dev/null; then
#         echo -e "${RED}❌ Azure login failed. Please try again.${NC}"
#         exit 1
#     fi
#     echo -e "${GREEN}✅ Successfully logged into Azure.${NC}"
# else
#     echo -e "${GREEN}✅ Already logged into Azure.${NC}"
# fi

[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Step 1: Run Terraform and extract the VM IP and admin username
echo -e "${CYAN}🚀 Initializing Terraform...${NC}"
cd ../terraform || { echo -e "${RED}❌ Error: terraform directory not found.${NC}"; exit 1; }

# copy main backup file to main.tf
cp main.tmp main.tf

RESOURCE_GROUP_NAME=$(az group list --query "[0].name" -o tsv)
echo -e "${GREEN}✅ The resource group name is: $RESOURCE_GROUP_NAME${NC}"

# Update variables.tf with the new resource group name
sed -i "/variable \"resource_group_name\"/,/}/s/^  default     = \".*\"/  default     = \"$RESOURCE_GROUP_NAME\"/" variables.tf

echo -e "${GREEN}✅ Updated resource_group_name in variables.tf to: $RESOURCE_GROUP_NAME${NC}"

# Update candidate name in main.tf
sed -i "s/CANDIDATE_NAME/${CANDIDATE_NAME}/g" main.tf

echo -e "${CYAN}🚀 Initializing Terraform...${NC}"
terraform init
echo -e "${CYAN}🔧 Applying Terraform configuration...${NC}"
terraform apply -auto-approve -var="resource_group_name=$RESOURCE_GROUP_NAME"

echo -e "${CYAN}🔍 Fetching the VM IP and admin username...${NC}"
VM_PUBLIC_IP=$(terraform output -raw vm_public_ip)
VM_PRIVATE_IP=$(terraform output -raw vm_private_ip)
ADMIN_USERNAME=$(terraform output -raw admin_username)

if [[ -z "$VM_PUBLIC_IP" || -z "$VM_PRIVATE_IP" || -z "$ADMIN_USERNAME" ]]; then
  echo -e "${RED}❌ Error: Unable to retrieve VM IP or admin username from Terraform.${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Azure VM is running at Public IP: $VM_PUBLIC_IP and Private IP: $VM_PRIVATE_IP${NC}"
echo -e "${GREEN}✅ VM admin username and candidate name: $ADMIN_USERNAME${NC}"

# Step 2: Update /etc/hosts for local testing
echo -e "${CYAN}📝 Updating /etc/hosts for local testing...${NC}"
echo -e "${YELLOW}Add the following line to your /etc/hosts file:${NC}"
echo -e "${GREEN}$VM_PUBLIC_IP $DOMAIN${NC}"
read -p "Press Enter to continue after updating /etc/hosts..."

# Step 3: Connect to the VM and install dependencies
echo -e "${CYAN}🔧 Configuring the VM...${NC}"
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  $ADMIN_USERNAME@$VM_PUBLIC_IP << EOF
  sudo apt update && sudo apt upgrade -y
  sudo apt-get install --no-install-recommends -y python3 ca-certificates git make jq nmap curl uuid-runtime bc python3-pip
  sudo apt install software-properties-common -y
  echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf > /dev/null
  sudo swapoff -a
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 
EOF

# Step 4: Clone and configure Kubespray
echo -e "${CYAN}🔁 Cloning Kubespray repository...${NC}"
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  $ADMIN_USERNAME@$VM_PUBLIC_IP << EOF
  # Check if Kubespray is already cloned
  if [ -d "~/kubespray/.git" ]; then
      echo "✅ Kubespray is already cloned in ~/kubespray."
  else
      echo "🚀 Cloning Kubespray (branch: release-2.24)..."
      git clone https://github.com/kubernetes-sigs/kubespray.git ~/kubespray
      cd ~/kubespray
      git checkout v2.26.0
      echo "✅ Kubespray cloned successfully."
  fi
  cd ~/kubespray
  pip3 install --upgrade pip
  pip install -r requirements.txt 
  pip install -r contrib/inventory_builder/requirements.txt
EOF

# Step 5: Set up Kubespray inventory for a single node
echo -e "${CYAN}🔧 Configuring Kubespray inventory for single-node setup...${NC}"
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  $ADMIN_USERNAME@$VM_PUBLIC_IP << EOF
  # Check if destination directory exists
  if [ -d ~/kubespray/inventory/mycluster ]; then
      echo "✅ Inventory directory already exists at $DEST_DIR."
  else
      echo "🚀 Copying inventory directory..."
      cp -rfp ~/kubespray/inventory/sample ~/kubespray/inventory/mycluster 
      echo "✅ Inventory copied successfully."
  fi
EOF

# Step 6: Run the Kubespray Ansible playbook
echo -e "${CYAN}🎯 Running Kubespray playbook for Kubernetes setup...${NC}"
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  $ADMIN_USERNAME@$VM_PUBLIC_IP << EOF
  cd ~/kubespray/

  declare -a IPS=($VM_PRIVATE_IP)

  # Check if the IPS array is not empty
  if [ ${#IPS[@]} -gt 0 ]; then
    echo "IPS is not empty"
    CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py "${IPS[@]}"
  else
    echo "IPS is empty"
    CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py "$VM_PRIVATE_IP"
  fi
  cat inventory/mycluster/hosts.yaml
  # Check if kubectl command exists
  if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Running Ansible playbook to set up the cluster..."
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root -u "$ADMIN_USERNAME" --private-key=~/.ssh/id_rsa cluster.yml
    if [ $? -ne 0 ]; then
      echo "❌ Error: Ansible playbook failed."
      exit 1
    fi
    echo "✅ Ansible playbook executed successfully."
  else
    echo "✅ kubectl is already installed. Skipping Ansible playbook."
  fi
  mkdir ~/.kube
  sudo cp /etc/kubernetes/admin.conf ~/.kube/config
  sudo chown $ADMIN_USERNAME:$ADMIN_USERNAME ~/.kube/config 
  kubectl get po -A
EOF

# Step 7: Deploy StorageClass, PV, and PVC
echo -e "${CYAN}📦 Deploying StorageClass, PV, and PVC...${NC}"
scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ../scripts/StorageClass.yaml $ADMIN_USERNAME@$VM_PUBLIC_IP:~
scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ../scripts/StorageClass-manual.yaml $ADMIN_USERNAME@$VM_PUBLIC_IP:~
# scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ../scripts/mysql-pvc.yaml $ADMIN_USERNAME@$VM_PUBLIC_IP:~
# scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ../scripts/wordpress-pvc.yaml $ADMIN_USERNAME@$VM_PUBLIC_IP:~
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  $ADMIN_USERNAME@$VM_PUBLIC_IP << EOF
  # Create the wordpress namespace if it doesn't exist
  if ! kubectl get namespace wordpress &> /dev/null; then
    kubectl create namespace wordpress
  else
    echo "Namespace 'wordpress' already exists. Skipping creation."
  fi
  kubectl apply -f StorageClass.yaml
  kubectl apply -f StorageClass-manual.yaml
  # kubectl apply -f mysql-pvc.yaml
  # kubectl apply -f wordpress-pvc.yaml
EOF

# Step 8: Install Helm and deploy WordPress, MySQL, and PhpMyAdmin
echo -e "${CYAN}📦 Deploying Helm charts for WordPress, MySQL, and PhpMyAdmin...${NC}"
scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ../scripts/mysql-values.yaml $ADMIN_USERNAME@$VM_PUBLIC_IP:~
scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ../scripts/wordpress-values.yaml $ADMIN_USERNAME@$VM_PUBLIC_IP:~
scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ../scripts/phpmyadmin-values.yaml $ADMIN_USERNAME@$VM_PUBLIC_IP:~
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  $ADMIN_USERNAME@$VM_PUBLIC_IP << EOF
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  # Add the Bitnami Helm repository if it doesn't exist  
  if ! helm repo list | grep -q "bitnami"; then
    helm repo add bitnami $HELM_CHART_REPO
  else
    echo "Bitnami Helm repository already exists. Skipping addition."
  fi
  helm repo update

  # Install MySQL if it doesn't already exist
  if ! helm list -n wordpress | grep -q "mysql"; then
    helm install mysql bitnami/mysql --namespace wordpress --set persistence.existingClaim=mysql-pvc --values mysql-values.yaml
  else
    echo "MySQL Helm release already exists. Skipping installation."
  fi

  # Install WordPress if it doesn't already exist
  if ! helm list -n wordpress | grep -q "wordpress"; then
    helm install wordpress bitnami/wordpress --namespace wordpress --set persistence.existingClaim=wordpress-pvc --values wordpress-values.yaml
  else
    echo "WordPress Helm release already exists. Skipping installation."
  fi
  # Install phpMyAdmin if it doesn't already exist
  if ! helm list -n wordpress | grep -q "phpmyadmin"; then
    helm install phpmyadmin bitnami/phpmyadmin --namespace wordpress --values phpmyadmin-values.yaml
  else
    echo "phpMyAdmin Helm release already exists. Skipping installation."
  fi
EOF

# Step 9: Install NGINX Ingress Controller
echo -e "${CYAN}🚀 Installing NGINX Ingress Controller...${NC}"
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  $ADMIN_USERNAME@$VM_PUBLIC_IP << EOF
  # Create the ingress-nginx namespace if it doesn't exist
  if ! kubectl get namespace ingress-nginx &> /dev/null; then
    kubectl create namespace ingress-nginx
  else
    echo "Namespace 'ingress-nginx' already exists. Skipping creation."
  fi
  if ! helm repo list | grep -q "ingress-nginx"; then
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  else
    echo "ingress-nginx Helm repository already exists. Skipping addition."
  fi
  
  helm repo update
  # Install ingress-nginx if it doesn't already exist
  if ! helm list -n ingress-nginx | grep -q "ingress-nginx"; then
    helm install ingress-nginx ingress-nginx/ingress-nginx \
        --namespace ingress-nginx \
        --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
        --set controller.service.loadBalancerIP=$VM_PUBLIC_IP
  else
    echo "ingress-nginx Helm release already exists. Skipping installation."
  fi
EOF

# Step 10: Apply Ingress Rules
echo -e "${CYAN}🚀 Applying Ingress rules...${NC}"
scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ../scripts/ingress.yaml $ADMIN_USERNAME@$VM_PUBLIC_IP:~
ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  $ADMIN_USERNAME@$VM_PUBLIC_IP << EOF
  kubectl apply -f ingress.yaml
EOF

echo -e "${GREEN}✅ Deployment complete! Access WordPress at http://$VM_PUBLIC_IP/wordpress and PhpMyAdmin at http://$VM_PUBLIC_IP/dbadmin${NC}"
echo -e "${YELLOW}If you updated /etc/hosts, you can also access WordPress at http://$DOMAIN/wordpress and PhpMyAdmin at http://$DOMAIN/dbadmin${NC}"