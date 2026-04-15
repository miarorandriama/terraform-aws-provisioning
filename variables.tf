variable "common_tags" {
  description = "Common tags for all the resources"
  type = map(string)
}

variable "environment" {
  description = "Name of the environment"
  type = string
}