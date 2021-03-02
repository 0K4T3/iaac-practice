provider "aws" {
  region = "us-east-1"

  access_key = "dummy_access_key"
  secret_key = "dummmy_secret_key"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    dynamodb = "http://localhost:4566"
  }
}

resource "aws_dynamodb_table" "users_table" {
  name           = "Users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }
}
