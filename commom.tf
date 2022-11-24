----------------------#LOADBALANCER---------------------------

resource "aws_lb" "app-lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg2.id]
  subnets            = ["${aws_subnet.pub-a.id}", "${aws_subnet.pub-b.id}"]

}

-------------------------#TARGETGROUP - 1 ---------------------

resource "aws_lb_target_group" "tg-group" {     
  name        = "tg-group"
  port        = "80"
  protocol    = "HTTP"                                                #this target_group attach with first SERVICE-1
  vpc_id      = "${aws_vpc.createVPC.id}"
  target_type = "ip"

}

-------------------------#LISTENER-------------------------------

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "80"
  protocol          = "HTTP"
                                                                   #listener should be one 
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.tg-group.arn
      }

      
      

      
    }
  }
}



-------------------------#TARGETGROUP - 2---------------------------------

resource "aws_lb_target_group" "tg1-group" {     
  name        = "tg1-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.createVPC.id}"
  target_type = "ip"

  

}
                                                                                   #THIS target_group AND aws_lb_listener_rule attach with SERVICE-2
-------------------------------#LISTENER-RULE-1-----------------------------

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.lb-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg1-group.arn
  }

  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }

  condition {
    query_string {
      key   = "health"
      value = "check"
    }
  }
}


----------------------------#TARGETGROUP - 3 -------------------------

resource "aws_lb_target_group" "tg2-group" {     
  name        = "tg2-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.createVPC.id}"
  target_type = "ip"

  
}

---------------------------#LISTENER-RULE-2 ------------------------------                  #THIS target_group AND aws_lb_listener_rule attach with SERVICE-3

resource "aws_lb_listener_rule" "static1" {
  listener_arn = aws_lb_listener.lb-listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg2-group.arn
  }

  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }

  condition {
    query_string {
      key   = "ipl"
      value = "mi"
    }
  }
}


-------------------#TARGETGROUP - 4 ---------------------

resource "aws_lb_target_group" "tg3-group" {     
  name        = "tg3-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.createVPC.id}"
  target_type = "ip"

  

}


----------------------#LISTENER-RULE-3 ---------------------      #THIS target_group AND aws_lb_listener_rule attach with SERVICE-4

resource "aws_lb_listener_rule" "static2" {
  listener_arn = aws_lb_listener.lb-listener.arn
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg3-group.arn
  }

  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }

  condition {
    query_string {
      key   = "value"
      value = "service"
    }
  }
}


----------------------#TARGETGROUP - 5 -------------------------------

resource "aws_lb_target_group" "tg4-group" {     
  name        = "tg4-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.createVPC.id}"
  target_type = "ip"

  

}

----------------------#LISTENER-RULE-4 ----------------------------------     #THIS target_group AND aws_lb_listener_rule attach with SERVICE-5

resource "aws_lb_listener_rule" "static3" {
  listener_arn = aws_lb_listener.lb-listener.arn
  priority     = 97

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg4-group.arn
  }

  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }

  condition {
    query_string {
      key   = "local"
      value = "host"
    }
  }
}



---------------------#TARGETGROUP - 6 ----------------------------

resource "aws_lb_target_group" "tg5-group" {     
  name        = "tg5-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.createVPC.id}"
  target_type = "ip"

  

}

----------------------#LISTENER-RULE-5 ----------------------------------     #THIS target_group AND aws_lb_listener_rule attach with SERVICE-6


resource "aws_lb_listener_rule" "static4" {
  listener_arn = aws_lb_listener.lb-listener.arn
  priority     = 96

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg5-group.arn
  }

  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }

  condition {
    query_string {
      key   = "logic"
      value = "answer"
    }
  }
}



----------------------------------------------xxxxxx------------------------------------------------------------------------------------------------------