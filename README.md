# Todo App – Full Stack Microservices Project

This project is a **Dockerized full‑stack Todo application** built with:

* **Backend Microservices**

  * Auth Service (Node.js + Express)
  * Todo Service (Node.js + Express)
  * API Gateway (Node.js + Express + http-proxy-middleware)
* **Frontend**

  * React (Vite or CRA)
* **Docker**

  * Multi‑service setup with `docker-compose`
  * Each service isolated in its own container

---

## ✅ Features

* User authentication (JWT‑based)
* Create / Update / Delete Todos
* API Gateway routing
* React frontend
* Environment‑based configuration
* Fully containerized microservice architecture

---

## ✅ Folder Structure

```
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
│   ├── src/
│   └── package.json
├── docker-compose.yml
└── README.md (this file)
```

---

## ✅ Prerequisites

Make sure you have installed:

### **1. Node.js (optional for local dev)**

[https://nodejs.org/](https://nodejs.org/)

### **2. Docker Desktop**

[https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

### **3. Git (optional)**

[https://git-scm.com/](https://git-scm.com/)

```
VITE_API_URL=http://localhost:4001
```

---

## ✅ Docker Setup

Everything runs using `docker-compose`.

### **docker-compose.yml** (example overview)

```
version: "1.0"

services:
  userauth:
    build: ./Services/auth-services
    container_name: userauth_service
    networks:
      - appnet

  todo:
    build: ./Services/todo-services
    container_name: todo_service
    networks:
      - appnet

  gateway:
    build: ./Services/Gateway
    container_name: gateway_service
    ports:
      - "4001:3000"
    depends_on:
      - userauth
      - todo
    networks:
      - appnet

  frontend:
    build: ./Frontend
    container_name: frontend_app
    ports:
      - "5172:80"
    depends_on:
      - gateway
    networks:
      - appnet

networks:
  appnet:
```

---

## ✅ How to Run the Entire Project

This is the fun part — everything spins up with **one command**.

### **1. Build and start containers**

```
docker-compose up --build
```

### **2. Stop containers**

```
docker-compose down
```

### **3. View running containers**

```
docker ps
```

---

## ✅ Accessing the Application

Once the containers are running:

Backend services are internal — frontend communicates only through Gateway.

---

## ✅ API Gateway Routes

### **Auth Routes (no JWT)**

```
POST /auth/register
POST /auth/login
```

### **Todo Routes (JWT protected)**

```
GET /todos
POST /todos
PUT /todos/:id
DELETE /todos/:id
```

---

## ✅ Development Tips

* Use `.env` files for service configuration
* Inside Docker, use container names (NOT localhost) for communication
* Rebuild containers after changing dependencies:

```
docker-compose up --build
```

* Logs for a specific service:

```
docker logs gateway_service
```

---

## ✅ Common Issues

### ❌ "Connection refused" when services talk to each other

Use:

```
http://userauth:3001
ttp://todo:3002
```

✅ Do NOT use localhost.

### ❌ "404 after refresh" in React + Nginx

Add `try_files` rule in Nginx.

### ❌ "Ports already in use"

Stop whatever is running on your host:

```
npx kill-port 5172
```

---

## ✅ Deployment (Optional)

You can deploy using:

* Docker Hub + VPS
* Render
* Railway
* AWS ECS
* Docker Swarm

---

## ✅ Final Thoughts

Your Todo App is fully containerized, scalable, and split into clean microservices. This README gives you everything you need to:

* Run it locally
* Understand the structure
* Build on top of it
* Deploy it later
