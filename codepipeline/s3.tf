resource "aws_kms_key" "vault_s3_kms_key" {
  description             = "Key to encrypt contents of the bucket for vault pipeline"
  deletion_window_in_days = 10
}

resource "aws_kms_grant" "kms_vault_grant" {
  name              = "kms-vault-grant"
  key_id            = aws_kms_key.vault_s3_kms_key.key_id
  grantee_principal = aws_iam_role.codepipeline-role.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "DescribeKey", "ReEncryptFrom", "ReEncryptTo"]
}


resource "aws_s3_bucket" "s3-bucket" {
  bucket        = "test-s3-pipeline-xyz"
  acl           = "private"
  force_destroy = true
}
