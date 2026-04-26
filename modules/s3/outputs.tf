output "bucket_id" {
  description = "Le nom du bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "L'ARN du bucket pour les politiques IAM"
  value       = aws_s3_bucket.this.arn
}
