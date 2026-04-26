output "the_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.the_bucket.id
}

output "the_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.the_bucket.arn
}
