locals {
  build_dir_rel_path   = "dist"
  build_directory_path = "${path.root}/${local.build_dir_rel_path}"
  handler_zip_name     = "${local.build_dir_rel_path}/handler.zip"
  layers_path          = "${path.root}/src/layers"
  node_layer_path      = "${local.layers_path}/nodejs"
  layers_zip_name      = "${local.build_dir_rel_path}/nodejs.zip"
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
  name               = "${var.function_name}-${var.env}-lambda"
  assume_role_policy = data.aws_iam_policy_document.test_lambda_assume_role_policy.json

  tags = {
    ENV = var.env
  }
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 60

  tags = {
    ENV = var.env
  }
}

data "aws_iam_policy_document" "cloudwatch_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      aws_cloudwatch_log_group.lambda_log_group.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]
    resources = [
      "${aws_cloudwatch_log_group.lambda_log_group.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  name   = "${var.function_name}-${var.env}-cloudwatch-policy"
  policy = data.aws_iam_policy_document.cloudwatch_role_policy_document.json
  role   = aws_iam_role.lambda_role.id
}

resource "null_resource" "nodejs_layer" {
  provisioner "local-exec" {
    command = <<EOT
      rm -rf ${local.layers_path} && \
      mkdir -p ${local.node_layer_path} && \
      cp ${var.proj_root_relative_path}/{package.json,package-lock.json} ${local.node_layer_path} && \
      cd ${local.node_layer_path} && \
      NODE_ENV=production npm ci
    EOT
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

resource "null_resource" "nodejs_layer_cleanup" {
  provisioner "local-exec" {
    command = "rm -rf ${local.layers_path}"
  }

  depends_on = [data.archive_file.nodejs_layer_package]
}

resource "aws_lambda_layer_version" "nodejs_layer" {
  layer_name          = "nodejs"
  filename            = local.layers_zip_name
  source_code_hash    = data.archive_file.nodejs_layer_package.output_base64sha256
  compatible_runtimes = [var.runtime]
}

data "archive_file" "handler" {
  type        = "zip"
  source_dir  = "${path.root}/${var.proj_root_relative_path}/${var.handler_path}"
  output_path = local.handler_zip_name
}

#  resource "aws_lambda_function" "lambda" {
#   filename                       = local.handler_zip_name
#   function_name                  = local.function_name
#   role                           = aws_iam_role.lambda_role.arn
#   handler                        = var.handler
#   source_code_hash               = filebase64sha256(local.handler_zip_name)
#   runtime                        = var.runtime
#   layers                         = [aws_lambda_layer_version.nodejs_layer.arn]
#   timeout                        = var.timeout
#   memory_size                    = var.memory_size
#   reserved_concurrent_executions = var.reserved_concurrent_executions
#   depends_on                     = [data.archive_file.handler]

#   environment {
#     variables = var.env_vars
#   }

#   tags = {
#     ENV = var.env
#   }
# }
