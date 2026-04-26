# S3 Bucket Configuration variables
variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "versioning" {
  description = "Activate or not versioning"
  type        = string
}

# Tags and environment variables
variable "environment" {
  description = "The environment for the S3 bucket"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all the ressources"
  type        = map(string)
}

variable "additional_tags" {
  description = "Additional tags specific for the S3 buckets (will be merged with common_tags)"
  type        = map(string)
  default     = {}
}
