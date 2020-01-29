resource "aws_api_gateway_rest_api" "api" {
  name = "rubber-stamp"
}

resource "aws_api_gateway_resource" "welcome" {
  path_part   = "welcome"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "get-welcomed" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.welcome.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "welcome-integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.welcome.id
  http_method             = aws_api_gateway_method.get-welcomed.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_welcome.invoke_arn
}

resource "aws_api_gateway_resource" "approved" {
  path_part   = "approved"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_method" "get-approved" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.approved.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "approved-integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.approved.id
  http_method             = aws_api_gateway_method.get-approved.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_approved.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda_welcome" {
  statement_id  = "AllowExecutionFromAPIGatewayWelcome"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_welcome.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.get-welcomed.http_method}${aws_api_gateway_resource.welcome.path}"
}
resource "aws_lambda_permission" "apigw_lambda_approved" {
  statement_id  = "AllowExecutionFromAPIGatewayApproved"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_approved.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.get-approved.http_method}${aws_api_gateway_resource.approved.path}"
}


resource "aws_api_gateway_deployment" "rubber-stamp-deployment" {
  depends_on = [aws_api_gateway_integration.approved-integration,aws_api_gateway_integration.welcome-integration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"

}
