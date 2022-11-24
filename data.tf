data "aws_iam_role" "ecs-task" {
  name = "ecsTaskExecutionRole"
}



#first we create data on iam role through console