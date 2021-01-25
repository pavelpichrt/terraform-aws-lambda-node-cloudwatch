variable "function_name" {}

variable "runtime" {
  default     = "nodejs12.x"
  description = "See Node.js runtimes here: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html"
}

variable "handler" {
  default     = "index.handler"
  description = "Name of the exported handler function"
}

variable "proj_root_relative_path" {
  default     = ".."
  description = "Relative path from 'path.root' project root"
}

variable "handler_path" {
  default     = "src/handler"
  description = "Relative path from 'path.root' to the handler directory"
}

variable "env" {
  default     = "dev"
  description = "Only serves for naming/tagging"
}

variable "memory_size" {
  default     = "128"
  description = "same as aws_lambda_function resource"
}

variable "timeout" {
  default     = "3"
  description = "same as aws_lambda_function resource"
}

variable "reserved_concurrent_executions" {
  default     = "-1"
  description = "same as aws_lambda_function resource"
}

variable "env_vars" {
  default     = {}
  type        = map(string)
  description = "same as aws_lambda_function resource.environment.variables"
}

