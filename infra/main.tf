resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "My Static app Bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "static_site_bucket" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "static_site_bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "static_site_bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "static_site_bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      },
      {
        Sid: "ModifyBucketPolicy",
        Effect: "Allow",
        Principal: {
          "AWS": "*"
        },
        Action: [
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy"
        ],
        Resource: "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}"
      },
      {
        Sid: "AccessS3Console",
        Effect: "Allow",
        Principal: {
          "AWS": "*"
        },
        Action: [
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets"
        ],
        Resource: "arn:aws:s3:::*"
      }
    ]
  })
}
