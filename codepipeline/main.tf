resource "aws_codepipeline" "codepipeline" {
  name     = "codepipeline-project"
  role_arn = aws_iam_role.codepipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.s3-codebuild-vault.bucket
    type     = "S3"
    encryption_key {
      id   = aws_kms_key.vault_s3_kms_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner  = var.github-owner
        Repo   = var.github-repo
        Branch = var.github-branch
      }
    }
  }

  stage {
    name = "build_stage"

    action {
      name            = "Build_consul_AMI"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"
      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }
}
