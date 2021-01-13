variable "function_name" {}

variable "runtime" {
  default = "nodejs12.x"
}

variable "handler" {
  default = "exports.handler"
}

variable "handler_path" {
  default = "src/handler"
}

variable "layers_path" {
  default = "src/layers"
}

variable "build_dir_rel_path" {
  default = "dist"
}

variable "env" {
  default = "dev"
}
