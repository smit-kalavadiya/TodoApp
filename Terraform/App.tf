// create an ECR repository for the todo app
resource "aws_ecr_repository" "gateway_repo" {
  name = "gateway-app"
}

resource "aws_ecr_repository" "todos_repo" {
  name = "todos-app"
}

resource "aws_ecr_repository" "auth_repo" {
  name = "auth-app"
}

resource "aws_ecr_repository" "frontend_repo" {
  name = "frontend-app"
}

// create an ECS cluster for the todo app
resource "aws_ecs_cluster" "main" {
  name = "todo-cluster"
}


// create an IAM role for the ECS task execution
data "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"
}


// create an ECS task definition for the frontend app
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "frontend"
      image = "${aws_ecr_repository.frontend_repo.repository_url}:latest"

      portMappings = [{
        name          = "frontend-port" # IMPORTANT
        containerPort = 80
        protocol      = "tcp"
      }]
    }
  ])
}

resource "aws_cloudwatch_log_group" "todo_logs" {
  name              = "/ecs/todo-task"
  retention_in_days = 7
}

// create an ECS task definition for the todo app
resource "aws_ecs_task_definition" "gateway" {
  family                   = "gateway-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "gateway-container"
      image = "${aws_ecr_repository.gateway_repo.repository_url}:latest"

      portMappings = [{
        name          = "gateway-port" # IMPORTANT
        containerPort = 3000
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.todo_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "gateway"
        }
      }
      environment = [
        {
          name  = "JWT_SECRET"
          value = "secretpassword"
        },
        {
          name  = "GATEWAY_PORT"
          value = "3000"
        },
        {
          name  = "AUTH_SERVICE_URL"
          value = "http://auth:5000/auth"
        },
        {
          name  = "TODO_SERVICE_URL"
          value = "http://todo:5001/todos"
        }
      ]
    }
  ])
}

// create an ECS task definition for the auth app
resource "aws_ecs_task_definition" "auth" {
  family                   = "auth-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "auth-container"
      image = "${aws_ecr_repository.auth_repo.repository_url}:latest"

      portMappings = [{
        name          = "auth-port" # IMPORTANT
        containerPort = 5000
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.todo_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "auth"
        }
      }
      environment = [
        {
          name  = "PORT"
          value = "5000"
        },
        {
          name  = "MONGO_URI"
          value = ""
        },
        {
          name  = "JWT_SECRET"
          value = "secretpassword"
        }
      ]
    }
  ])
}



// create an ECS task definition for the todos app
resource "aws_ecs_task_definition" "todo" {
  family                   = "todo-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "todo-container"
      image = "${aws_ecr_repository.todos_repo.repository_url}:latest"

      portMappings = [{
        name          = "todos-port" # IMPORTANT
        containerPort = 5001
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.todo_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "todo"
        }
      }
      environment = [
        {
          name  = "MONGO_URI"
          value = ""
        },
        {
          name  = "JWT_SECRET"
          value = "secretpassword"
        }
      ]
    }
  ])
}



// create a private DNS namespace for the todo app
resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "internal"
  vpc  = aws_vpc.main.id
}



// create an ECS service for the todo app
resource "aws_ecs_service" "gateway" {
  name            = "gateway-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.gateway.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.public_sg.id]
    assign_public_ip = true
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn

    service {
      port_name = "gateway-port"

      client_alias {
        dns_name = "gateway"
        port     = 3000
      }
    }
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.gateway_tg.arn
    container_name   = "gateway-container"
    container_port   = 3000
  }
  depends_on = [
  aws_lb_listener_rule.gateway_rule
]
}




// create an ECS service for the auth app
resource "aws_ecs_service" "auth" {
  name            = "auth-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.auth.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private.id]
    security_groups  = [aws_security_group.private_sg.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn

    service {
      port_name = "auth-port"

      client_alias {
        dns_name = "auth"
        port     = 5000
      }
    }
  }
}

// create an ECS service for frontend
resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.frontend_sg.id]
    assign_public_ip = true
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn

    service {
      port_name = "frontend-port"

      client_alias {
        dns_name = "frontend"
        port     = 80
      }
    }
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "frontend"
    container_port   = 80
  }
  
}


// create an ECS service for the todos app
resource "aws_ecs_service" "todos" {
  name            = "todos-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.todo.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private.id]
    security_groups  = [aws_security_group.private_sg.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.main.arn

    service {
      port_name = "todos-port"

      client_alias {
        dns_name = "todo"
        port     = 5001
      }
    }
  }
}