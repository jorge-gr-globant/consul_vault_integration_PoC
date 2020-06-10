variable "build_log_group_name" {
  default = "codebuild_group"
}

variable "build_log_stream_name" {
  default = "codebuild_stream"
}

variable "source_bucket_key" {
  default = "source"
}

# Git vars
variable "github-owner" {
  default = "jorge-gr-globant"
}

variable "github-repo" {
  default = "consul_vault_integration_PoC"
}

variable "github-branch" {
  default = "master"
}
