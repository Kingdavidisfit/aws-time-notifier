provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "time_notifier" {
  filename         = "${path.module}/lambda.zip"
  function_name    = "PhoenixTimeNotifier"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
}
