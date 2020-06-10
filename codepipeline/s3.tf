resource "aws_kms_key" "vault_s3_kms_key" {
  description             = "Key to encrypt contents of the bucket for pipeline"
  deletion_window_in_days = 10
}

resource "aws_kms_grant" "kms_se_grant" {
  name              = "kms_s3_grant"
  key_id            = aws_kms_key.vault_s3_kms_key.key_id
  grantee_principal = aws_iam_role.codepipeline-role.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "DescribeKey", "ReEncryptFrom", "ReEncryptTo"]
}


resource "aws_s3_bucket" "s3_codebuild_vault" {
  bucket        = "pipeline_source_output"
  acl           = "private"
  force_destroy = true
}
