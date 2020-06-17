# Set the VPC
data "aws_vpc" "selected" {
  default = true
}

# Get the private subnet id's from the selected vpc
data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
}

data "aws_subnet" "selected" {
  id       = each.value
  for_each = data.aws_subnet_ids.selected.ids
}

data "aws_caller_identity" "current" {}
