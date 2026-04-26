# 1. Création du Bucket
resource "aws_s3_bucket" "the_bucket" {
  bucket = var.bucket_name

  tags = merge(
    var.common_tags,
    var.additional_tags,
    {
      Name = "${var.environment}-${lookup(var.additional_tags, "Service", "free")}"
    }
  )
}

# 2. Configuration du Versioning
resource "aws_s3_bucket_versioning" "the_versioning" {
  bucket = aws_s3_bucket.the_bucket.id
  versioning_configuration {
    status = var.versioning
  }
}

# 3. Chiffrement par défaut (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "the_encryption" {
  bucket = aws_s3_bucket.the_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Blocage de l'accès public (Sécurité critique)
resource "aws_s3_bucket_public_access_block" "the_public_block" {
  bucket = aws_s3_bucket.the_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
