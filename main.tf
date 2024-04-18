# Create S3 bucket to hold the website
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

# # Upload index.html to S3 bucket
# resource "aws_s3_object" "index_html" {
#   bucket       = aws_s3_bucket.website_bucket.id
#   key          = "index.html"
#   source       = "website/index.html" # Path to the local index.html file
#   etag         = filemd5("website/index.html")
#   content_type = "text/html" # Setting the MIME type
# }

# # Upload error.html to S3 bucket
# resource "aws_s3_object" "error_html" {
#   bucket       = aws_s3_bucket.website_bucket.id
#   key          = "index.html"
#   source       = "website/index.html" # Path to the local error.html file
#   etag         = filemd5("website/index.html")
#   content_type = "text/html" # Setting the MIME type
# }

# # Upload CSS files to S3 bucket
# resource "aws_s3_object" "css_files" {
#   for_each     = fileset("website/assets/css", "**/*.css")
#   bucket       = aws_s3_bucket.website_bucket.id
#   key          = "assets/css/${each.value}"
#   source       = "website/assets/css/${each.value}"
#   etag         = filemd5("website/assets/css/${each.value}")
#   content_type = "text/css" # Setting the MIME type
# }

# # Upload JS files to S3 bucket
# resource "aws_s3_object" "js_files" {
#   for_each     = fileset("website/assets/js", "**/*.js")
#   bucket       = aws_s3_bucket.website_bucket.id
#   key          = "assets/js/${each.value}"
#   source       = "website/assets/js/${each.value}"
#   etag         = filemd5("website/assets/js/${each.value}")
#   content_type = "application/javascript" # Setting the MIME type
# }

# # Upload images to S3 bucket
# resource "aws_s3_object" "image_files" {
#   for_each = fileset("website/assets/img", "**/*")
#   bucket   = aws_s3_bucket.website_bucket.id
#   key      = "assets/img/${each.value}"
#   source   = "website/assets/img/${each.value}"
#   etag     = filemd5("website/assets/img/${each.value}")

#   content_type = lookup({
#     "jpg"  = "image/jpeg"
#     "jpeg" = "image/jpeg"
#     "png"  = "image/png"
#     "gif"  = "image/gif"
#     "svg"  = "image/svg+xml"
#   }, regex("\\.([^.]+)$", each.value)[0], "")
# }

# # Upload fonts to S3 bucket
# resource "aws_s3_object" "font_files" {
#   for_each     = fileset("website/assets/fonts", "**/*")
#   bucket       = aws_s3_bucket.website_bucket.id
#   key          = "assets/fonts/${each.value}"
#   source       = "website/assets/fonts/${each.value}"
#   etag         = filemd5("website/assets/fonts/${each.value}")
#   content_type = "font/*" # Setting the MIME type based on file extension
# }

# Create CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin Access Identity for static website"
}

# Create CloudFront Distribution
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = var.bucket_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.website_index_document

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = "arn:aws:acm:us-east-1:403146930820:certificate/3123b496-dd65-48a8-83ca-b73934a53aca"
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "CloudFront Distribution"
    Environment = "Production"
  }
}

# S3 Bucket Policy to allow CloudFront Origin Access Identity to read objects
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
        Principal = {
          CanonicalUser = aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id
        }
      }
    ]
  })
}