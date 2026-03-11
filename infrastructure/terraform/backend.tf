# S3 backend for remote state storage
# Note: S3 bucket and DynamoDB table must be created first
# Run: ./setup-backend.sh before terraform init

terraform {
  backend "s3" {
    bucket         = "terraform-state-youlend-${var.aws_account_id}"
    key            = "youlend/terraform.tfstate"
    region         = "us-east-1"
    profile        = "youlend"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-youlend"

    # Optional: Enable versioning on the bucket
    # versioning = true
  }
}
