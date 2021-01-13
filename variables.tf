variable "function_name" {}

variable "runtime" {
  default     = "nodejs12.x"
  description = "See Node.js runtimes here: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html"
}

variable "handler" {
  default     = "exports.handler"
  description = "Name of the exported handler function"
}

variable "handler_path" {
  default     = "src/handler"
  description = "Relative path from 'path.root' to the handler directory"
}

variable "layers_path" {
  default     = "src/layers"
  description = "Relative path from 'path.root' to the layers directory"
}
variable "build_dir_rel_path" {
  default     = "dist"
  description = "Relative path from 'path.root' to the build directory (you probably want to add this to .gitignore)"
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



