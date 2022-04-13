## Creating Launch Configuration

resource "aws_launch_configuration" "as-launch" {
  image_id               = aws_ami_from_instance.new_nginx_ami.id
  instance_type          = "t2.micro"
  security_groups        = [ var.security_groupid ]
  key_name               = var.key_name
  associate_public_ip_address = true
  }



## Creating AutoScaling Group

resource "aws_autoscaling_group" "as-group" {
  name                      = "terraform_autoscaling_gp"
  launch_configuration = aws_launch_configuration.as-launch.id 
  desired_capacity = 1
  min_size = 1
  max_size = 4
  vpc_zone_identifier  = [ var.as_subnet1 ]
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_ami_from_instance" "new_nginx_ami" {
  name               = "terraform-nginx"
  source_instance_id = var.instance_id2
}

resource "aws_autoscaling_policy" "agents-scale-up" {
    name = "agents-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.as-group.name}"
}

resource "aws_autoscaling_policy" "agents-scale-down" {
    name = "agents-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.as-group.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu-high-alarm1" {
  alarm_name                = "cpu-high"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "60"
  alarm_description         = "This metric monitors ec2 cpu utilization"


  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as-group.name
  }

   alarm_actions     = [aws_autoscaling_policy.agents-scale-up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu-low-alarm2" {
  alarm_name                = "cpu-low"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "40"
  alarm_description         = "This metric monitors ec2 cpu utilization"


  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as-group.name
  }

   alarm_actions     = [aws_autoscaling_policy.agents-scale-down.arn]
}
