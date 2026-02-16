# 🚀 Todo App – Full Stack Microservices + Terraform (AWS ECS)

This project is a **Dockerized full-stack Todo application** built using a **microservices architecture**, and deployable to **AWS using Terraform + ECS + ALB**.

---

# 🏗 Architecture Overview

## 🔹 Backend Microservices (Node.js + Express)

- **Auth Service** – User registration & login (JWT)
- **Todo Service** – CRUD operations for todos
- **API Gateway** – Routes requests using http-proxy-middleware

## 🔹 Frontend

- React (Vite)
- Communicates only with API Gateway

## 🔹 Containerization

- Docker for each service
- Docker Compose for local development

## 🔹 Infrastructure (Production)

Provisioned using:

- AWS ECS (Fargate)
- Application Load Balancer (ALB)
- Amazon ECR
- Terraform (Infrastructure as Code)

---

# ✅ Features

- JWT-based Authentication
- Create / Update / Delete Todos
- API Gateway routing
- React frontend
- Environment-based configuration
- Fully containerized microservice architecture
- Infrastructure as Code (Terraform)
- ECS Fargate deployment ready

---

# 📁 Folder Structure

root/
├── Services/
│ ├── auth-services/
│ │ ├── Dockerfile
│ │ ├── index.js
│ │ ├── package.json
│ │ └── .env
│ ├── todo-services/
│ │ ├── Dockerfile
│ │ ├── index.js
│ │ ├── package.json
│ │ └── .env
│ └── Gateway/
│ ├── Dockerfile
│ ├── index.js
│ ├── package.json
│ └── .env
│
├── Frontend/
│ ├── Dockerfile
│ ├── src/
│ └── package.json
│
├── terraform/
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ ├── backend.tf
│ └── ecs.tf
│
├── docker-compose.yml
└── README.md

---

# ✅ Prerequisites

Make sure you have installed:

1. Node.js (optional for local development)
2. Docker Desktop
3. Git
4. Terraform
5. AWS CLI (configured using `aws configure`)

---

# 🐳 Local Development (Docker Compose)

## 1️⃣ Build and Start Containers

```bash
docker-compose up --build

2️⃣ Stop Services
docker-compose down

3️⃣ View Running Containers
docker ps

🌍 Local URLs

Frontend:

http://localhost:5172


API Gateway:

http://localhost:4001


Backend services are internal and communicate via Docker network.

🔀 API Routes
🔓 Auth Routes (Public)
POST /auth/register
POST /auth/login

🔐 Todo Routes (JWT Protected)
GET /todos
POST /todos
PUT /todos/:id
DELETE /todos/:id

⚙ Environment Configuration

Each service uses .env file.

Example:

PORT=3001
JWT_SECRET=your-secret-key
DB_URL=your-db-url


⚠ Never commit .env files. Use .env.example instead.

🏗 Terraform – AWS Deployment

Terraform automates AWS infrastructure provisioning.

🔐 Remote State Configuration (S3)

Example:

terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "todo-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

🚀 Deploy to AWS
1️⃣ Initialize
cd terraform
terraform init

2️⃣ Validate
terraform validate

3️⃣ Plan
terraform plan

4️⃣ Apply
terraform apply


After deployment, Terraform outputs the ALB DNS name:

http://app-alb-xxxxxxxx.us-east-1.elb.amazonaws.com


Access your app using that URL.

🐳 Docker → ECR → ECS Flow

Build Docker images

Push images to Amazon ECR

ECS pulls images from ECR

ALB routes traffic to Gateway service

Gateway routes internally to services

🧠 Production Architecture Flow

User → ALB → Gateway (ECS) → Auth / Todo Services (ECS Private Subnet)

Frontend → ALB → Gateway → Microservices

❗ Common Issues
❌ Services cannot communicate

Inside Docker use container names:

http://userauth:3001
http://todo:3002


Do NOT use localhost.

❌ GitHub Large File Error (100MB Limit)

Never commit:

.terraform/
terraform.tfstate
node_modules/
.env


Ensure proper .gitignore.

❌ Port Already in Use
npx kill-port 5172

🔐 Security Best Practices

Use AWS Secrets Manager in production

Store Terraform state in S3

Enable DynamoDB locking

Use IAM roles for ECS

Never hardcode credentials

☁ Deployment Options

AWS ECS (Recommended)

Docker Hub + VPS

Render

Railway

Docker Swarm

📈 What This Project Demonstrates

Microservices Architecture

Docker Containerization

API Gateway Pattern

JWT Authentication

Infrastructure as Code (Terraform)

AWS ECS Fargate Deployment

Load Balancer Routing

Cloud Networking (VPC, Subnets, NAT, IGW)
