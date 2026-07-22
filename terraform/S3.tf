# create s3 bucket
/*
resource "aws_s3_bucket" "flight_bucket" {
    bucket = "flight-2-bucket-295"

    tags = {
        Name = "staticWebsiteBucket"
        env = "dev"
    }
}

resource "aws_s3_bucket_website_configuration" "flight_bucket_website" {
    bucket = aws_s3_bucket.flight_bucket.id

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}


# disable Public access

resource "aws_s3_bucket_public_access_block" "flight" {
    bucket = aws_s3_bucket.flight_bucket.id

    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
  
}

# bucket policy t allow read access

resource "aws_s3_bucket_policy" "static_website_policy" {
    bucket = aws_s3_bucket.flight_bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement= [
            {
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = "${aws_s3_bucket.flight_bucket.arn}/*"
            }
        ]
    })
    depends_on = [aws_s3_bucket_public_access_block.flight]
}

resource "aws_s3_bucket_versioning" "flight_bucket_versioning" {
    bucket = aws_s3_bucket.flight_bucket.id

    versioning_configuration {
        status = "Enabled"
    }
}

*/


############################
# S3 Bucket
############################

resource "aws_s3_bucket" "flight_bucket" {

  bucket = "flight-2-bucket-29578"

  tags = {
    Name        = "flight-frontend-bucket"
    Environment = "dev"
  }
}

############################
# Enable Versioning
############################

resource "aws_s3_bucket_versioning" "flight_bucket_versioning" {

  bucket = aws_s3_bucket.flight_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

############################
# Block ALL Public Access
############################

resource "aws_s3_bucket_public_access_block" "flight_bucket_public_access" {

  bucket = aws_s3_bucket.flight_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

############################
# Bucket Ownership
############################

resource "aws_s3_bucket_ownership_controls" "flight_bucket_ownership" {

  bucket = aws_s3_bucket.flight_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#############################################
# Allow CloudFront to access the S3 bucket
#############################################

data "aws_iam_policy_document" "flight_bucket_policy" {

  statement {

    sid = "AllowCloudFrontServicePrincipal"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.flight_bucket.arn}/*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com"
      ]
    }

    condition {

      test = "StringEquals"

      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.frontend.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "flight_bucket_policy" {

  bucket = aws_s3_bucket.flight_bucket.id

  policy = data.aws_iam_policy_document.flight_bucket_policy.json
}
