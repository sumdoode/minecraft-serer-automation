provider "aws" {
  region = "us-east-1"
}

# Generate a new SSH key pair
resource "tls_private_key" "minecraft_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "minecraft" {
  key_name   = "minecraftkey"
  public_key = tls_private_key.minecraft_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.minecraft_key.private_key_pem
  filename = "${path.module}/minecraftkey_gen.pem"
  file_permission = "0400"
}

# Look up latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Create security group for Minecraft + SSH
resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft_sg"
  description = "Allow SSH and Minecraft traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EC2 instance
resource "aws_instance" "minecraft_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.minecraft.key_name
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]

  tags = {
    Name = "minecraft-server"
  }
}

# Output the IP address
output "instance_public_ip" {
  value = aws_instance.minecraft_server.public_ip
}
