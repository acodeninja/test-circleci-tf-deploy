provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    region  = "eu-west-2"
    bucket  = "acodeninja-tf-state"
    key     = "test-circleci-tf-deploy/terraform.tfstate"
  }
}

locals {
  tags = {
    Application = "test-circleci-tf-deploy"
    Terraform = "True"
  }
  mime_types = {
    js    = "application/javascript"
    map   = "application/javascript"
    json  = "application/json"
    png   = "image/png"
    svg   = "image/svg+xml"
    ico   = "image/x-icon"
    css   = "text/css"
    html  = "text/html"
    txt   = "text/plain"
  }
}

resource "aws_s3_bucket" "website" {
  bucket  = "${local.tags.Application}-bucket"
  acl     = "public-read"
  tags    = local.tags

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "website_files" {
  for_each      = fileset("build/", "**/*.*")
  bucket        = aws_s3_bucket.website.bucket
  key           = replace(each.value, "build/", "")
  source        = "build/${each.value}"
  acl           = "public-read"
  etag          = filemd5("build/${each.value}")
  content_type  = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
  tags          = local.tags
}
