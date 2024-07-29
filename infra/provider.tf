provider "aws" {
  region = "sa-east-1"
}

# Create S3 Bucket for Static Site
resource "aws_s3_bucket" "static_site_bucket" {
  bucket = "static-site-${var.bucket_name}"  # Ensure this bucket name is unique
 # Use private as default; we'll use public access block for public access
  tags = {
    Name = "Static Site Bucket"
  }
}

# Configure the bucket for static site hosting
resource "aws_s3_bucket_website_configuration" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Block public access settings for the bucket
resource "aws_s3_bucket_public_access_block" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Ownership controls to manage object ownership
resource "aws_s3_bucket_ownership_controls" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Optional: If you want to apply public read access through bucket policy
resource "aws_s3_bucket_policy" "static_site_bucket_policy" {
  bucket = aws_s3_bucket.static_site_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.static_site_bucket.arn}/*"
      }
    ]
  })
}
