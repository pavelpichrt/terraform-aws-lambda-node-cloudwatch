locals {
  build_directory_path = "${path.root}/${var.build_dir_rel_path}"
  handler_zip_name     = "${var.build_dir_rel_path}/handler.zip"
  layers_path          = "${path.root}/${var.layers_path}"
  layers_zip_name      = "${var.build_dir_rel_path}/nodejs.zip"
  function_name        = "${var.function_name}-${var.env}"
}

data "aws_iam_policy_document" "test_lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.function_name}-${var.env}-lambdaRole"
  assume_role_policy = data.aws_iam_policy_document.test_lambda_assume_role_policy.json

  tags = {
    ENV = var.env
  }
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${local.function_name}"

  tags = {
    ENV = var.env
  }
}

data "aws_iam_policy_document" "cloudwatch_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]

    resources = [aws_cloudwatch_log_group.lambda_log_group.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.lambda_log_group.arn}:*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  name   = "${var.function_name}-${var.env}-cloudwatch-policy"
  policy = data.aws_iam_policy_document.cloudwatch_role_policy_document.json
  role   = aws_iam_role.lambda_role.id
}

resource "null_resource" "nodejs_layer" {
  provisioner "local-exec" {
    working_dir = "${local.layers_path}/nodejs"
    command     = "npm install"
  }

  triggers = {
    rerun_every_time = uuid()
  }
}

data "archive_file" "nodejs_layer_package" {
  type        = "zip"
  source_dir  = local.layers_path
  output_path = local.layers_zip_name

  depends_on = [null_resource.nodejs_layer]
}

resource "aws_lambda_layer_version" "nodejs_layer" {
  layer_name          = "nodejs"
  filename            = local.layers_zip_name
  source_code_hash    = data.archive_file.nodejs_layer_package.output_base64sha256
  compatible_runtimes = [var.runtime]
}

data "archive_file" "handler" {
  type        = "zip"
  source_dir  = var.handler_path
  output_path = local.handler_zip_name
}

resource "aws_lambda_function" "lambda" {
  filename                       = local.handler_zip_name
  function_name                  = local.function_name
  role                           = aws_iam_role.lambda_role.arn
  handler                        = var.handler
  source_code_hash               = filebase64sha256(local.handler_zip_name)
  runtime                        = var.runtime
  depends_on                     = [data.archive_file.handler]
  layers                         = [aws_lambda_layer_version.nodejs_layer.arn]
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = {
      ENV = var.env
    }
  }

  tags = {
    ENV = var.env
  }
}
