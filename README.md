# Todo App – Full Stack Microservices 🚀

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-16.x-green?logo=node.js)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-18.x-blue?logo=react)](https://reactjs.org/)
[![Terraform](https://img.shields.io/badge/Terraform-1.x-blue?logo=terraform)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

> A Dockerized full-stack Todo application with microservices architecture, JWT authentication, React frontend, and optional Terraform-based AWS ECS deployment.

---

## 🏗 Architecture

- **Backend Microservices** (Node.js + Express)
  - Auth Service – JWT-based authentication
  - Todo Service – CRUD operations
  - API Gateway – Routes requests & handles auth

- **Frontend**
  - React (Vite)
  - Communicates only via API Gateway

- **Containerization**
  - Docker for each service
  - Docker Compose for local development

- **Cloud Infrastructure (Optional)**
  - Terraform for AWS ECS (Fargate)
  - ALB, VPC, ECR, S3 backend, DynamoDB

---

## ✅ Features

- User authentication (JWT)
- CRUD for Todos
- API Gateway routing
- React frontend
- Environment-based configuration
- Microservices & Docker containerization
- Terraform-based cloud deployment (AWS ECS)

---

## 📁 Folder Structure
root/
├── Services/
│   ├── auth-services/
│   │   ├── Dockerfile
│   │   ├── index.js
│   │   ├── package.json
│   │   └── .env
│   ├── todo-services/
│   │   ├── Dockerfile
│   │   ├── index.js
│   │   ├── package.json
│   │   └── .env
│   └── Gateway/
│       ├── Dockerfile
│       ├── index.js
│       ├── package.json
│       └── .env
├── Frontend/
│   ├── Dockerfile
│   ├── package.json
│   └── src/
│       ├── main.jsx
│       └── components/
│           ├── TodoList.jsx
│           └── TodoItem.jsx
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── ecs.tf
├── docker-compose.yml
└── README.md
---

## 🐳 Local Development

### Start containers:

```bash
docker-compose up --build


* Start containers:
docker-compose down

🌍 Access URLs

Frontend: http://localhost:5172

Gateway: http://localhost:4001

Backend services communicate internally via Docker network.

🔀 API Routes
Auth Routes (Public)
POST /auth/register
POST /auth/login

Todo Routes (JWT Protected)
GET /todos
POST /todos
PUT /todos/:id
DELETE /todos/:id

⚙ Development Tips

Use .env for local configs

Use container names (NOT localhost) inside Docker

Rebuild after dependency changes:

docker-compose up --build


View logs:

docker logs gateway_service

🏗 Terraform – AWS Deployment

Terraform provisions:

ECS Cluster (Fargate), Task Definitions & Services

Application Load Balancer

Public & Private Subnets, NAT & IGW

Amazon ECR for Docker images

S3 backend for Terraform state

DynamoDB for state locking

Deploy Steps:
cd terraform
terraform init
terraform validate
terraform plan
terraform apply


Terraform outputs ALB DNS URL to access your deployed app.

❗ Common Issues

Connection refused: Use container names (http://userauth:3001, http://todo:3002) inside Docker.

Ports in use:

npx kill-port 5172


GitHub 100MB limit: Do not commit .terraform/, terraform.tfstate, node_modules/, or .env.

✅ Deployment Options

AWS ECS (Recommended)

Docker Hub + VPS

Render / Railway / Docker Swarm

🎯 Final Thoughts

This project demonstrates:

Microservices & Docker containerization

API Gateway routing

JWT authentication

Terraform-based Infrastructure as Code

AWS ECS Fargate production deployment
