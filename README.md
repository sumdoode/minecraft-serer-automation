# minecraft-serer-automation
cs312-final-project
# Minecraft Server Deployment (Automated)

##  Overview

This project automates the provisioning and configuration of a Minecraft Java Edition server on AWS EC2 using **Terraform** and **Ansible**.

- Terraform provisions an EC2 instance and generates a new SSH key
    
- Ansible installs Java 22 and configures the Minecraft server to auto-start
    
- The server is ready to accept client connections on port `25565`
    

---

##  Requirements

### Software

- Terraform >= 1.3
    
- Ansible >= 2.10
    
- AWS CLI (configured with Learner Lab credentials)
    
- Python 3 and `boto3` (if using dynamic inventories)
    

### Configuration

- You do **not** need to manually create any AWS resources
    
- No use of AWS Console, no SSHing manually
    

### CLI Access

Ensure you have:

```bash
aws configure
# Then enter your access key, secret key, region (e.g. us-east-1)
```

---

##  File Structure

```
.
├── main.tf                 # Terraform infrastructure
├── minecraft_playbook.yml # Ansible automation script
├── minecraftkey.pem       # Auto-generated private key
├── README.md              # This file
```

---

##  Setup Instructions

### 1. Provision Infrastructure with Terraform

```bash
terraform init
terraform apply
```

After confirmation, Terraform will output:

- `minecraftkey.pem` private key
    
- `instance_public_ip` (save this IP)
    

### 2. Configure Server with Ansible

```bash
ansible-playbook -i <public_ip>, minecraft_playbook.yml \
  --private-key minecraftkey.pem \
  -u ec2-user
```

Replace `<public_ip>` with the one Terraform gave you.

---

##  Connecting to Minecraft Server

### Minecraft Client

1. Open Minecraft Java Edition
    
2. Go to Multiplayer > Add Server
    
3. Use:
    
    - IP: `<public_ip>`
        
    - Port: `25565`
        

### OR Test With Nmap

```bash
nmap -sV -Pn -p T:25565 <public_ip>
```

Expected result:

```
25565/tcp open  minecraft?
```

---

##  Troubleshooting

- Make sure port 25565 is open in the EC2 security group
    
- Confirm Java version is >= 22 by checking `java -version` inside the instance (via Ansible)
    
- Run `sudo journalctl -u minecraft` if the service fails to start
    

---

##  References

- [Minecraft Server JAR](https://www.minecraft.net/en-us/download/server)
    
- [Amazon Corretto Java 22](https://docs.aws.amazon.com/corretto/latest/corretto-22-ug/)
    
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
    
- [Ansible Docs](https://docs.ansible.com/)
    

---

