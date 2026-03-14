// Create an S3 bucket resource
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

// Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

// variable "bucket_name" 
variable "bucket_name" {
  type        = string
  default     = ""
  description = "description"
}

//data "aws_s3_bucket" "bucket" {

data "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}
//local "name" {
locals {
  name = "value"
}

module "s3_bucket" {
  source = "/path/to/module"
 
}

