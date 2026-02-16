terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.31.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


// Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "smit-vpc"
  }
}

// Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "smit-igw"
  }
}

// Create a public subnet 1
resource "aws_subnet" "public" {
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "smit-public-subnet-1"
  }
}

// Create a public subnet 2
resource "aws_subnet" "public_2" {
  availability_zone       = "us-east-1b"
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "smit-public-subnet-2"
  }
}


//create a private subnet
resource "aws_subnet" "private" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  tags = {
    Name = "smit-private-subnet"
  }
}

// Create a route table for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

// Create a route table for the private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "private-rt" }
}

// Route for private subnet to access the internet via NAT Gateway
resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

// Associate the private subnet with its route table
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

// Create a Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id # NAT must be in PUBLIC subnet
  tags          = { Name = "nat-gateway" }
}

// Create ALB
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false                 # true if private LB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]    # list of public subnet IDs

  enable_deletion_protection = false

  tags = {
    Name = "app-alb"
  }
}

//rule
resource "aws_lb_listener_rule" "gateway_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

//listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

//frontend target group
resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

//gateway target group
resource "aws_lb_target_group" "gateway_tg" {
  name        = "gateway-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path    = "/api/health"
    matcher = "200"
  }
}




// create a security group for ALB
resource "aws_security_group" "alb_sg" {
  name   = "application-load-balancer-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "application-load-balancer-sg"
  }
}



// create a security group for the todo app
resource "aws_security_group" "public_sg" {
  name   = "public-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "Allow load balancer to call Gateway"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "public-sg"
  }
}

// create a security group for the frontend
resource "aws_security_group" "frontend_sg" {
  name   = "frontend-sg"
  vpc_id = aws_vpc.main.id

  # Allow HTTP from internet
  ingress {
    description = "Allow HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS (optional but recommended)
  ingress {
    description = "Allow HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-sg"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Allow only port 5000 and 5001 from public-sg"
  vpc_id      = aws_vpc.main.id

  # Allow Gateway → Auth (port 5001)
  ingress {
    description     = "Allow gateway to auth service (port 5000)"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id] # ✅ Only SG
  }

  # Allow Gateway → Todo (port 5001)
  ingress {
    description     = "Allow gateway to todo service (port 5001)"
    from_port       = 5001
    to_port         = 5001
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id] # ✅ Only SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private-sg"
  }
}