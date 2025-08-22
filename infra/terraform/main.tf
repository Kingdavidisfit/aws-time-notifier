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

#attaching Lambda execution role for Cloudwatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#inline policy for SNS Publish permissions
resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "lambda_sns_publish"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "sns:Publish",
      Resource = aws_sns_topic.time_notifier_topic.arn
    }]
  })
}

#Lambda Function
resource "aws_lambda_function" "time_notifier" {
  filename         = "${path.module}/lambda.zip"
  function_name    = "PhoenixTimeNotifier"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  # Env var: pass SNS topic to Lambda
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.time_notifier_topic.arn
    }
  }
}


# SNS Topic and subscription
resource "aws_sns_topic" "time_notifier_topic" {
  name = "time-notifier-topic"
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.time_notifier_topic.arn
  protocol  = "email"
  endpoint  = "davidobamehinti@gmail.com"
}

#EventBridge Rule - scheduler
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "time_notifier_schedule"
  schedule_expression = "rate(5 minutes)" # change to 30mins to 1hr eventually
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "time_notifier_lambda"
  arn       = aws_lambda_function.time_notifier.arn
}

# Permission for EventBridge to trigger Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.time_notifier.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn

}