resource "aws_security_group" "pipeline_default" {
  name        = "pipeline-sg"
  description = "Allow access to pipeline"
  vpc_id      = data.aws_vpc.selected.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_all_out" {
  description = "Allow any outbound"
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"

  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.pipeline_default.id
}
