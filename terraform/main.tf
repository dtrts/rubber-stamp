provider "aws" {
  profile = "aws"
  region  = "eu-west-2"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


resource "aws_iam_role" "lambda_role" {
  name = "rubber-stamp-lambda-execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda_welcome" {
  function_name    = "rs-welcome"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  filename         = "../lambda/rs-welcome/code.zip"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../lambda/rs-welcome/code.zip")
}

resource "aws_lambda_function" "lambda_approved" {
  function_name    = "rs-approved"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  filename         = "../lambda/rs-approved/code.zip"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("../lambda/rs-approved/code.zip")
}
