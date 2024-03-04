provider "aws" {
  region = "us-east-1" 
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my_vpc"
  }
}

# Create a public subnet for the EC2 instance
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" 

  tags = {
    Name = "public_subnet"
  }
}

# Create the first private subnet for the RDS instance
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a" # Adjust to your region's AZ

  tags = {
    Name = "private_subnet1"
  }
}

# Create the second private subnet for the RDS instance in a different AZ
resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b" # Ensure this is a different AZ

  tags = {
    Name = "private_subnet2"
  }
}

# Launch an EC2 instance
resource "aws_instance" "EMC-instance" {
  ami           = "ami-06aa3f7caf3a30282" 
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.pem_key

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "my_ec2_instance_with_nginx"
  }
}

# RDS DB Subnet Group
resource "aws_db_subnet_group" "my_db_subnet_group1" {
  name       = "my_db_subnet_group1"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}

# RDS Instance
resource "aws_db_instance" "my_rds_instance" {
  identifier = "myrdsinstance"
  engine = "mysql"
  engine_version = "8.0" # Specify the desired version
  instance_class = "db.t3.micro"
  allocated_storage = 20
  username = "adminuser"
  password = "adminpassword"
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group1.name
  skip_final_snapshot = true

  tags = {
    Name = "My RDS Instance"
  }
}

# DB Subnet Group for the RDS instance
resource "aws_db_subnet_group" "my_db_subnet_group2" {
  name       = "my_db_subnet_group2"
  subnet_ids = [aws_subnet.private_subnet1.id,aws_subnet.private_subnet2.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}