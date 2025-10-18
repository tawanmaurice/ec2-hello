# Terraform EC2 Hello World 🌍

This project deploys a simple **Amazon EC2 (Amazon Linux 2)** instance in the default VPC.  
The instance auto-installs Apache and serves a “Hello from Terraform” web page.

---

## 🚀 What It Creates
- EC2 instance (`t2.micro`)
- Security Group: allows HTTP (80) + SSH (22)
- User data script to:
  - Update the system
  - Install Apache
  - Create a `index.html` with a greeting
  - Start the web server
- Terraform outputs:
  - Public IP
  - Clickable Hello URL

---

## 🔧 Usage

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
terraform output -raw hello_url

