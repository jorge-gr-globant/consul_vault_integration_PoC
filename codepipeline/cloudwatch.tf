resource "aws_cloudwatch_event_rule" "s3" {
  name        = "capture-s3-changes"
  description = "Capture s3 source changes in pipeline"

  event_pattern = <<PATTERN
{
  "detail-type": [
    "S3 state change"
  ],
  "source": [
    "aws.s3"
  ],
  "resources":[
    "${aws_s3_bucket.s3-bucket.arn}"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "CopyObject",
      "PutObject",
      "CompleteMultipartUpload"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.s3.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.validate_files.arn
}


resource "aws_lambda_function" "validate_files" {
    source_code_hash = filebase64sha256("function.zip")
    runtime = "python3.8"
    filename = "function.zip"
    function_name = "validateFiles"
    role = aws_iam_role.codepipeline-role.arn
    handler = "lambda_handler.handler"
}


resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.validate_files.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.s3.arn
}
