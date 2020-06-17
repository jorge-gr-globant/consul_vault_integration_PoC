resource "aws_iam_role" "codepipeline-role" {
  name = "codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com",
        "Service": "codebuild.amazonaws.com",
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline-policy" {
  name = "codepipeline-policy"
  role = aws_iam_role.codepipeline-role.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    { 
      "Sid": "codebuild",
      "Effect": "Allow",
      "Action": [
        "codebuild:*"
      ],
      "Resource": "arn:aws:codebuild:${var.aws_region}:${data.aws_caller_identity.current.account_id}:project/build_project"
    },
    {
      "Sid": "s3",
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:network-interface/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": ${jsonencode(values(data.aws_subnet.selected)[*].arn)},
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
    },
    {
      "Sid": "iam",
      "Effect": "Allow",
      "Action": [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:GetInstanceProfile",
          "iam:PassRole",
          "iam:CreateRole",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:CreateInstanceProfile",
          "iam:AddRoleToInstanceProfile"
      ],
      "Resource": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
      ]
    },
    {
      "Sid": "lambda",
      "Effect": "Allow",
      "Action": [
        "lambda:Get*",
        "lambda:List*",
        "lambda:CreateFunction",
        "lambda:InvokeFunction",
        "lambda:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "logs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.codepipeline-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
