----------------#TASK DEFINITION ------------------------

resource "aws_ecs_task_definition" "task4" {
  family                   = "task4"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "${data.aws_iam_role.ecs-task.arn}"

  container_definitions = jsonencode([
    {
      name   = "react5-container"
      image  = "875525659788.dkr.ecr.us-east-1.amazonaws.com/service5:latest" 
      cpu    = 256
      memory = 512
      portMappings = [
        {
          containerPort = 80

        }
      ]
    }
  ])
}


-------------------# ECS SERVICE 5----------------------------


resource "aws_ecs_service" "svc4" {
  name            = "react5-Service"
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.task4.id}"
  desired_count   = 2
  launch_type     = "FARGATE"


  network_configuration {
    subnets          = ["${aws_subnet.pub-a.id}", "${aws_subnet.pub-b.id}"]
    security_groups  = ["${aws_security_group.sg3.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.tg4-group.arn}"
    container_name   = "react5-container"
    container_port   = "80"
  }
}


---------------------# CODEBUILD ------------------------------

resource "aws_codebuild_project" "dr_docker4_build4" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "dr_docker4_build4"
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild_role.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    
    type                   = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/arjit547/twopipline.git"
    git_clone_depth = 1
  }
}

-------------------------# PIPELINE ---------------------------------

resource "aws_codepipeline" "dr_pipeline4" {
  name     = "dr_pipeline4"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }
  # SOURCE
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "arjit547"
        Repo       = "twopipline"
        Branch     = "main"
        OAuthToken = "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"
      }
    }
  }
  # BUILD
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = "dr_docker4_build4"
      }
    }
  }
  # DEPLOY
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = "clusterDev"
        ServiceName = "react5-Service"
        FileName    = "imagedefinitions5.json"
      }
    }
  }
}


----------------------------# AUTO SCALING GROUP --------------------

resource "aws_appautoscaling_target" "ecs_target4" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/clusterDev/react5-Service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

---------------------------# ASG POLICY -----------------------------

resource "aws_appautoscaling_policy" "scale_up_policy4" {
  name               = "scale_up_policy4"
  depends_on         = [aws_appautoscaling_target.ecs_target4]
  service_namespace  = "ecs"
  resource_id        = "service/clusterDev/react5-Service"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}





resource "aws_appautoscaling_policy" "scale_down_policy4" {
  name               = "scale_down_policy4"
  depends_on         = [aws_appautoscaling_target.ecs_target4]
  service_namespace  = "ecs"
  resource_id        = "service/clusterDev/react5-Service"
  scalable_dimension = "ecs:service:DesiredCount"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"
    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}



--------------------------CLOUDWATCH ----------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_high4" {
  alarm_name          = "cpu-high4"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3                              
  metric_name         = "CPUUtilization4"
  namespace           = "AWS/ECS"
  period              = 60                        
  statistic           = "Maximum"
  threshold           = 80
  
  alarm_actions = [aws_appautoscaling_policy.scale_up_policy4.arn]

  
}

resource "aws_cloudwatch_metric_alarm" "cpu_low4" {
  alarm_name          = "cpu-low4"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization4"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 10
  
  alarm_actions = [aws_appautoscaling_policy.scale_down_policy4.arn]

  
}



---------------------------------------------------xxxxxx---------------------------------------------------------------------------------------------------------