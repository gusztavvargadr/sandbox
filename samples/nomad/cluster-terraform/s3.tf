locals {
  s3_options = {
    bucket_name = "${local.deployment.name}"
  }
}

resource "aws_s3_bucket" "default" {
  bucket        = local.s3_options.bucket_name
  force_destroy = true
}

locals {
  s3 = {
    bucket_id   = aws_s3_bucket.default.id
    bucket_name = aws_s3_bucket.default.bucket
    bucket_arn  = aws_s3_bucket.default.arn
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "${local.s3.bucket_arn}",
      "${local.s3.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3" {
  name   = "${local.deployment.name}.s3"
  policy = data.aws_iam_policy_document.s3.json
}
