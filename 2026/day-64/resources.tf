resource "aws_s3_bucket" "terraweek" {
  bucket = "terraweek-state-sahil"
  tags = {
    Name = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "terraweek-versioning" {
  bucket = aws_s3_bucket.terraweek.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "remote-dynamodb-table" {
  name           = "remote-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

}
  