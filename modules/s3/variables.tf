variable "bucket_name" {
  description = "The name of the bucket"
  type = string
}

variable "environment" {
  description = "The environment for the S3 bucket"
  type = string
  default = "dev"
}

variable "common_tags" {
  description = "Common tags for all the ressources"
  type = map(string)
}

variable "versioning_enabled" {
  description = "Activate or not versioning"
  type = string
  default = "Enabled" # S3 versioning can be either "Enabled" or "Suspended"
}