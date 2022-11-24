-----------------# ECS CLUSTER-------------

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "clusterDev"
}