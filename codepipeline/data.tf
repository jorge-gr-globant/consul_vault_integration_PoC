data "aws_vpc" "selected" {
  tags = {
    Name = "consul-sandbox-vpc"
    Project         = "consul"
    Environment    = "sandbox"
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Project         = "consul"
    Environment    = "sandbox"
    Tier           = "private"
  }
}

data "aws_subnet" "selected" {
  id       = each.value
  for_each = data.aws_subnet_ids.selected.ids
}

data "aws_caller_identity" "current" {}
