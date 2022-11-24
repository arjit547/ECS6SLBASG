--------------------- #Security-Group for ECS Fargate --------------------------------


resource "aws_security_group" "sg3" {
  name        = "reactfinal-securitygroup"
  description = "Port "
  vpc_id      = aws_vpc.createVPC.id

  

  ingress {
    description      = "Allow Port "
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "Allow all ip and ports outboun"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




-------------------------------------#Security-Group for Load Balancer ----------------------------------


resource "aws_security_group" "sg2" {      
  name        = "react-server-alb"
  description = "Port tcp"
  vpc_id      = aws_vpc.createVPC.id

  ingress {
    description      = "Allow Port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "Allow all ip and ports outboun"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
